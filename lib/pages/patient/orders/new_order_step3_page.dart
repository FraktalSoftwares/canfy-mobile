import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../widgets/patient/new_order_step_progress.dart';
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

  Widget _buildDocumentUploadCard({
    required String title,
    required String? fileName,
    required bool hasValue,
    required VoidCallback onAddOrReplace,
    VoidCallback? onReplace,
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
              height: 1.5,
            ),
          ),
          const Text(
            'Formatos aceitos: PDF, PNG, JPG',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Área de upload (estado preenchido ou vazio)
          hasValue
              ? Column(
                  children: [
                    // Card com arquivo anexado (borda sólida)
                    Center(
                      child: GestureDetector(
                        onTap: onAddOrReplace,
                        child: Container(
                          width: 310,
                          padding: const EdgeInsets.symmetric(vertical: 44),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF33CC80),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                fileName ?? 'documento.pdf',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00994B),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Botão "Trocar documento" (verde preenchido)
                    if (onReplace != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onReplace,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BB5A),
                            foregroundColor: const Color(0xFFE6F8EF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Trocar documento',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Center(
                  child: GestureDetector(
                    onTap: onAddOrReplace,
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        color: const Color(0xFF33CC80),
                        strokeWidth: 1.5,
                        borderRadius: 18,
                      ),
                      child: Container(
                        width: 310,
                        padding: const EdgeInsets.symmetric(vertical: 44),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                color: Color(0xFF00994B),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Clique para adicionar o arquivo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00994B),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Indicador de progresso: 6 segmentos, 3 verdes
            const NewOrderStepProgress(currentStep: 3),
            const SizedBox(height: 40),
            // Header: "Novo pedido" + badge etapa (SEM badge de valor conforme Figma)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Novo pedido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
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
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Card roxo de aviso (receita já anexada)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA987F5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child:
                        const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sua receita médica já foi anexada automaticamente\na este pedido. Não é necessário enviar novamente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4E3390),
                        height: 1.5,
                      ),
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
              // Card: RG ou CNH
              _buildDocumentUploadCard(
                title: 'RG ou CNH',
                fileName: _displayFileName(_rgFile, _rgExistingFileName),
                hasValue: _hasRg,
                onAddOrReplace: () {
                  _showPickSourceSheet(
                    onCamera: () async {
                      final file = await _pickFromCamera();
                      if (mounted && file != null) {
                        setState(() => _rgFile = file);
                      }
                    },
                    onGallery: () async {
                      final file = await _pickFromGallery();
                      if (mounted && file != null) {
                        setState(() => _rgFile = file);
                      }
                    },
                  );
                },
                onReplace: _hasRg
                    ? () {
                        _showPickSourceSheet(
                          onCamera: () async {
                            final file = await _pickFromCamera();
                            if (mounted && file != null) {
                              setState(() => _rgFile = file);
                            }
                          },
                          onGallery: () async {
                            final file = await _pickFromGallery();
                            if (mounted && file != null) {
                              setState(() => _rgFile = file);
                            }
                          },
                        );
                      }
                    : null,
              ),
              // Card: Comprovante de residência
              _buildDocumentUploadCard(
                title: 'Comprovante de residência',
                fileName: _displayFileName(
                    _addressProofFile, _addressProofExistingFileName),
                hasValue: _hasAddressProof,
                onAddOrReplace: () {
                  _showPickSourceSheet(
                    onCamera: () async {
                      final file = await _pickFromCamera();
                      if (mounted && file != null) {
                        setState(() => _addressProofFile = file);
                      }
                    },
                    onGallery: () async {
                      final file = await _pickFromGallery();
                      if (mounted && file != null) {
                        setState(() => _addressProofFile = file);
                      }
                    },
                  );
                },
                onReplace: _hasAddressProof
                    ? () {
                        _showPickSourceSheet(
                          onCamera: () async {
                            final file = await _pickFromCamera();
                            if (mounted && file != null) {
                              setState(() => _addressProofFile = file);
                            }
                          },
                          onGallery: () async {
                            final file = await _pickFromGallery();
                            if (mounted && file != null) {
                              setState(() => _addressProofFile = file);
                            }
                          },
                        );
                      }
                    : null,
              ),
              // Card: Autorização da Anvisa
              _buildDocumentUploadCard(
                title: 'Autorização da Anvisa',
                fileName: _displayFileName(_anvisaFile, null),
                hasValue: _hasAnvisa,
                onAddOrReplace: () {
                  _showPickSourceSheet(
                    onCamera: () async {
                      final file = await _pickFromCamera();
                      if (mounted && file != null) {
                        setState(() => _anvisaFile = file);
                      }
                    },
                    onGallery: () async {
                      final file = await _pickFromGallery();
                      if (mounted && file != null) {
                        setState(() => _anvisaFile = file);
                      }
                    },
                  );
                },
                onReplace: _hasAnvisa
                    ? () {
                        _showPickSourceSheet(
                          onCamera: () async {
                            final file = await _pickFromCamera();
                            if (mounted && file != null) {
                              setState(() => _anvisaFile = file);
                            }
                          },
                          onGallery: () async {
                            final file = await _pickFromGallery();
                            if (mounted && file != null) {
                              setState(() => _anvisaFile = file);
                            }
                          },
                        );
                      }
                    : null,
              ),
              // Erro de upload, se houver
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
              // Botão "Próximo"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed && !_uploadingOnNext ? _onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BB5A),
                    foregroundColor: const Color(0xFFE6F8EF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 1),
    );
  }
}

/// Desenha borda tracejada (Figma: estado vazio do upload).
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.borderRadius = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    final inset = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          inset, inset, size.width - inset * 2, size.height - inset * 2),
      Radius.circular(borderRadius - inset),
    );
    final path = Path()..addRRect(rrect);
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(distance, end);
        canvas.drawPath(extractPath, paint);
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
