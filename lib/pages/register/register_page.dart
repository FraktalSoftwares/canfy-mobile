import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/auth_service.dart';
import '../../services/api/cep_service.dart';
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

  // Controllers dos campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _crmController = TextEditingController();
  final _croController = TextEditingController();

  // Máscaras
  final _cpfMask = InputMasks.cpf;
  final _phoneMask = InputMasks.phone;
  final _dateMask = InputMasks.date;
  final _cepMask = InputMasks.cep;

  // Estados de visibilidade de senha
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Estados dos checkboxes
  bool _agreeTerms = false;
  bool _authorizeDataSharing = false;

  // Estados de validação
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _cpfError;
  String? _phoneError;
  String? _birthDateError;
  String? _cepError;

  String? _selectedGender;
  bool _isDoctor = false;
  bool _isLoading = false;
  bool _isLoadingCep = false;
  String? _lastSearchedCep;
  final AuthService _authService = AuthService();
  final CepService _cepService = CepService();
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
          _emailError = null;
          _passwordError = null;
        }
      });
    });

    // Adicionar listeners para validação em tempo real
    _nameController.addListener(() => _validateName());
    _emailController.addListener(() => _validateEmail());
    _passwordController.addListener(() => _validatePassword());
    _confirmPasswordController.addListener(() => _validateConfirmPassword());
    _cpfController.addListener(() => _validateCPF());
    _phoneController.addListener(() => _validatePhone());
    _birthDateController.addListener(() => _validateBirthDate());
    _cepController.addListener(() {
      _validateCEP();
      _handleCepSearch();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _crmController.dispose();
    _croController.dispose();
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

  void _validateEmail() {
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email é obrigatório');
    } else if (!InputMasks.isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Email inválido');
    } else {
      setState(() => _emailError = null);
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

  void _validatePhone() {
    final phone = _phoneMask.getUnmaskedText();
    if (phone.isEmpty) {
      setState(() => _phoneError = 'Telefone é obrigatório');
    } else if (!InputMasks.isValidPhone(phone)) {
      setState(() => _phoneError = 'Telefone inválido');
    } else {
      setState(() => _phoneError = null);
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

  void _validateCEP() {
    if (_cepController.text.isNotEmpty) {
      final cep = _cepMask.getUnmaskedText();
      if (!InputMasks.isValidCEP(cep)) {
        setState(() => _cepError = 'CEP inválido');
      } else {
        setState(() => _cepError = null);
      }
    } else {
      setState(() => _cepError = null);
    }
  }

  /// Valida se o formulário de login está válido
  bool _isLoginFormValid() {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  /// Método para fazer login
  Future<void> _handleLogin() async {
    print('=== INÍCIO DO LOGIN (RegisterPage) ===');
    print('Login - Email: ${_emailController.text.trim()}');
    print('Login - Senha preenchida: ${_passwordController.text.isNotEmpty}');

    // Validar formulário novamente antes de prosseguir
    _validateEmail();
    _validatePassword();

    // Verificar se o formulário está válido ANTES de fazer qualquer coisa
    final isValid = _isLoginFormValid();
    print('Login - Formulário válido após validação: $isValid');

    if (!isValid) {
      print('Login - Formulário inválido, abortando login');
      setState(() {
        // Forçar exibição dos erros
        if (_emailController.text.trim().isEmpty) {
          _emailError = 'Email é obrigatório';
        }
        if (_passwordController.text.isEmpty) {
          _passwordError = 'Senha é obrigatória';
        }
      });
      return;
    }

    print('Login - Formulário válido, iniciando autenticação...');
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      print('Login - Chamando AuthService.login...');
      final result = await _authService.login(
        email: email,
        password: password,
      );
      print('Login - Resultado recebido: success=${result['success']}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Verificar tipo de usuário e redirecionar
          final data = result['data'] as Map<String, dynamic>?;
          final profile = data?['profile'];

          // Debug: imprimir dados recebidos
          print('Login - Dados recebidos: $data');
          print('Login - Profile: $profile');

          // O profile pode ser um Map ou uma lista com um Map
          Map<String, dynamic>? profileMap;
          if (profile is Map<String, dynamic>) {
            profileMap = profile;
          } else if (profile is List && profile.isNotEmpty) {
            profileMap = profile[0] as Map<String, dynamic>?;
          }

          // O tipo_usuario vem como string do Supabase
          final tipoUsuario = profileMap?['tipo_usuario'] as String?;
          print('Login - Tipo usuário: $tipoUsuario');

          // Redirecionar baseado no tipo de usuário
          String targetRoute = '/patient/home';

          if (tipoUsuario != null) {
            if (tipoUsuario == 'paciente') {
              targetRoute = '/patient/home';
              print(
                  'Login - Usuário é paciente, redirecionando para /patient/home');
            } else if (tipoUsuario == 'medico' || tipoUsuario == 'prescritor') {
              targetRoute = '/home';
              print(
                  'Login - Usuário é médico/prescritor, redirecionando para /home');
            }
          }

          // Redirecionar
          print('Login - Executando redirecionamento para: $targetRoute');
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
          print('Login - Falha no login: ${result['message']}');
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
        print('Login - Exceção durante o login: ${e.toString()}');
      }
    }
  }

  /// Busca endereço pelo CEP quando o campo está completo
  Future<void> _handleCepSearch() async {
    final cep = _cepMask.getUnmaskedText();

    // Só busca se tiver 8 dígitos, não estiver carregando e for um CEP diferente do último buscado
    if (cep.length == 8 && !_isLoadingCep && cep != _lastSearchedCep) {
      setState(() {
        _isLoadingCep = true;
        _cepError = null;
        _lastSearchedCep = cep;
      });

      try {
        // Pequeno delay para evitar múltiplas chamadas
        await Future.delayed(const Duration(milliseconds: 300));

        final result = await _cepService.getAddressByCep(cep);

        if (mounted) {
          setState(() {
            _isLoadingCep = false;
          });

          if (result['success'] == true) {
            final data = result['data'] as Map<String, dynamic>;

            // Preencher campos automaticamente
            _addressController.text = data['logradouro'] as String? ?? '';
            _neighborhoodController.text = data['bairro'] as String? ?? '';
            _cityController.text = data['localidade'] as String? ?? '';
            _stateController.text = data['uf'] as String? ?? '';

            // Complemento pode vir da API, mas não sobrescreve se já tiver algo
            if (_complementController.text.isEmpty) {
              _complementController.text = data['complemento'] as String? ?? '';
            }

            // Limpar erro se houver
            setState(() => _cepError = null);
          } else {
            setState(() {
              final errorMsg =
                  result['message'] as String? ?? 'CEP não encontrado';
              _cepError = ErrorMessages.formatError(errorMsg);
              _lastSearchedCep = null; // Permite tentar novamente
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingCep = false;
            _cepError = ErrorMessages.formatError(e);
            _lastSearchedCep = null; // Permite tentar novamente
          });
        }
      }
    } else if (cep.length < 8) {
      // Resetar último CEP buscado se o usuário apagar
      _lastSearchedCep = null;
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
                  controller: _nameController,
                  label: 'Nome completo',
                  hint: 'Digite seu nome completo',
                  errorText: _nameError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Digite seu email',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Senha',
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
                  controller: _confirmPasswordController,
                  label: 'Confirmar senha',
                  hint: 'Repita sua senha',
                  obscureText: _obscureConfirmPassword,
                  errorText: _confirmPasswordError,
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _birthDateController,
                  label: 'Data de nascimento',
                  hint: 'DD/MM/AAAA',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_dateMask],
                  errorText: _birthDateError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cpfController,
                  label: 'CPF',
                  hint: '000.000.000-00',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfMask],
                  errorText: _cpfError,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Telefone',
                  hint: '(00) 00000-0000',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_phoneMask],
                  errorText: _phoneError,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Gênero',
                  value: _selectedGender,
                  items: _genders,
                  hint: 'Selecione seu gênero',
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildCepField(
                  controller: _cepController,
                  label: 'CEP',
                  hint: '00000-000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepMask],
                  errorText: _cepError,
                  isLoading: _isLoadingCep,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Endereço',
                  hint: 'Digite seu endereço',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _numberController,
                  label: 'Número',
                  hint: 'Digite o número',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _complementController,
                  label: 'Complemento',
                  hint: 'Digite o complemento (opcional)',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _neighborhoodController,
                  label: 'Bairro',
                  hint: 'Digite o bairro',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityController,
                  label: 'Cidade',
                  hint: 'Digite a cidade',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _stateController,
                  label: 'Estado',
                  hint: 'Digite o estado',
                ),
                if (_isDoctor) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _crmController,
                    label: 'CRM',
                    hint: 'Digite seu CRM',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _croController,
                    label: 'CRO',
                    hint: 'Digite seu CRO',
                  ),
                ],
                const SizedBox(height: 24),
                // Checkboxes
                _buildCheckbox(
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
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: (_agreeTerms && !_isLoading && _isFormValid())
                        ? _handleRegister
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.canfyGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Criar conta',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // Tela de Login dentro do RegisterPage
                _buildTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'Insira seu e-mail',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
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
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      // Verificar novamente antes de chamar
                      if (_isLoginFormValid() && !_isLoading) {
                        _handleLogin();
                      } else {
                        print(
                            'Login - Botão clicado mas formulário inválido ou carregando');
                        // Forçar validação e mostrar erros
                        _validateEmail();
                        _validatePassword();
                        setState(() {
                          if (_emailController.text.trim().isEmpty) {
                            _emailError = 'Email é obrigatório';
                          }
                          if (_passwordController.text.isEmpty) {
                            _passwordError = 'Senha é obrigatória';
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_isLoginFormValid() && !_isLoading)
                          ? AppTheme.canfyGreen
                          : const Color(0xFFE0E0E0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Entrar',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                  ),
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
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _cpfError == null &&
        _phoneError == null &&
        _birthDateError == null &&
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _cpfMask.getUnmaskedText().isNotEmpty &&
        _phoneMask.getUnmaskedText().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
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
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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

  Widget _buildCepField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    required bool isLoading,
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
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
            suffixIcon: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.canfyGreen),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? errorText,
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
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    String? linkText,
    String? linkText2,
    String? linkText3,
    VoidCallback? onLinkTap,
  }) {
    return Row(
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

  /// Processa o cadastro do paciente
  Future<void> _handleRegister() async {
    // Validar formulário novamente antes de enviar
    _validateName();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();
    _validateCPF();
    _validatePhone();
    _validateBirthDate();

    if (!_isFormValid() || !_agreeTerms) {
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
      final phone = _phoneMask.getUnmaskedText();

      // Validar que CPF não está vazio (já validado antes, mas garantir)
      if (cpf.isEmpty) {
        throw Exception('CPF é obrigatório');
      }

      // Chamar serviço de cadastro
      final result = await _authService.registerPatient(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: phone.isNotEmpty ? phone : null,
        cpf: cpf,
        birthDate: birthDate,
        gender: _selectedGender,
        cep: _cepMask.getUnmaskedText().isEmpty
            ? null
            : _cepMask.getUnmaskedText(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        addressNumber: _numberController.text.trim().isEmpty
            ? null
            : _numberController.text.trim(),
        complement: _complementController.text.trim().isEmpty
            ? null
            : _complementController.text.trim(),
        neighborhood: _neighborhoodController.text.trim().isEmpty
            ? null
            : _neighborhoodController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        authorizeDataSharing: _authorizeDataSharing,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Navegar para home do paciente (usuário já está logado após cadastro)
          context.go('/patient/home');
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
