import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/api_service.dart';
import '../../services/api/auth_service.dart';
import '../../services/api/medico_service.dart';
import '../../utils/input_masks.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

/// Cores do Figma - Dados básicos (médico)
class _BasicDataColors {
  static const Color appBarBg = Color(0xFFFFFFFF);
  static const Color appBarBorder = Color(0xFFD6D6D3);
  static const Color backButtonBg = Color(0xFFE6F8EF);
  static const Color cardBg = Color(0xFFF7F7F5);
  static const Color label = Color(0xFF5E5E5B);
  static const Color value = Color(0xFF212121);
  static const Color borderField = Color(0xFFE6E6E3);
  static const Color linkGreen = Color(0xFF00994B);
  static const Color linkRed = Color(0xFFD32F2F);
  static const Color docBorder = Color(0xFF33CC80);
  static const Color docIconBg = Color(0xFFE6F8EF);
  static const Color buttonPrimary = Color(0xFF00BB5A);
  static const Color buttonContent = Color(0xFFE6F8EF);
  static const Color avatarEditBg = Color(0xFF2B338A);
  static const Color avatarEditBorder = Color(0xFFF3F4F6);
}

class BasicDataPage extends StatefulWidget {
  const BasicDataPage({super.key});

  @override
  State<BasicDataPage> createState() => _BasicDataPageState();
}

class _BasicDataPageState extends State<BasicDataPage> {
  final ApiService _api = ApiService();
  final MedicoService _medicoService = MedicoService();
  final AuthService _authService = AuthService();

  // Controllers
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _crmController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();

  // Máscaras de input
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _dateMask = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );
  final _crmMask = MaskTextInputFormatter(
    mask: '######-??',
    filter: {
      "#": RegExp(r'[0-9]'),
      "?": RegExp(r'[A-Za-z]'),
    },
  );

  // Estado
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String _userName = '';
  String? _avatarUrl;
  String? _medicoId;
  String? _userId;
  List<Map<String, dynamic>> _documentos = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cpfController.dispose();
    _crmController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _api.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Usuário não autenticado';
        });
        return;
      }

      _userId = user.id;
      _emailController.text = user.email ?? '';

      // Buscar dados do profile
      final profileResult = await _api.getFiltered(
        'profiles',
        filters: {'id': user.id},
        limit: 1,
      );

      if (profileResult['success'] == true && profileResult['data'] != null) {
        final profiles = profileResult['data'] as List;
        if (profiles.isNotEmpty) {
          final profile = profiles[0] as Map<String, dynamic>;
          _userName = profile['nome_completo'] as String? ?? '';
          // Formata telefone com máscara
          final telefone = profile['telefone'] as String? ?? '';
          _phoneController.text = _formatPhoneForDisplay(telefone);

          // Avatar URL
          final avatarPath = profile['avatar_url'] as String? ??
              profile['foto_perfil_url'] as String?;
          if (avatarPath != null && avatarPath.trim().isNotEmpty) {
            if (avatarPath.startsWith('http')) {
              _avatarUrl = avatarPath;
            } else {
              try {
                _avatarUrl = Supabase.instance.client.storage
                    .from('avatars')
                    .getPublicUrl(avatarPath);
              } catch (_) {
                _avatarUrl = null;
              }
            }
          }
        }
      }

      // Buscar dados do médico
      final medicoResult = await _medicoService.getMedicoByCurrentUser();
      debugPrint('Medico result: $medicoResult');
      if (medicoResult['success'] == true && medicoResult['data'] != null) {
        final medico = medicoResult['data'] as Map<String, dynamic>;
        _medicoId = medico['id'] as String?;
        debugPrint('Medico ID carregado: $_medicoId');

        // Formata CPF com máscara
        final cpf = medico['cpf'] as String? ?? '';
        _cpfController.text = InputMasks.formatCpfForDisplay(cpf);

        // CRM + UF (formato: 123456-SP)
        final crm = medico['crm'] as String? ?? '';
        final ufCrm = medico['uf_crm'] as String? ?? '';
        _crmController.text =
            crm.isNotEmpty && ufCrm.isNotEmpty ? '$crm-$ufCrm' : crm;

        // Data de nascimento (se existir no médico ou profile)
        final dataNasc = medico['data_nascimento'] as String?;
        if (dataNasc != null && dataNasc.isNotEmpty) {
          _birthDateController.text = _formatDate(dataNasc);
        }

        // Endereço completo
        _regionController.text = medico['endereco_completo'] as String? ?? '';

        // Carregar documentos do médico
        if (_medicoId != null) {
          await _loadDocumentos(_medicoId!);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados: $e';
      });
    }
  }

  Future<void> _loadDocumentos(String medicoId) async {
    final result = await _medicoService.getMedicoDocumentos(medicoId);
    if (result['success'] == true && result['data'] != null) {
      final docsMap = result['data'] as Map<String, Map<String, dynamic>>;
      _documentos = docsMap.values.toList();
    }
  }

  /// Converte data ISO (YYYY-MM-DD) para formato brasileiro (DD/MM/YYYY).
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  /// Converte data brasileira (DD/MM/YYYY) para ISO (YYYY-MM-DD).
  String? _parseDate(String brDate) {
    try {
      final parts = brDate.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Formata telefone para exibição (10-11 dígitos -> (XX) XXXXX-XXXX).
  String _formatPhoneForDisplay(String? value) {
    if (value == null || value.isEmpty) return '';
    final d = InputMasks.removeNonNumeric(value);
    if (d.isEmpty) return '';
    if (d.length <= 2) return '($d';
    if (d.length <= 7) return '(${d.substring(0, 2)}) ${d.substring(2)}';
    if (d.length <= 11) {
      final ddd = d.substring(0, 2);
      final part1 = d.length == 11 ? d.substring(2, 7) : d.substring(2, 6);
      final part2 = d.length == 11 ? d.substring(7) : d.substring(6);
      return '($ddd) $part1-$part2';
    }
    return value;
  }

  Future<void> _saveData() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Remover máscara do telefone antes de salvar
      final telefoneRaw = InputMasks.removeNonNumeric(_phoneController.text);

      // Atualizar profile (telefone)
      if (_userId != null) {
        debugPrint('Salvando profile: userId=$_userId, telefone=$telefoneRaw');
        final profileResult = await _api.put('profiles', {
          'id': _userId
        }, {
          'telefone': telefoneRaw,
        });
        debugPrint('Profile update result: $profileResult');

        if (profileResult['success'] != true) {
          throw Exception(
              profileResult['message'] ?? 'Erro ao atualizar perfil');
        }
      }

      // Atualizar médico (CPF, CRM, endereço)
      if (_medicoId != null) {
        // Remover máscara do CPF
        final cpfRaw = InputMasks.removeNonNumeric(_cpfController.text);

        // Parse CRM+UF (formato: 123456-SP)
        String crm = _crmController.text.trim();
        String? ufCrm;
        if (crm.contains('-')) {
          final parts = crm.split('-');
          crm = parts[0].trim();
          ufCrm = parts.length > 1 ? parts[1].trim().toUpperCase() : null;
        }

        // Parse data de nascimento (DD/MM/YYYY -> YYYY-MM-DD)
        String? dataNascimento;
        final birthText = _birthDateController.text.trim();
        if (birthText.isNotEmpty) {
          dataNascimento = _parseDate(birthText);
        }

        final endereco = _regionController.text.trim();

        debugPrint(
            'Salvando médico: cpf=$cpfRaw, crm=$crm, uf=$ufCrm, data=$dataNascimento, endereco=$endereco');

        // Atualizar diretamente via API para garantir que os dados são enviados
        final updateData = <String, dynamic>{};
        if (cpfRaw.isNotEmpty) updateData['cpf'] = cpfRaw;
        if (crm.isNotEmpty) updateData['crm'] = crm;
        if (ufCrm != null && ufCrm.isNotEmpty) updateData['uf_crm'] = ufCrm;
        if (dataNascimento != null) {
          updateData['data_nascimento'] = dataNascimento;
        }
        if (endereco.isNotEmpty) updateData['endereco_completo'] = endereco;

        if (updateData.isNotEmpty) {
          final medicoResult =
              await _api.put('medicos', {'id': _medicoId}, updateData);
          debugPrint('Medico update result: $medicoResult');

          if (medicoResult['success'] != true) {
            throw Exception(
                medicoResult['message'] ?? 'Erro ao atualizar médico');
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: _BasicDataColors.buttonPrimary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao salvar dados: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: _BasicDataColors.linkRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sair',
              style: TextStyle(color: _BasicDataColors.linkRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Esta ação é irreversível. Todos os seus dados serão permanentemente excluídos. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: _BasicDataColors.linkRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Funcionalidade de exclusão de conta em desenvolvimento'),
        ),
      );
    }
  }

  Future<void> _deleteDocument(Map<String, dynamic> doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir documento'),
        content: Text('Deseja excluir "${doc['nome_arquivo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: _BasicDataColors.linkRed),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final docId = doc['id'] as String?;
      if (docId != null) {
        final result = await _medicoService.deleteMedicoDocumento(docId);
        if (result['success'] == true && mounted) {
          setState(() {
            _documentos.removeWhere((d) => d['id'] == docId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento excluído')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral000,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: const BoxDecoration(
            color: _BasicDataColors.appBarBg,
            border: Border(
              bottom: BorderSide(
                color: _BasicDataColors.appBarBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  // Botão voltar circular verde claro
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    child: Transform.rotate(
                      angle: 1.5708,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: _BasicDataColors.backButtonBg,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: _BasicDataColors.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Título centralizado
                  const Expanded(
                    child: Text(
                      'Dados básicos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _BasicDataColors.value,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Avatar do médico
                  const DoctorAppBarAvatar(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _userName.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: _BasicDataColors.linkRed),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style:
                              const TextStyle(color: _BasicDataColors.label)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header "Dados básicos"
                      SizedBox(
                        height: 33,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Dados básicos',
                            style: AppTextStyles.truculenta(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: _BasicDataColors.value,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Card de dados básicos
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _BasicDataColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto de perfil com ícone de edição
                            GestureDetector(
                              onTap: () {
                                // TODO: Implementar edição de foto
                              },
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 32,
                                    backgroundColor: AppColors.neutral300,
                                    backgroundImage: _avatarUrl != null
                                        ? NetworkImage(_avatarUrl!)
                                        : null,
                                    child: _avatarUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.neutral600,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _BasicDataColors.avatarEditBg,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              _BasicDataColors.avatarEditBorder,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Nome do usuário
                            Text(
                              _userName.isNotEmpty ? _userName : 'Usuário',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _BasicDataColors.value,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Campos de dados
                            _buildInfoRow('E-mail', _emailController,
                                readOnly: true),
                            const SizedBox(height: 8),
                            _buildInfoRow('Senha', null,
                                displayText: '********', readOnly: true),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              'CPF',
                              _cpfController,
                              inputFormatters: [_cpfMask],
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'CRM+UF',
                              _crmController,
                              inputFormatters: [_crmMask],
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Data de nascimento',
                              _birthDateController,
                              inputFormatters: [_dateMask],
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                              'Telefone',
                              _phoneController,
                              inputFormatters: [_phoneMask],
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Região', _regionController,
                                isMultiline: true),
                            const SizedBox(height: 24),
                            // Link Alterar senha
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _BasicDataColors.borderField,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Implementar alteração de senha
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Funcionalidade em desenvolvimento'),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Alterar senha',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _BasicDataColors.linkGreen,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Link Excluir conta
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: GestureDetector(
                                onTap: _showDeleteAccountDialog,
                                child: const Text(
                                  'Excluir conta e todos os dados na plataforma',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _BasicDataColors.linkRed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Card de Documentos
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: _BasicDataColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título Documentos
                            const Text(
                              'Documentos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _BasicDataColors.value,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Lista de documentos
                            if (_documentos.isEmpty)
                              const Text(
                                'Nenhum documento enviado',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _BasicDataColors.label,
                                ),
                              )
                            else
                              ..._documentos.map((doc) {
                                final nomeArquivo =
                                    doc['nome_arquivo'] as String? ??
                                        doc['tipo'] as String? ??
                                        'Documento';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildDocumentItem(nomeArquivo, doc),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botões de ação
                      _buildOutlineButton(
                        icon: Icons.exit_to_app,
                        label: 'Sair da conta',
                        onTap: _logout,
                      ),
                      const SizedBox(height: 8),
                      _buildPrimaryButton(
                        icon: Icons.check,
                        label: _isSaving ? 'Salvando...' : 'Salvar dados',
                        onTap: _isSaving ? () {} : _saveData,
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildInfoRow(
    String label,
    TextEditingController? controller, {
    bool isMultiline = false,
    bool readOnly = false,
    String? displayText,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 124,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: _BasicDataColors.label,
              height: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _BasicDataColors.borderField,
                  width: 1,
                ),
              ),
            ),
            child: controller != null
                ? TextField(
                    controller: controller,
                    maxLines: isMultiline ? 2 : 1,
                    readOnly: readOnly,
                    inputFormatters: inputFormatters,
                    keyboardType: keyboardType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: readOnly
                          ? _BasicDataColors.label
                          : _BasicDataColors.value,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    displayText ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: readOnly
                          ? _BasicDataColors.label
                          : _BasicDataColors.value,
                      height: 1.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String fileName, Map<String, dynamic> doc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _BasicDataColors.cardBg,
        border: Border.all(color: _BasicDataColors.docBorder),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDocIconButton(
            icon: Icons.edit_outlined,
            onTap: () {
              // TODO: Implementar edição de documento
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento')),
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _BasicDataColors.linkGreen,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          _buildDocIconButton(
            icon: Icons.delete_outline,
            onTap: () => _deleteDocument(doc),
          ),
        ],
      ),
    );
  }

  Widget _buildDocIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _BasicDataColors.docIconBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(
          icon,
          color: _BasicDataColors.linkGreen,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: _BasicDataColors.label,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _BasicDataColors.label,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _BasicDataColors.buttonPrimary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: _BasicDataColors.buttonContent,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _BasicDataColors.buttonContent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
