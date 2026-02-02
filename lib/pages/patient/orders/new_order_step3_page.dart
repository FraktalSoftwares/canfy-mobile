import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../models/order/new_order_form_data.dart';
import '../../../services/storage/image_storage_service.dart';
import '../../../services/api/patient_service.dart';

class NewOrderStep3Page extends StatefulWidget {
  final NewOrderFormData? formData;

  const NewOrderStep3Page({super.key, this.formData});

  @override
  State<NewOrderStep3Page> createState() => _NewOrderStep3PageState();
}

class _NewOrderStep3PageState extends State<NewOrderStep3Page> {
  final ImageStorageService _storageService = ImageStorageService();
  final PatientService _patientService = PatientService();
  final ImagePicker _imagePicker = ImagePicker();

  // RG/CNH: novo arquivo local ou último anexo (pode trocar)
  File? _rgFile;
  String? _rgExistingUrl;
  String? _rgExistingFileName;

  // Comprovante: novo arquivo local ou último anexo (pode trocar)
  File? _addressProofFile;
  String? _addressProofExistingUrl;
  String? _addressProofExistingFileName;

  // Anvisa: sempre novo anexo
  File? _anvisaFile;

  bool _loadingExisting = true;
  bool _uploadingOnNext = false;
  String? _uploadError;

  NewOrderFormData get formData => widget.formData!;

  @override
  void initState() {
    super.initState();
    if (widget.formData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/patient/orders/new/step1');
      });
      return;
    }
    _loadLastDocuments();
  }

  Future<void> _loadLastDocuments() async {
    setState(() => _loadingExisting = true);
    try {
      final result = await _patientService.getLastPatientDocuments();
      if (mounted && result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final identidade = data['identidade'] as Map<String, dynamic>?;
        final comprovante =
            data['comprovante_residencia'] as Map<String, dynamic>?;
        setState(() {
          if (identidade != null) {
            _rgExistingUrl = identidade['arquivo_url'] as String?;
            _rgExistingFileName = identidade['nome_arquivo'] as String?;
          }
          if (comprovante != null) {
            _addressProofExistingUrl = comprovante['arquivo_url'] as String?;
            _addressProofExistingFileName =
                comprovante['nome_arquivo'] as String?;
          }
          _loadingExisting = false;
        });
      } else {
        if (mounted) setState(() => _loadingExisting = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  void _showPickSourceSheet({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Anexar documento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF00994B)),
                title: const Text('Câmera'),
                onTap: () {
                  Navigator.pop(context);
                  onCamera();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: Color(0xFF00994B)),
                title: const Text('Galeria'),
                onTap: () {
                  Navigator.pop(context);
                  onGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<File?> _pickFromCamera() async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return null;
    return File(xFile.path);
  }

  Future<File?> _pickFromGallery() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: false,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null ||
        !mounted) {
      return null;
    }
    return File(result.files.single.path!);
  }

  String? _displayFileName(File? file, String? existingFileName) {
    if (file != null) {
      final segments = file.path.replaceAll('\\', '/').split('/');
      return segments.isNotEmpty ? segments.last : 'Arquivo';
    }
    return existingFileName;
  }

  bool get _hasRg =>
      _rgFile != null || (_rgExistingUrl != null && _rgExistingUrl!.isNotEmpty);
  bool get _hasAddressProof =>
      _addressProofFile != null ||
      (_addressProofExistingUrl != null &&
          _addressProofExistingUrl!.isNotEmpty);
  bool get _hasAnvisa => _anvisaFile != null;

  bool get _canProceed => _hasRg && _hasAddressProof && _hasAnvisa;

  Future<void> _onNext() async {
    setState(() {
      _uploadingOnNext = true;
      _uploadError = null;
    });

    String? rgUrl = _rgExistingUrl;
    String? rgFileName = _rgExistingFileName;
    String? addressProofUrl = _addressProofExistingUrl;
    String? addressProofFileName = _addressProofExistingFileName;
    String? anvisaUrl;
    String? anvisaFileName;

    try {
      if (_rgFile != null) {
        final contentType = _rgFile!.path.toLowerCase().endsWith('.pdf')
            ? 'application/pdf'
            : 'image/jpeg';
        final res = await _storageService.uploadDocument(
          _rgFile!,
          contentType: contentType,
        );
        if (res['success'] != true || res['url'] == null) {
          throw Exception(res['message'] ?? 'Falha ao enviar RG/CNH');
        }
        rgUrl = res['url'] as String;
        rgFileName =
            res['fileName'] as String? ?? _displayFileName(_rgFile, null);
      }

      if (_addressProofFile != null) {
        final contentType =
            _addressProofFile!.path.toLowerCase().endsWith('.pdf')
                ? 'application/pdf'
                : 'image/jpeg';
        final res = await _storageService.uploadDocument(
          _addressProofFile!,
          contentType: contentType,
        );
        if (res['success'] != true || res['url'] == null) {
          throw Exception(res['message'] ?? 'Falha ao enviar comprovante');
        }
        addressProofUrl = res['url'] as String;
        addressProofFileName = res['fileName'] as String? ??
            _displayFileName(_addressProofFile, null);
      }

      if (_anvisaFile == null) {
        throw Exception('Envie a autorização da Anvisa');
      }
      final contentTypeAnvisa = _anvisaFile!.path.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'image/jpeg';
      final resAnvisa = await _storageService.uploadDocument(
        _anvisaFile!,
        contentType: contentTypeAnvisa,
      );
      if (resAnvisa['success'] != true || resAnvisa['url'] == null) {
        throw Exception(
            resAnvisa['message'] ?? 'Falha ao enviar autorização Anvisa');
      }
      anvisaUrl = resAnvisa['url'] as String;
      anvisaFileName = resAnvisa['fileName'] as String? ??
          _displayFileName(_anvisaFile, null);

      if (!mounted) return;
      final updated = formData.copyWith(
        rgDocumentUrl: rgUrl,
        rgFileName: rgFileName,
        addressProofUrl: addressProofUrl,
        addressProofFileName: addressProofFileName,
        anvisaDocumentUrl: anvisaUrl,
        anvisaFileName: anvisaFileName,
      );
      context.push('/patient/orders/new/step4', extra: updated);
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadingOnNext = false;
          _uploadError = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(
        5,
        (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: i < 3 ? 53 : (i == 3 ? 52 : 53),
            height: 6,
            decoration: BoxDecoration(
              color: i < 3 ? const Color(0xFF00BB5A) : const Color(0xFFD6D6D3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    String? subtitle,
    required String? fileName,
    required bool hasValue,
    required VoidCallback onAddOrReplace,
    required VoidCallback? onReplace,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F3F3D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Formatos aceitos: PDF, PNG, JPG',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAddOrReplace,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 44),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF33CC80),
                  width: 1.5,
                ),
              ),
              child: hasValue
                  ? Column(
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
                            color: Color(0xFF00994B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          fileName ?? 'Documento anexado',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00994B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (onReplace != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Toque para trocar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F8EF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 32,
                            color: Color(0xFF00994B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Câmera ou galeria',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00994B),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (hasValue && onReplace != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onReplace,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF00994B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Trocar documento',
                  style: TextStyle(fontSize: 14, color: Color(0xFF00994B)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formData == null) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF00994B))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Upload de documentos',
        fallbackRoute: '/patient/orders/new/step2',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildProgressIndicator(),
            const SizedBox(height: 40),
            const Text(
              'Novo pedido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Etapa 3 - Upload de documentos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA987F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child:
                        const Icon(Icons.check, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sua receita médica já foi anexada automaticamente a este pedido. Não é necessário enviar novamente.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4E3390)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loadingExisting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: Color(0xFF00994B)),
                ),
              )
            else ...[
              _buildDocumentUploadCard(
                title: 'RG ou CNH',
                subtitle:
                    'Último anexo pode ser reutilizado. Toque para trocar ou anexar.',
                fileName: _displayFileName(_rgFile, _rgExistingFileName),
                hasValue: _hasRg,
                onAddOrReplace: () {
                  _showPickSourceSheet(
                    onCamera: () async {
                      final file = await _pickFromCamera();
                      if (mounted && file != null)
                        setState(() => _rgFile = file);
                    },
                    onGallery: () async {
                      final file = await _pickFromGallery();
                      if (mounted && file != null)
                        setState(() => _rgFile = file);
                    },
                  );
                },
                onReplace: _hasRg
                    ? () {
                        _showPickSourceSheet(
                          onCamera: () async {
                            final file = await _pickFromCamera();
                            if (mounted && file != null)
                              setState(() => _rgFile = file);
                          },
                          onGallery: () async {
                            final file = await _pickFromGallery();
                            if (mounted && file != null)
                              setState(() => _rgFile = file);
                          },
                        );
                      }
                    : null,
              ),
              _buildDocumentUploadCard(
                title: 'Comprovante de residência',
                subtitle:
                    'Último anexo pode ser reutilizado. Toque para trocar ou anexar.',
                fileName: _displayFileName(
                    _addressProofFile, _addressProofExistingFileName),
                hasValue: _hasAddressProof,
                onAddOrReplace: () {
                  _showPickSourceSheet(
                    onCamera: () async {
                      final file = await _pickFromCamera();
                      if (mounted && file != null)
                        setState(() => _addressProofFile = file);
                    },
                    onGallery: () async {
                      final file = await _pickFromGallery();
                      if (mounted && file != null)
                        setState(() => _addressProofFile = file);
                    },
                  );
                },
                onReplace: _hasAddressProof
                    ? () {
                        _showPickSourceSheet(
                          onCamera: () async {
                            final file = await _pickFromCamera();
                            if (mounted && file != null)
                              setState(() => _addressProofFile = file);
                          },
                          onGallery: () async {
                            final file = await _pickFromGallery();
                            if (mounted && file != null)
                              setState(() => _addressProofFile = file);
                          },
                        );
                      }
                    : null,
              ),
              _buildDocumentUploadCard(
                title: 'Autorização da Anvisa',
                subtitle:
                    'Sempre é necessário enviar uma nova autorização para cada pedido.',
                fileName: _displayFileName(_anvisaFile, null),
                hasValue: _hasAnvisa,
                onAddOrReplace: () {
                  _showPickSourceSheet(
                    onCamera: () async {
                      final file = await _pickFromCamera();
                      if (mounted && file != null)
                        setState(() => _anvisaFile = file);
                    },
                    onGallery: () async {
                      final file = await _pickFromGallery();
                      if (mounted && file != null)
                        setState(() => _anvisaFile = file);
                    },
                  );
                },
                onReplace: _hasAnvisa
                    ? () {
                        setState(() => _anvisaFile = null);
                      }
                    : null,
              ),
              if (_uploadError != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Color(0xFFC62828), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _uploadError!,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFFC62828)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canProceed && !_uploadingOnNext ? _onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00994B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _uploadingOnNext
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Próximo',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 1),
    );
  }
}
