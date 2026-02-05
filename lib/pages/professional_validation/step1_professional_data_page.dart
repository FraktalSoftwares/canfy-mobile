import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/api_service.dart';
import '../../services/api/medico_service.dart';
import '../../services/storage/image_storage_service.dart';
import '../../utils/input_masks.dart';

class Step1ProfessionalDataPage extends StatefulWidget {
  const Step1ProfessionalDataPage({super.key});

  @override
  State<Step1ProfessionalDataPage> createState() =>
      _Step1ProfessionalDataPageState();
}

class _Step1ProfessionalDataPageState extends State<Step1ProfessionalDataPage> {
  final MedicoService _medicoService = MedicoService();
  final ApiService _apiService = ApiService();
  final ImageStorageService _imageStorageService = ImageStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImageFile;
  String? _profileFotoUrl;
  String? _userId;

  final _cpfController = TextEditingController();
  final _crmController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _cepController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _complementController = TextEditingController();

  String? _selectedYearsOfExperience;
  String? _selectedEspecialidadeId;
  List<Map<String, dynamic>> _especialidades = [];
  String? _medicoId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  static const List<String> _tempoAtuacaoItems = [
    'Menos de 1 ano',
    '1 a 5 anos',
    '5 a 10 anos',
    '10 a 20 anos',
    'Mais de 20 anos',
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
    final espResult = await _medicoService.getEspecialidades();

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
    _userId = medico['user_id'] as String?;
    _crmController.text = _formatCrmUf(
      medico['crm'] as String?,
      medico['uf_crm'] as String?,
    );
    _cpfController.text =
        InputMasks.formatCpfForDisplay(medico['cpf'] as String?);
    _selectedEspecialidadeId = medico['especialidade_id'] as String?;
    _selectedYearsOfExperience = medico['tempo_atuacao'] as String?;
    _parseEnderecoCompleto(medico['endereco_completo'] as String?);

    // Carregar foto do perfil (profiles.foto_perfil_url)
    if (_userId != null) {
      final profileResult = await _apiService.getFiltered(
        'profiles',
        filters: {'id': _userId!},
        limit: 1,
      );
      if (profileResult['success'] == true &&
          profileResult['data'] != null &&
          (profileResult['data'] as List).isNotEmpty) {
        final profile =
            (profileResult['data'] as List)[0] as Map<String, dynamic>;
        _profileFotoUrl = profile['foto_perfil_url'] as String?;
      }
    }

    List<Map<String, dynamic>> list = [];
    if (espResult['success'] == true && espResult['data'] != null) {
      list = (espResult['data'] as List).cast<Map<String, dynamic>>();
    }
    if (!mounted) return;
    setState(() {
      _especialidades = list;
      _isLoading = false;
    });
  }

  String _formatCrmUf(String? crm, String? ufCrm) {
    if (crm == null || crm.isEmpty) return '';
    if (ufCrm != null && ufCrm.isNotEmpty && ufCrm != 'A confirmar') {
      return '$crm/$ufCrm';
    }
    return crm;
  }

  void _parseEnderecoCompleto(String? endereco) {
    if (endereco == null || endereco.isEmpty) return;
    // Formato: "Logradouro nº X, Bairro, Cidade, Estado, CEP: XXXXX-XXX (Complemento)"
    final parts = endereco.split(',').map((s) => s.trim()).toList();
    if (parts.isEmpty) return;

    // parts[0] = "Logradouro nº X" ou "Logradouro"
    final part0 = parts[0];
    final idxN = part0.toLowerCase().indexOf(' nº ');
    if (idxN >= 0) {
      _streetController.text = part0.substring(0, idxN).trim();
      _numberController.text = part0.substring(idxN + 4).trim();
    } else {
      _streetController.text = part0;
    }

    if (parts.length >= 2) _neighborhoodController.text = parts[1];
    if (parts.length >= 3) _cityController.text = parts[2];
    if (parts.length >= 4) _stateController.text = parts[3];

    // parts[4] = "CEP: 01240001" ou "CEP: 01240-001"
    if (parts.length >= 5 && parts[4].toLowerCase().startsWith('cep:')) {
      final cepRaw = parts[4]
          .replaceFirst(RegExp(r'^cep:\s*', caseSensitive: false), '')
          .trim();
      _cepController.text = InputMasks.formatCepForDisplay(cepRaw);
    }

    // parts[5] = "(Complemento)"
    if (parts.length >= 6 &&
        parts[5].startsWith('(') &&
        parts[5].endsWith(')')) {
      _complementController.text =
          parts[5].substring(1, parts[5].length - 1).trim();
    }
  }

  String _buildEnderecoCompleto() {
    final parts = <String>[];
    if (_streetController.text.trim().isNotEmpty) {
      parts.add(_streetController.text.trim());
      if (_numberController.text.trim().isNotEmpty) {
        parts.add('nº ${_numberController.text.trim()}');
      }
    }
    if (_neighborhoodController.text.trim().isNotEmpty) {
      parts.add(_neighborhoodController.text.trim());
    }
    if (_cityController.text.trim().isNotEmpty) {
      parts.add(_cityController.text.trim());
    }
    if (_stateController.text.trim().isNotEmpty) {
      parts.add(_stateController.text.trim());
    }
    if (_cepController.text.trim().isNotEmpty) {
      parts.add('CEP: ${_cepController.text.trim()}');
    }
    if (_complementController.text.trim().isNotEmpty) {
      parts.add('(${_complementController.text.trim()})');
    }
    return parts.join(', ');
  }

  Future<void> _saveAndNext() async {
    if (_medicoId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados do médico não carregados. Tente novamente.'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
      return;
    }

    final crmText = _crmController.text.trim();
    String? crmNum;
    String? ufCrm;
    if (crmText.isNotEmpty) {
      if (crmText.contains('/')) {
        final parts = crmText.split('/');
        crmNum = parts[0].trim();
        ufCrm = parts.length > 1 ? parts[1].trim() : 'A confirmar';
      } else {
        crmNum = crmText;
        ufCrm = 'A confirmar';
      }
    }

    setState(() => _isSaving = true);

    try {
      // Se o usuário escolheu uma nova foto, tentar upload e salvar em profiles (não bloqueia ir para etapa 2)
      if (_pickedImageFile != null && _userId != null) {
        try {
          final uploadResult =
              await _imageStorageService.uploadImage(_pickedImageFile!);
          if (uploadResult['success'] == true && uploadResult['url'] != null) {
            final imageUrl = uploadResult['url'] as String;
            final updateResult = await _apiService.put(
              'profiles',
              {'id': _userId!},
              {'foto_perfil_url': imageUrl},
            );
            if (updateResult['success'] == true && mounted) {
              setState(() {
                _profileFotoUrl = imageUrl;
                _pickedImageFile = null;
              });
            } else if (updateResult['success'] != true && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    updateResult['message'] as String? ??
                        'Erro ao salvar foto no perfil.',
                  ),
                  backgroundColor: const Color(0xFFD32F2F),
                ),
              );
            }
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  uploadResult['message'] as String? ?? 'Erro ao enviar foto.',
                ),
                backgroundColor: const Color(0xFFD32F2F),
              ),
            );
          }
        } catch (_) {
          // Falha na foto não impede seguir para etapa 2
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Foto não foi salva. Você pode alterá-la depois.'),
                backgroundColor: Color(0xFFD32F2F),
              ),
            );
          }
        }
      }

      final result = await _medicoService.updateMedico(
        _medicoId!,
        crm: crmNum,
        ufCrm: ufCrm,
        cpf: _cpfController.text.trim().isEmpty
            ? null
            : InputMasks.removeNonNumeric(_cpfController.text).trim(),
        especialidadeId: _selectedEspecialidadeId,
        tempoAtuacao: _selectedYearsOfExperience,
        enderecoCompleto:
            _buildEnderecoCompleto().isEmpty ? null : _buildEnderecoCompleto(),
      );

      if (!mounted) return;
      final success = result['success'] == true;
      if (success) {
        // Garantir navegação para etapa 2 no próximo frame
        await Future.delayed(Duration.zero);
        if (!mounted) return;
        context.go('/professional-validation/step2-documents');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? 'Erro ao salvar'),
            backgroundColor: const Color(0xFFD32F2F),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stack) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: const Color(0xFFD32F2F),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('Step1ProfessionalDataPage _saveAndNext error: $e\n$stack');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adicionar foto',
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 20, color: Color(0xFF212121)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF212121)),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF212121)),
              title: const Text('Escolher foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_pickedImageFile != null ||
                (_profileFotoUrl != null && _profileFotoUrl!.isNotEmpty))
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
                title: const Text(
                  'Remover foto atual',
                  style: TextStyle(
                      color: Color(0xFFD32F2F), fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null && mounted) {
        _showImageAdjustmentSheet(File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  /// Modal de ajuste de foto (Figma: preview circular, zoom -, Q, +, Cancelar, Adicionar)
  void _showImageAdjustmentSheet(File imageFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adicionar foto',
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Preview circular (Figma: imagem em círculo)
            ClipOval(
              child: SizedBox(
                width: 263,
                height: 263,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Controles de zoom (-, Q, +)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6E6E3),
                borderRadius: BorderRadius.circular(115),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F3F3D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      side: const BorderSide(color: Color(0xFFB8B8B5)),
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        color: const Color(0xFF7C7C79),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() => _pickedImageFile = imageFile);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.canfyGreen,
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Adicionar',
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto() {
    setState(() {
      _pickedImageFile = null;
    });
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _crmController.dispose();
    _yearsOfExperienceController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _cepController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    super.dispose();
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
              color: Color(0xFF33CC80), // green-500
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.white),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user-selection');
            }
          },
        ),
        title: Text(
          'Dados profissionais',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
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
                            onPressed: () => context.go('/user-selection'),
                            child: const Text('Voltar'),
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
                        // Barra de progresso
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BB5A), // green-700
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6D6D3), // neutral-300
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD6D6D3), // neutral-300
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Título e badges
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
                                    color:
                                        const Color(0xFFF0F0EE), // neutral-100
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Etapa 1 - Dados profissionais',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(
                                          0xFF3F3F3D), // neutral-800
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F8EF), // green-100
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Valor: R\$ 89,90',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color(0xFF007A3B), // green-900
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Card Dados de registro
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F5), // neutral-050
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Avatar (tirar foto ou galeria)
                              GestureDetector(
                                onTap: _showImagePickerSheet,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFE6F8EF),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.111,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: _pickedImageFile != null
                                          ? Image.file(
                                              _pickedImageFile!,
                                              fit: BoxFit.cover,
                                              width: 80,
                                              height: 80,
                                            )
                                          : _profileFotoUrl != null &&
                                                  _profileFotoUrl!.isNotEmpty
                                              ? Image.network(
                                                  _profileFotoUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 80,
                                                  height: 80,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                    Icons.person,
                                                    size: 40,
                                                    color: Color(0xFF00994B),
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Color(0xFF00994B),
                                                ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF33CC80),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFF3F4F6),
                                            width: 1.25,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Título "Dados de registro"
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Dados de registro',
                                  style: AppTextStyles.arimo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        const Color(0xFF3F3F3D), // neutral-800
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Campo CPF
                              _buildTextField(
                                controller: _cpfController,
                                label: 'CPF',
                                hint: 'Digite seu CPF',
                                inputFormatters: [InputMasks.cpf],
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 8),
                              // Campo CRM + UF
                              _buildTextField(
                                controller: _crmController,
                                label: 'CRM + UF',
                                hint: 'Ex: 123456/SP',
                                inputFormatters: [InputMasks.crmUf],
                                keyboardType: TextInputType.visiblePassword,
                              ),
                              const SizedBox(height: 8),
                              // Especialidade médica (dropdown da API)
                              _buildEspecialidadeDropdown(),
                              const SizedBox(height: 8),
                              // Tempo de atuação (dropdown)
                              _buildDropdownField(
                                label: 'Tempo de atuação',
                                hint: 'Selecione o tempo de atuação',
                                value: _selectedYearsOfExperience,
                                items: _tempoAtuacaoItems,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYearsOfExperience = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Card Endereço profissional
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F5), // neutral-050
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título "Endereço profissional"
                              Text(
                                'Endereço profissional',
                                style: AppTextStyles.arimo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3F3F3D), // neutral-800
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Subtítulo
                              Text(
                                'Endereço profissional',
                                style: AppTextStyles.arimo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9A9A97), // neutral-500
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Logradouro e Número
                              Row(
                                children: [
                                  Expanded(
                                    flex: 216,
                                    child: _buildTextField(
                                      controller: _streetController,
                                      label: 'Logradouro',
                                      hint: 'Ex: Rua rego freitas',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 86,
                                    child: _buildTextField(
                                      controller: _numberController,
                                      label: 'Número',
                                      hint: 'Ex: 452',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // CEP e Estado
                              Row(
                                children: [
                                  Expanded(
                                    flex: 216,
                                    child: _buildTextField(
                                      controller: _cepController,
                                      label: 'CEP',
                                      hint: 'Ex: 01240-001',
                                      inputFormatters: [InputMasks.cep],
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 86,
                                    child: _buildTextField(
                                      controller: _stateController,
                                      label: 'Estado',
                                      hint: 'Ex: SP',
                                      inputFormatters: [InputMasks.uf],
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Cidade
                              _buildTextField(
                                controller: _cityController,
                                label: 'Cidade',
                                hint: 'Ex: São Paulo',
                              ),
                              const SizedBox(height: 8),
                              // Bairro
                              _buildTextField(
                                controller: _neighborhoodController,
                                label: 'Bairro',
                                hint: 'Ex: Vila Madalena',
                              ),
                              const SizedBox(height: 8),
                              // Complemento
                              _buildTextField(
                                controller: _complementController,
                                label: 'Complemento',
                                hint: 'Ex: Apto 2006',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Botão Próximo
                        SizedBox(
                          width: double.infinity,
                          height: 49,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveAndNext,
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

  Widget _buildEspecialidadeDropdown() {
    final items = _especialidades
        .map((e) => e['nome'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    String? currentNome;
    if (_selectedEspecialidadeId != null) {
      final match = _especialidades
          .where((e) => e['id'] == _selectedEspecialidadeId)
          .toList();
      currentNome = match.isNotEmpty ? match[0]['nome'] as String? : null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especialidade médica',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F3F3D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD6D6D3)),
          ),
          child: DropdownButtonFormField<String>(
            value: currentNome,
            decoration: InputDecoration(
              hintText: 'Selecione sua especialidade',
              hintStyle: AppTextStyles.arimo(
                  fontSize: 14, color: const Color(0xFF7C7C79)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF7C7C79)),
            ),
            items: items.map((nome) {
              return DropdownMenuItem<String>(
                value: nome,
                child: Text(nome,
                    style:
                        AppTextStyles.arimo(fontSize: 14, color: Colors.black)),
              );
            }).toList(),
            onChanged: (nome) {
              if (nome == null) return;
              final match =
                  _especialidades.where((e) => e['nome'] == nome).toList();
              final id = match.isNotEmpty ? match[0]['id'] as String? : null;
              setState(() => _selectedEspecialidadeId = id);
            },
            style: AppTextStyles.arimo(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F3F3D), // neutral-800
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.arimo(
              fontSize: 14,
              color: const Color(0xFF7C7C79), // neutral-600
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(
                color: Color(0xFFD6D6D3), // neutral-300
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(
                color: Color(0xFFD6D6D3), // neutral-300
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(
                color: AppTheme.canfyGreen,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTextStyles.arimo(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3F3F3D), // neutral-800
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: const Color(0xFFD6D6D3), // neutral-300
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.arimo(
                fontSize: 14,
                color: const Color(0xFF7C7C79), // neutral-600
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF7C7C79),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
