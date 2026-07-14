import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../services/api/auth_service.dart';
import '../../services/api/asaas_service.dart';
import '../../utils/input_masks.dart';
import '../../utils/error_messages.dart';

class RegisterPage extends StatefulWidget {
  final String? userType;

  const RegisterPage({
    super.key,
    this.userType,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRegisterTab = true;

  // Controllers dos campos (cadastro) - conforme frame "1 Cadastro" do Figma
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controller do campo de e-mail usado na aba de Login (sempre e-mail real)
  final _loginEmailController = TextEditingController();

  // Máscaras
  final _cpfMask = InputMasks.cpf;
  final _dateMask = InputMasks.date;

  // Estados de visibilidade de senha
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Estados dos checkboxes
  bool _agreeTerms = false;
  bool _authorizeDataSharing = false;

  // Estados de validação
  String? _nameError;
  String? _emailOrPhoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _cpfError;
  String? _birthDateError;
  String? _loginEmailError;

  String? _selectedGender;
  bool _isDoctor = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final AsaasService _asaasService = AsaasService();
  final List<String> _genders = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não informar',
  ];

  @override
  void initState() {
    super.initState();
    _isDoctor = widget.userType == 'doctor';
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isRegisterTab = _tabController.index == 0;
        // Limpar erros apenas quando mudar para a tab de cadastro
        // Manter erros na tab de login para feedback ao usuário
        if (_tabController.index == 0) {
          _loginEmailError = null;
          _passwordError = null;
        }
      });
    });

    // Adicionar listeners para validação em tempo real
    _nameController.addListener(() => _validateName());
    _emailOrPhoneController.addListener(() => _validateEmailOrPhone());
    _passwordController.addListener(() => _validatePassword());
    _confirmPasswordController.addListener(() => _validateConfirmPassword());
    _cpfController.addListener(() => _validateCPF());
    _birthDateController.addListener(() => _validateBirthDate());
    _loginEmailController.addListener(() => _validateLoginEmail());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _loginEmailController.dispose();
    super.dispose();
  }

  // Validações em tempo real
  void _validateName() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Nome completo é obrigatório');
    } else if (_nameController.text.trim().split(' ').length < 2) {
      setState(() => _nameError = 'Digite seu nome completo');
    } else {
      setState(() => _nameError = null);
    }
  }

  /// Verifica se o texto informado se parece com um e-mail (contém "@")
  bool _looksLikeEmail(String value) => value.contains('@');

  /// Valida o campo unificado "E-mail ou telefone": aceita um e-mail válido
  /// ou um telefone brasileiro plausível (10-11 dígitos).
  void _validateEmailOrPhone() {
    final value = _emailOrPhoneController.text.trim();
    if (value.isEmpty) {
      setState(() => _emailOrPhoneError = 'E-mail ou telefone é obrigatório');
      return;
    }
    if (_looksLikeEmail(value)) {
      if (!InputMasks.isValidEmail(value)) {
        setState(() => _emailOrPhoneError = 'E-mail inválido');
      } else {
        setState(() => _emailOrPhoneError = null);
      }
    } else {
      final digits = InputMasks.removeNonNumeric(value);
      if (!InputMasks.isValidPhone(digits)) {
        setState(() => _emailOrPhoneError = 'Informe um e-mail ou telefone válido');
      } else {
        setState(() => _emailOrPhoneError = null);
      }
    }
  }

  void _validateLoginEmail() {
    if (_loginEmailController.text.trim().isEmpty) {
      setState(() => _loginEmailError = 'Email é obrigatório');
    } else if (!InputMasks.isValidEmail(_loginEmailController.text.trim())) {
      setState(() => _loginEmailError = 'Email inválido');
    } else {
      setState(() => _loginEmailError = null);
    }
  }

  void _validatePassword() {
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Senha é obrigatória');
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Senha deve ter no mínimo 6 caracteres');
    } else {
      setState(() => _passwordError = null);
      // Revalidar confirmação se já foi preenchida
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword();
      }
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = 'Confirme sua senha');
    } else if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'As senhas não coincidem');
    } else {
      setState(() => _confirmPasswordError = null);
    }
  }

  void _validateCPF() {
    final cpf = _cpfMask.getUnmaskedText();
    if (cpf.isEmpty) {
      setState(() => _cpfError = 'CPF é obrigatório');
    } else if (!InputMasks.isValidCPF(cpf)) {
      setState(() => _cpfError = 'CPF inválido');
    } else {
      setState(() => _cpfError = null);
    }
  }

  void _validateBirthDate() {
    if (_birthDateController.text.trim().isEmpty) {
      setState(() => _birthDateError = 'Data de nascimento é obrigatória');
    } else if (!InputMasks.isValidDate(_birthDateController.text.trim())) {
      setState(() => _birthDateError = 'Data inválida. Use DD/MM/AAAA');
    } else {
      setState(() => _birthDateError = null);
    }
  }

  /// Valida se o formulário de login está válido
  bool _isLoginFormValid() {
    return _loginEmailError == null &&
        _passwordError == null &&
        _loginEmailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  /// Método para fazer login
  Future<void> _handleLogin() async {
    // Validar formulário novamente antes de prosseguir
    _validateLoginEmail();
    _validatePassword();

    // Verificar se o formulário está válido ANTES de fazer qualquer coisa
    final isValid = _isLoginFormValid();

    if (!isValid) {
      setState(() {
        // Forçar exibição dos erros
        if (_loginEmailController.text.trim().isEmpty) {
          _loginEmailError = 'Email é obrigatório';
        }
        if (_passwordController.text.isEmpty) {
          _passwordError = 'Senha é obrigatória';
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _loginEmailController.text.trim();
      final password = _passwordController.text;

      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Verificar tipo de usuário e redirecionar
          final data = result['data'] as Map<String, dynamic>?;
          final profile = data?['profile'];

          // O profile pode ser um Map ou uma lista com um Map
          Map<String, dynamic>? profileMap;
          if (profile is Map<String, dynamic>) {
            profileMap = profile;
          } else if (profile is List && profile.isNotEmpty) {
            profileMap = profile[0] as Map<String, dynamic>?;
          }

          // O tipo_usuario vem como string do Supabase
          final tipoUsuario = profileMap?['tipo_usuario'] as String?;

          // Redirecionar baseado no tipo de usuário
          String targetRoute = '/patient/home';

          if (tipoUsuario != null) {
            if (tipoUsuario == 'paciente') {
              targetRoute = '/patient/home';
            } else if (tipoUsuario == 'medico' || tipoUsuario == 'prescritor') {
              // Médico: se status pendente_aprovacao, vai para fluxo de validação
              final user = data?['user'] as Map<String, dynamic>?;
              final userId = user?['id'] as String?;
              if (userId != null) {
                final medicoResult = await ApiService().getFiltered(
                  'medicos',
                  filters: {'user_id': userId},
                  limit: 1,
                );
                if (medicoResult['success'] == true &&
                    medicoResult['data'] != null &&
                    (medicoResult['data'] as List).isNotEmpty) {
                  final medico =
                      (medicoResult['data'] as List)[0] as Map<String, dynamic>;
                  final status = medico['status'] as String?;
                  if (status == 'pendente_aprovacao') {
                    targetRoute =
                        '/professional-validation/step1-professional-data';
                  } else {
                    targetRoute = '/home';
                  }
                } else {
                  targetRoute = '/home';
                }
              } else {
                targetRoute = '/home';
              }
            }
          }

          // Redirecionar
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              context.go(targetRoute);
            }
          });
        } else {
          final errorMessage = ErrorMessages.extractErrorMessage(result);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFD32F2F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = ErrorMessages.formatError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user-selection');
            }
          },
        ),
        title: Text(
          'Cadastro',
          style: AppTextStyles.truculenta(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                'Vamos começar?',
                style: AppTextStyles.truculenta(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Leva só alguns minutos.\nVocê pode atualizar seus dados depois.',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: const Color(0xFF5E5E5B),
                ),
              ),
              const SizedBox(height: 24),
              // Tabs Cadastro/Login
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8EF),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.canfyGreen,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  labelStyle: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  unselectedLabelStyle: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: const [
                    Tab(text: 'Cadastro'),
                    Tab(text: 'Login'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Campos do formulário
              if (_isRegisterTab) ...[
                _buildTextField(
                  key: const ValueKey('pac_cadastro_nome'),
                  controller: _nameController,
                  label: 'Nome Completo *',
                  hint: 'Digite seu nome completo',
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  key: const ValueKey('pac_cadastro_data_nascimento'),
                  controller: _birthDateController,
                  label: 'Data de nascimento *',
                  hint: 'DD/MM/AAAA',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_dateMask],
                  errorText: _birthDateError,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Sexo *',
                  value: _selectedGender,
                  items: _genders,
                  hint: 'Selecione o sexo',
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cpfController,
                  label: 'CPF *',
                  hint: '000.000.000-00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfMask],
                  errorText: _cpfError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _rgController,
                  label: 'RG',
                  hint: 'Digite seu RG',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  key: const ValueKey('pac_cadastro_email_telefone'),
                  controller: _emailOrPhoneController,
                  label: 'E-mail ou telefone *',
                  hint: 'Digite seu e-mail ou telefone',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailOrPhoneError,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  key: const ValueKey('pac_cadastro_senha'),
                  controller: _passwordController,
                  label: 'Criar senha *',
                  hint: 'Crie uma senha segura',
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  key: const ValueKey('pac_cadastro_confirmar_senha'),
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha *',
                  hint: 'Repita sua senha',
                  obscureText: _obscureConfirmPassword,
                  errorText: _confirmPasswordError,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Checkboxes
                _buildCheckbox(
                  key: const ValueKey('pac_cadastro_aceitar_termos'),
                  value: _agreeTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeTerms = value ?? false;
                    });
                  },
                  text: 'Concordo com os ',
                  linkText: 'termos de uso',
                  linkText2: ' e a ',
                  linkText3: 'política de privacidade',
                  onLinkTap: () {
                    // Navegar para termos
                  },
                ),
                const SizedBox(height: 16),
                _buildCheckbox(
                  key: const ValueKey('pac_cadastro_autorizar_compartilhamento'),
                  value: _authorizeDataSharing,
                  onChanged: (value) {
                    setState(() {
                      _authorizeDataSharing = value ?? false;
                    });
                  },
                  text:
                      'Autorizo o compartilhamento de dados com médicos e associações, quando necessário para meu tratamento.',
                ),
                const SizedBox(height: 32),
                // Botão Criar conta
                AppButton(
                  key: const ValueKey('pac_cadastro_submit'),
                  text: 'Criar conta',
                  isLoading: _isLoading,
                  onPressed: (_agreeTerms &&
                          _authorizeDataSharing &&
                          _isFormValid())
                      ? _handleRegister
                      : null,
                ),
              ] else ...[
                // Tela de Login dentro do RegisterPage
                _buildTextField(
                  controller: _loginEmailController,
                  label: 'E-mail',
                  hint: 'Insira seu e-mail',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _loginEmailError,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Insira sua senha',
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA64740),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Entrar',
                  isLoading: _isLoading,
                  onPressed: () {
                    if (_isLoginFormValid() && !_isLoading) {
                      _handleLogin();
                    } else {
                      _validateLoginEmail();
                      _validatePassword();
                      setState(() {
                        if (_loginEmailController.text.trim().isEmpty) {
                          _loginEmailError = 'Email é obrigatório';
                        }
                        if (_passwordController.text.isEmpty) {
                          _passwordError = 'Senha é obrigatória';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: 'Não tem uma conta? '),
                        TextSpan(
                          text: 'Crie agora',
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
            ],
          ),
        ),
      ),
    );
  }

  bool _isFormValid() {
    return _nameError == null &&
        _emailOrPhoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _cpfError == null &&
        _birthDateError == null &&
        _nameController.text.trim().isNotEmpty &&
        _emailOrPhoneController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _cpfMask.getUnmaskedText().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty &&
        _selectedGender != null;
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.arimo(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.arimo(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              borderSide: const BorderSide(color: AppTokens.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              borderSide: const BorderSide(color: AppTokens.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              borderSide: const BorderSide(color: AppTokens.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.arimo(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD32F2F),
            ),
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? errorText,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyles.arimo(
            fontSize: 16,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.arimo(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              borderSide: const BorderSide(color: AppTokens.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              borderSide: const BorderSide(color: AppTokens.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              borderSide: const BorderSide(color: AppTokens.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.arimo(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD32F2F),
            ),
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF9E9E9E),
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    Key? key,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    String? linkText,
    String? linkText2,
    String? linkText3,
    VoidCallback? onLinkTap,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.canfyGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: text),
                  if (linkText != null)
                    TextSpan(
                      text: linkText,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: Colors.blue,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: onLinkTap != null
                          ? (TapGestureRecognizer()..onTap = onLinkTap)
                          : null,
                    ),
                  if (linkText2 != null) TextSpan(text: linkText2),
                  if (linkText3 != null)
                    TextSpan(
                      text: linkText3,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: Colors.blue,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: onLinkTap != null
                          ? (TapGestureRecognizer()..onTap = onLinkTap)
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.arimo(
                fontSize: 16,
                color: const Color(0xFF9E9E9E),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Converte data de DD/MM/AAAA para DateTime
  DateTime? _parseBirthDate(String dateStr) {
    try {
      final numbers = InputMasks.removeNonNumeric(dateStr);
      if (numbers.length == 8) {
        final day = int.parse(numbers.substring(0, 2));
        final month = int.parse(numbers.substring(2, 4));
        final year = int.parse(numbers.substring(4, 8));
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Resolve o e-mail usado para autenticação no Supabase Auth a partir do
  /// campo unificado "E-mail ou telefone". Se o usuário digitou um e-mail,
  /// usamos ele diretamente. Se digitou um telefone, sintetizamos um e-mail
  /// de placeholder (o Supabase Auth exige um e-mail único para signUp) e
  /// guardamos o telefone real em profiles.telefone.
  String _resolveAuthEmail(String rawValue) {
    final trimmed = rawValue.trim();
    if (_looksLikeEmail(trimmed)) {
      return trimmed;
    }
    final digits = InputMasks.removeNonNumeric(trimmed);
    return '$digits@phone.canfy.local';
  }

  /// Retorna o telefone (somente dígitos) quando o campo unificado contém um
  /// telefone, ou null quando contém um e-mail.
  String? _resolvePhoneFromUnifiedField(String rawValue) {
    final trimmed = rawValue.trim();
    if (_looksLikeEmail(trimmed)) return null;
    final digits = InputMasks.removeNonNumeric(trimmed);
    return digits.isEmpty ? null : digits;
  }

  /// Processa o cadastro do paciente ou médico
  Future<void> _handleRegister() async {
    // Validar formulário novamente antes de enviar
    _validateName();
    _validateEmailOrPhone();
    _validatePassword();
    _validateConfirmPassword();
    _validateCPF();
    _validateBirthDate();

    if (!_isFormValid() || !_agreeTerms || !_authorizeDataSharing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Por favor, preencha todos os campos obrigatórios corretamente e aceite os termos de uso.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse da data de nascimento
      final birthDate = _parseBirthDate(_birthDateController.text.trim());
      if (birthDate == null) {
        throw Exception('Data de nascimento inválida');
      }

      // Obter valores sem máscara
      final cpf = _cpfMask.getUnmaskedText();
      final rg = _rgController.text.trim();
      final rawEmailOrPhone = _emailOrPhoneController.text;
      final authEmail = _resolveAuthEmail(rawEmailOrPhone);
      final phone = _resolvePhoneFromUnifiedField(rawEmailOrPhone);

      final result = _isDoctor
          ? await _authService.registerDoctor(
              name: _nameController.text.trim(),
              email: authEmail,
              password: _passwordController.text,
              phone: phone,
              cpf: cpf.isNotEmpty ? cpf : null,
              birthDate: birthDate,
              gender: _selectedGender,
              rg: rg.isNotEmpty ? rg : null,
            )
          : await _authService.registerPatient(
              name: _nameController.text.trim(),
              email: authEmail,
              password: _passwordController.text,
              phone: phone,
              cpf: cpf.isNotEmpty ? cpf : null,
              birthDate: birthDate,
              gender: _selectedGender,
              rg: rg.isNotEmpty ? rg : null,
              authorizeDataSharing: _authorizeDataSharing,
            );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          if (_isDoctor) {
            context.go('/professional-validation/step1-professional-data');
          } else {
            // Criar cliente no Asaas e salvar asaas_customer_id no profile (para pagamentos)
            final cpfFinal = _cpfMask.getUnmaskedText();
            await _asaasService.syncCustomer(
              name: _nameController.text.trim(),
              email: authEmail,
              mobilePhone: phone,
              cpfCnpj: cpfFinal.isNotEmpty ? cpfFinal : null,
            );
            context.go('/patient/home');
          }
        } else {
          final errorMessage = ErrorMessages.extractErrorMessage(result);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFD32F2F),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = ErrorMessages.formatError(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}
