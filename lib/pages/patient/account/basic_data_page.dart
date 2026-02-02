import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../services/api/patient_service.dart';
import '../../../services/api/api_service.dart';
import '../../../services/storage/image_storage_service.dart';
import '../../../utils/input_masks.dart';
import '../../../core/theme/text_styles.dart';

class PatientBasicDataPage extends StatefulWidget {
  const PatientBasicDataPage({super.key});

  @override
  State<PatientBasicDataPage> createState() => _PatientBasicDataPageState();
}

class _PatientBasicDataPageState extends State<PatientBasicDataPage> {
  final PatientService _patientService = PatientService();
  final ApiService _apiService = ApiService();
  final ImageStorageService _imageStorageService = ImageStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Máscaras
  final _cpfMask = InputMasks.cpf;
  final _phoneMask = InputMasks.phone;
  final _dateMask = InputMasks.date;

  // Estados
  bool _isLoading = true;
  bool _isSaving = false;
  String? _patientAvatar;
  String? _patientId;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>?;
        final profile = data?['profile'] as Map<String, dynamic>?;
        final paciente = data?['paciente'] as Map<String, dynamic>?;

        if (profile != null) {
          _userId = profile['id'] as String?;
          _nameController.text = profile['nome_completo'] as String? ?? '';

          // Formatar telefone se existir
          final phone = profile['telefone'] as String? ?? '';
          if (phone.isNotEmpty) {
            final phoneNumbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
            if (phoneNumbers.length == 10 || phoneNumbers.length == 11) {
              if (phoneNumbers.length == 10) {
                _phoneController.text =
                    '(${phoneNumbers.substring(0, 2)}) ${phoneNumbers.substring(2, 6)}-${phoneNumbers.substring(6, 10)}';
              } else {
                _phoneController.text =
                    '(${phoneNumbers.substring(0, 2)}) ${phoneNumbers.substring(2, 7)}-${phoneNumbers.substring(7, 11)}';
              }
            } else {
              _phoneController.text = phone;
            }
          }

          _patientAvatar = profile['foto_perfil_url'] as String?;

          // Buscar email do auth.users
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            _emailController.text = user.email ?? '';
          }
        }

        if (paciente != null) {
          _patientId = paciente['id'] as String?;

          // CPF
          final cpf = paciente['cpf'] as String? ?? '';
          if (cpf.isNotEmpty) {
            // Aplicar máscara manualmente
            final cpfNumbers = cpf.replaceAll(RegExp(r'[^0-9]'), '');
            if (cpfNumbers.length == 11) {
              _cpfController.text =
                  '${cpfNumbers.substring(0, 3)}.${cpfNumbers.substring(3, 6)}.${cpfNumbers.substring(6, 9)}-${cpfNumbers.substring(9, 11)}';
            } else {
              _cpfController.text = cpf;
            }
          }

          // Data de nascimento
          final birthDate = paciente['data_nascimento'] as String?;
          if (birthDate != null && birthDate.isNotEmpty) {
            try {
              final date = DateTime.parse(birthDate);
              _birthDateController.text =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
            } catch (e) {
              // Ignorar erro de parsing
            }
          }

          // Endereço
          _addressController.text =
              paciente['endereco_completo'] as String? ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveData() async {
    setState(() {
      _isSaving = true;
    });

    try {
      if (_userId == null) {
        throw Exception('ID do usuário não encontrado');
      }

      // Atualizar profile
      final profileUpdate = {
        'nome_completo': _nameController.text.trim(),
        if (_phoneController.text.isNotEmpty)
          'telefone': _phoneMask.getUnmaskedText(),
      };

      final profileResult = await _apiService.put(
        'profiles',
        {'id': _userId!},
        profileUpdate,
      );

      if (!profileResult['success']) {
        throw Exception(profileResult['message'] ?? 'Erro ao atualizar perfil');
      }

      // Atualizar dados do paciente
      if (_patientId != null) {
        final cpf = _cpfMask.getUnmaskedText();
        if (cpf.isEmpty) {
          throw Exception('CPF é obrigatório');
        }

        // Parse da data de nascimento
        final birthDateStr = _dateMask.getUnmaskedText();
        if (birthDateStr.length != 8) {
          throw Exception('Data de nascimento inválida');
        }

        final day = int.parse(birthDateStr.substring(0, 2));
        final month = int.parse(birthDateStr.substring(2, 4));
        final year = int.parse(birthDateStr.substring(4, 8));
        final birthDate = DateTime(year, month, day);

        final pacienteUpdate = {
          'cpf': cpf,
          'data_nascimento': birthDate.toIso8601String().split('T')[0],
          if (_addressController.text.trim().isNotEmpty)
            'endereco_completo': _addressController.text.trim(),
        };

        final pacienteResult = await _apiService.put(
          'pacientes',
          {'id': _patientId!},
          pacienteUpdate,
        );

        if (!pacienteResult['success']) {
          throw Exception(pacienteResult['message'] ??
              'Erro ao atualizar dados do paciente');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Widget _buildFieldRow(String label, Widget value) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE6E6E3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5E5E5B),
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: PatientAppBar(
          title: 'Meus dados',
          fallbackRoute: '/patient/account',
          avatarTappable: false,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Meus dados',
        fallbackRoute: '/patient/account',
        avatarUrl: _patientAvatar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados básicos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 24),
            // Card de dados básicos
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto de perfil
                  GestureDetector(
                    onTap: () {
                      _showImagePickerSheet();
                    },
                    child: Stack(
                      children: [
                        _patientAvatar != null && _patientAvatar!.isNotEmpty
                            ? CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: NetworkImage(_patientAvatar!),
                                onBackgroundImageError: (_, __) {},
                              )
                            : CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.grey[300],
                                child: const Icon(Icons.person, size: 40),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF43439D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF8F8F8),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : 'Usuário',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Campos editáveis
                  _buildFieldRow(
                    'Nome',
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'E-mail',
                    TextField(
                      controller: _emailController,
                      readOnly: true, // Email não pode ser alterado aqui
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C7C79),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                        hintText: 'Altere no email do sistema',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Telefone',
                    TextField(
                      controller: _phoneController,
                      inputFormatters: [_phoneMask],
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFieldRow(
                    'CPF',
                    TextField(
                      controller: _cpfController,
                      inputFormatters: [_cpfMask],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Data de nascimento',
                    TextField(
                      controller: _birthDateController,
                      inputFormatters: [_dateMask],
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                        hintText: 'DD/MM/AAAA',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFieldRow(
                    'Endereço',
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF212121),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Link para alterar senha
                  GestureDetector(
                    onTap: () {
                      context.push('/forgot-password/reset');
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE6E6E3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Alterar senha',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF00994B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Link para excluir conta
                  GestureDetector(
                    onTap: () {
                      _showDeleteAccountSheet();
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE6E6E3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Excluir conta e todos os dados na plataforma',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botão Sair da conta
            OutlinedButton.icon(
              onPressed: () {
                _showLogoutSheet();
              },
              icon: const Icon(Icons.exit_to_app, size: 16),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                side: const BorderSide(color: Color(0xFF7C7C79)),
              ),
            ),
            const SizedBox(height: 8),
            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveData,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 16),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar dados'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00994B),
                minimumSize: const Size(double.infinity, 49),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra o sheet de confirmação para sair da conta
  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Deseja sair da conta?',
                    style: AppTextStyles.truculenta(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Você poderá entrar novamente a qualquer momento usando seu e-mail ou telefone',
              style: AppTextStyles.arimo(
                fontSize: 14,
                color: const Color(0xFF5E5E5B),
              ),
            ),
            const SizedBox(height: 32),
            // Botões
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
                    onPressed: () async {
                      // 1. Fazer logout do Supabase
                      try {
                        await _apiService.signOut();
                      } catch (e) {
                        // Se houver erro no logout, ainda continuar com o processo
                        print('Erro ao fazer logout: $e');
                      }

                      // 2. Recarregar o app redirecionando para splash
                      // O sheet vai fechar automaticamente ao mudar de rota
                      if (mounted) {
                        context.go('/splash');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E5E5B),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Sair da conta',
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

  /// Mostra o sheet de confirmação para excluir conta
  void _showDeleteAccountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com título e botão fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Excluir conta permanentemente',
                    style: AppTextStyles.truculenta(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: const Color(0xFF5E5E5B),
                ),
                children: [
                  TextSpan(
                    text: 'Essa ação não pode ser desfeita. ',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF5E5E5B),
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Todos os seus dados serão apagados '),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'da plataforma de forma permanente.'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Botões
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
                    onPressed: () async {
                      // Fechar o sheet primeiro e aguardar o fechamento
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                        // Aguardar o sheet fechar completamente
                        await Future.delayed(const Duration(milliseconds: 200));
                      }

                      // Verificar se ainda está montado antes de continuar
                      if (!mounted) return;

                      // Executar exclusão
                      await _deleteAccount();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      minimumSize: const Size(0, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      'Excluir conta',
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

  /// Deleta a conta do usuário
  Future<void> _deleteAccount() async {
    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // 1. Deletar preferências de notificações (se existir)
      if (_userId != null) {
        try {
          final prefsResult = await _apiService
              .delete('preferencias_notificacoes', {'user_id': _userId!});
          if (prefsResult['success']) {
            print('Preferências de notificações deletadas com sucesso');
          }
        } catch (e) {
          print('Aviso: Erro ao deletar preferências de notificações: $e');
          // Continuar mesmo se falhar
        }
      }

      // 2. Deletar dados do paciente primeiro (se existir)
      if (_patientId != null) {
        final pacienteResult =
            await _apiService.delete('pacientes', {'id': _patientId!});
        if (!pacienteResult['success']) {
          throw Exception(
              'Erro ao deletar dados do paciente: ${pacienteResult['message']}');
        }
        print('Paciente deletado com sucesso');
      }

      // 3. Deletar profile
      if (_userId != null) {
        final profileResult =
            await _apiService.delete('profiles', {'id': _userId!});
        if (!profileResult['success']) {
          throw Exception(
              'Erro ao deletar perfil: ${profileResult['message']}');
        }
        print('Profile deletado com sucesso');
      }

      // 4. Deletar usuário do auth.users usando Edge Function
      final deleteUserResult = await _apiService.deleteUserAccount();
      if (!deleteUserResult['success']) {
        throw Exception(
            'Erro ao deletar conta do usuário: ${deleteUserResult['message']}');
      }
      print('Usuário deletado do auth.users com sucesso');

      // 5. Fazer logout (mesmo que o usuário já tenha sido deletado, é bom limpar a sessão local)
      await _apiService.signOut();
      print('Logout realizado com sucesso');

      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
        // Recarregar o app redirecionando para splash
        // O sheet vai fechar automaticamente ao mudar de rota
        context.go('/splash');
      }
    } catch (e) {
      print('Erro ao excluir conta: $e');
      if (mounted) {
        // Tentar fechar o loading se ainda estiver aberto
        try {
          Navigator.pop(context);
        } catch (_) {
          // Ignorar se não houver dialog para fechar
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Mostra o sheet para selecionar a origem da imagem (câmera ou galeria)
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
            Text(
              'Selecionar foto',
              style: AppTextStyles.arimo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF212121),
              ),
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
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_patientAvatar != null && _patientAvatar!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                title: const Text(
                  'Remover foto',
                  style: TextStyle(color: Color(0xFFD32F2F)),
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

  /// Seleciona uma imagem da câmera ou galeria
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        _showImageAdjustmentSheet(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mostra o sheet de ajuste de foto conforme o design do Figma
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
            // Header
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
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Preview da imagem
            Container(
              height: 263,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Controles de zoom (simplificado - apenas visual)
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
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
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
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Botões
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
                    onPressed: () async {
                      Navigator.pop(context);
                      await _uploadImage(imageFile);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00994B),
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

  /// Faz upload da imagem e atualiza o perfil
  Future<void> _uploadImage(File imageFile) async {
    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Fazer upload da imagem
      final uploadResult = await _imageStorageService.uploadImage(imageFile);

      if (!uploadResult['success'] || uploadResult['url'] == null) {
        throw Exception(
            uploadResult['message'] ?? 'Erro ao fazer upload da imagem');
      }

      final imageUrl = uploadResult['url'] as String;

      // Atualizar o profile com a URL da imagem
      if (_userId != null) {
        final updateResult = await _apiService.put(
          'profiles',
          {'id': _userId!},
          {'foto_perfil_url': imageUrl},
        );

        if (!updateResult['success']) {
          throw Exception(
              updateResult['message'] ?? 'Erro ao atualizar foto de perfil');
        }

        // Atualizar o estado local
        setState(() {
          _patientAvatar = imageUrl;
        });

        if (mounted) {
          Navigator.pop(context); // Fechar loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Remove a foto do perfil
  Future<void> _removePhoto() async {
    // Mostrar confirmação
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto'),
        content:
            const Text('Tem certeza que deseja remover sua foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover',
                style: TextStyle(color: Color(0xFFD32F2F))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Mostrar loading
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // Atualizar o profile removendo a URL da imagem
      if (_userId != null) {
        final updateResult = await _apiService.put(
          'profiles',
          {'id': _userId!},
          {'foto_perfil_url': null},
        );

        if (!updateResult['success']) {
          throw Exception(
              updateResult['message'] ?? 'Erro ao remover foto de perfil');
        }

        // Atualizar o estado local
        setState(() {
          _patientAvatar = null;
        });

        if (mounted) {
          Navigator.pop(context); // Fechar loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto removida com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
