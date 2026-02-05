import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/medico_service.dart';
import '../../services/api/api_service.dart';
import '../../services/storage/image_storage_service.dart';

class Step2DocumentsPage extends StatefulWidget {
  const Step2DocumentsPage({super.key});

  @override
  State<Step2DocumentsPage> createState() => _Step2DocumentsPageState();
}

class _Step2DocumentsPageState extends State<Step2DocumentsPage> {
  final MedicoService _medicoService = MedicoService();
  final ApiService _apiService = ApiService();
  final ImageStorageService _storageService = ImageStorageService();

  String? _medicoId;
  bool _isLoading = true;
  String? _loadError;
  bool _isSaving = false;
  String? _saveError;

  /// Por tipo: id do registro, url e nome do arquivo (quando já salvo) ou arquivo local (quando acabou de escolher)
  final Map<String, String?> _docIds = {};
  final Map<String, String?> _docUrls = {};
  final Map<String, String?> _docFileNames = {};
  final Map<String, File?> _docLocalFiles = {};

  static const List<Map<String, dynamic>> _documentTypes = [
    {'key': 'rg_ou_cnh', 'title': 'RG ou CNH', 'optional': false},
    {
      'key': 'comprovante_residencia',
      'title': 'Comprovante de residência',
      'optional': false
    },
    {
      'key': 'comprovante_crm_cro',
      'title': 'Comprovante do CRM/CRO',
      'optional': false
    },
    {'key': 'diploma', 'title': 'Diploma', 'optional': false},
    {
      'key': 'certificado_complementar',
      'title': 'Certificado complementar',
      'optional': true
    },
    {
      'key': 'outros_documentos',
      'title': 'Outros documentos',
      'optional': true
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    final medicoResult = await _medicoService.getMedicoByCurrentUser();
    if (!mounted) return;
    if (medicoResult['success'] != true || medicoResult['data'] == null) {
      setState(() {
        _isLoading = false;
        _loadError =
            medicoResult['message'] as String? ?? 'Médico não encontrado';
      });
      return;
    }
    final medico = medicoResult['data'] as Map<String, dynamic>;
    _medicoId = medico['id'] as String?;
    if (_medicoId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Médico não encontrado';
      });
      return;
    }
    final docsResult = await _medicoService.getMedicoDocumentos(_medicoId!);
    if (mounted &&
        docsResult['success'] == true &&
        docsResult['data'] != null) {
      final byTipo = docsResult['data'] as Map<String, dynamic>;
      for (final e in byTipo.entries) {
        final doc = e.value as Map<String, dynamic>;
        _docIds[e.key] = doc['id'] as String?;
        _docUrls[e.key] = doc['arquivo_url'] as String?;
        _docFileNames[e.key] = doc['nome_arquivo'] as String?;
      }
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  bool _hasDoc(String key) {
    if (_docLocalFiles[key] != null) return true;
    final url = _docUrls[key];
    return url != null && url.isNotEmpty;
  }

  String? _displayFileName(String key) {
    if (_docLocalFiles[key] != null) {
      final p = _docLocalFiles[key]!.path.replaceAll('\\', '/');
      final segments = p.split('/');
      return segments.isNotEmpty ? segments.last : 'documento';
    }
    return _docFileNames[key];
  }

  bool get _canProceed {
    for (final t in _documentTypes) {
      if (t['optional'] == true) continue;
      if (!_hasDoc(t['key'] as String)) return false;
    }
    return true;
  }

  Future<void> _pickAndUpload(String tipo) async {
    if (_medicoId == null) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: false,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null ||
        !mounted) {
      return;
    }
    final file = File(result.files.single.path!);
    final ext = file.path.toLowerCase().split('.').last;
    final contentType = ext == 'pdf'
        ? 'application/pdf'
        : (ext == 'png' ? 'image/png' : 'image/jpeg');
    final user = _apiService.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Usuário não autenticado'),
              backgroundColor: Color(0xFFD32F2F)),
        );
      }
      return;
    }
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = file.path.replaceAll('\\', '/').split('/').last;
    final safeName = name.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    final path = 'medico_docs/${user.id}/${timestamp}_$safeName';
    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      final uploadResult = await _storageService.uploadDocument(
        file,
        path: path,
        contentType: contentType,
      );
      if (!mounted) return;
      if (uploadResult['success'] != true || uploadResult['url'] == null) {
        setState(() {
          _isSaving = false;
          _saveError =
              uploadResult['message'] as String? ?? 'Erro ao enviar arquivo';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_saveError!),
              backgroundColor: const Color(0xFFD32F2F)),
        );
        return;
      }
      final url = uploadResult['url'] as String;
      final fileName = uploadResult['fileName'] as String? ?? safeName;
      final saveResult = await _medicoService.saveMedicoDocumento(
        _medicoId!,
        tipo: tipo,
        arquivoUrl: url,
        nomeArquivo: fileName,
      );
      if (!mounted) return;
      if (saveResult['success'] == true) {
        setState(() {
          _docLocalFiles[tipo] = null;
          _docUrls[tipo] = url;
          _docFileNames[tipo] = fileName;
          final resData = saveResult['data'];
          if (resData is Map<String, dynamic> && resData['id'] != null) {
            _docIds[tipo] = resData['id'] as String?;
          }
          _isSaving = false;
          _saveError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Documento salvo.'),
              backgroundColor: AppTheme.canfyGreen),
        );
      } else {
        setState(() {
          _isSaving = false;
          _saveError =
              saveResult['message'] as String? ?? 'Erro ao salvar documento';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(_saveError!),
              backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    }
  }

  Future<void> _removeDocument(String tipo) async {
    if (_medicoId == null) return;
    final id = _docIds[tipo];
    setState(() {
      _docLocalFiles[tipo] = null;
      _docUrls[tipo] = null;
      _docFileNames[tipo] = null;
      _docIds[tipo] = null;
    });
    if (id != null) {
      await _medicoService.deleteMedicoDocumento(id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Documento removido.'),
            backgroundColor: AppTheme.canfyGreen),
      );
    }
  }

  void _goNext() {
    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Envie todos os documentos obrigatórios (RG ou CNH, Comprovante de residência, Comprovante do CRM/CRO e Diploma).'),
          backgroundColor: Color(0xFFD32F2F),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    context.go('/professional-validation/step3-availability');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF33CC80),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.white),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/professional-validation/step1-professional-data');
            }
          },
        ),
        title: Text(
          'Envio de documentos',
          style: AppTextStyles.arimo(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.canfyGreen))
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arimo(
                                fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _loadData,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BB5A),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BB5A),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6D6D3),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Validação profissional',
                              style: AppTextStyles.truculenta(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F0EE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Etapa 2 - Envio de documentos',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF3F3F3D),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F8EF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Valor: R\$ 89,90',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF007A3B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ..._documentTypes.map((t) {
                          final key = t['key'] as String;
                          final title = t['title'] as String;
                          final optional = t['optional'] as bool;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildDocumentCard(
                              documentKey: key,
                              title: title,
                              optional: optional,
                              hasDoc: _hasDoc(key),
                              fileName: _displayFileName(key),
                              onAddOrReplace: () => _pickAndUpload(key),
                              onRemove: () => _removeDocument(key),
                              isSaving: _isSaving,
                            ),
                          );
                        }),
                        if (_saveError != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _saveError!,
                              style: AppTextStyles.arimo(
                                  fontSize: 12, color: const Color(0xFFD32F2F)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 49,
                          child: ElevatedButton(
                            onPressed:
                                (_canProceed && !_isSaving) ? _goNext : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.canfyGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFE0E0E0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Próximo',
                                    style: AppTextStyles.arimo(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String documentKey,
    required String title,
    required bool optional,
    required bool hasDoc,
    String? fileName,
    required VoidCallback onAddOrReplace,
    required VoidCallback onRemove,
    required bool isSaving,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.arimo(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3F3F3D),
              ),
              children: [
                TextSpan(text: title),
                if (optional)
                  TextSpan(
                    text: ' (opcional)',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3F3F3D),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Formatos aceitos: PDF, PNG, JPG',
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: const Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 16),
          if (hasDoc && fileName != null)
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 44),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFF33CC80), width: 1.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.insert_drive_file,
                          size: 32,
                          color: AppTheme.canfyGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        fileName,
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.canfyGreen,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onAddOrReplace,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.canfyGreen,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Trocar documento',
                      style: AppTextStyles.arimo(
                          fontSize: 14, color: AppTheme.canfyGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TextButton(
                    onPressed: isSaving ? null : onRemove,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.canfyGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Remover documento',
                      style: AppTextStyles.arimo(
                          fontSize: 14, color: AppTheme.canfyGreen),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: isSaving ? null : onAddOrReplace,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 44),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: const Color(0xFF33CC80), width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F8EF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.cloud_upload,
                        size: 32,
                        color: AppTheme.canfyGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Clique para adicionar o arquivo',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.canfyGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
