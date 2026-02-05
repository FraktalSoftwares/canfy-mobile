import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api/api_service.dart';
import '../../services/api/auth_service.dart';
import '../../utils/input_masks.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasError = false;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  bool _isLoginTab = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 1); // Login tab selecionada por padrão
    _tabController.addListener(() {
      setState(() {
        _isLoginTab = _tabController.index == 1;
        _hasError = false;
        _emailError = null;
        _passwordError = null;
      });
      // Se tab Cadastro foi selecionada, navegar para register
      if (_tabController.index == 0) {
        Future.microtask(() {
          if (mounted) {
            context.go('/register');
          }
        });
      }
    });

    // Adicionar listeners para validação em tempo real
    _emailController.addListener(() => _validateEmail());
    _passwordController.addListener(() => _validatePassword());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email é obrigatório');
    } else if (!InputMasks.isValidEmail(email)) {
      setState(() => _emailError = 'Email inválido');
    } else {
      setState(() => _emailError = null);
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Senha é obrigatória');
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Senha deve ter no mínimo 6 caracteres');
    } else {
      setState(() => _passwordError = null);
    }
  }

  bool _isFormValid() {
    return _emailError == null &&
        _passwordError == null &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    print('=== INÍCIO DO LOGIN ===');
    print('Login - Email: ${_emailController.text.trim()}');
    print('Login - Senha preenchida: ${_passwordController.text.isNotEmpty}');
    print('Login - _isFormValid(): ${_isFormValid()}');
    print('Login - _emailError: $_emailError');
    print('Login - _passwordError: $_passwordError');

    // Validar formulário novamente antes de prosseguir
    _validateEmail();
    _validatePassword();

    // Verificar se o formulário está válido ANTES de fazer qualquer coisa
    final isValid = _isFormValid();
    print('Login - Formulário válido após validação: $isValid');

    if (!isValid) {
      print('Login - Formulário inválido, abortando login');
      setState(() {
        _hasError = true;
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
      _hasError = false;
      _emailError = null;
      _passwordError = null;
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
          print('Login - Tipo do profile: ${profile.runtimeType}');

          // O profile pode ser um Map ou uma lista com um Map
          Map<String, dynamic>? profileMap;
          if (profile is Map<String, dynamic>) {
            profileMap = profile;
            print('Login - Profile é Map');
          } else if (profile is List) {
            print('Login - Profile é List com ${profile.length} itens');
            if (profile.isNotEmpty) {
              profileMap = profile[0] as Map<String, dynamic>?;
            }
          } else if (profile != null) {
            print(
                'Login - Profile é de tipo desconhecido: ${profile.runtimeType}');
          }

          // O tipo_usuario vem como string do Supabase
          final tipoUsuario = profileMap?['tipo_usuario'] as String?;
          print('Login - Tipo usuário: $tipoUsuario');
          print('Login - Profile completo: $profileMap');

          // Redirecionar baseado no tipo de usuário
          String targetRoute = '/patient/home';

          if (tipoUsuario != null) {
            if (tipoUsuario == 'paciente') {
              targetRoute = '/patient/home';
              print(
                  'Login - Usuário é paciente, redirecionando para /patient/home');
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
                    print(
                        'Login - Médico pendente de aprovação, redirecionando para validação');
                  } else {
                    targetRoute = '/home';
                    print(
                        'Login - Usuário é médico/prescritor, redirecionando para /home');
                  }
                } else {
                  targetRoute = '/home';
                }
              } else {
                targetRoute = '/home';
              }
            } else {
              print(
                  'Login - Tipo desconhecido ($tipoUsuario), usando fallback para /patient/home');
            }
          } else {
            print(
                'Login - Tipo usuário não encontrado, usando fallback para /patient/home');
          }

          // Redirecionar imediatamente após o frame atual
          print('Login - Preparando redirecionamento para: $targetRoute');

          // Usar SchedulerBinding para garantir que o redirecionamento aconteça após o build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              print('Login - Executando redirecionamento para: $targetRoute');
              try {
                // Usar go() que substitui a rota atual
                context.go(targetRoute);
                print(
                    'Login - Redirecionamento para $targetRoute executado com sucesso');
              } catch (e, stackTrace) {
                print('Login - Erro ao redirecionar: $e');
                print('Login - Stack trace: $stackTrace');
                // Se falhar, tentar novamente após um delay
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    print(
                        'Login - Tentando redirecionamento novamente para: $targetRoute');
                    try {
                      context.go(targetRoute);
                    } catch (e2) {
                      print('Login - Erro na segunda tentativa: $e2');
                    }
                  }
                });
              }
            } else {
              print('Login - Widget não está mais montado no callback');
            }
          });
        } else {
          setState(() {
            _hasError = true;
            _emailError = null;
            _passwordError =
                result['message'] as String? ?? 'Erro ao fazer login';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erro ao fazer login'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _passwordError = 'Erro ao fazer login: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Título
              Text(
                'Bem-vindo de volta!',
                style: AppTextStyles.truculenta(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entre para continuar sua jornada.',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  color: const Color(0xFF5E5E5B),
                ),
              ),
              const SizedBox(height: 24),
              // Tabs Cadastro/Login
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8EF), // green-100
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
              const SizedBox(height: 24),
              // Conteúdo baseado na tab selecionada
              if (_isLoginTab) ...[
                // Campo Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Insira seu e-mail ou telefone',
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  hasError: _hasError && _emailError != null,
                ),
                const SizedBox(height: 16),
                // Campo Senha
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Insira sua senha',
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  hasError: _hasError && _passwordError != null,
                  onToggleVisibility: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Link Esqueceu a senha
                TextButton(
                  onPressed: () {
                    context.go('/forgot-password');
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA64740), // orange-900
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Entrar
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      // Verificar novamente antes de chamar
                      if (_isFormValid() && !_isLoading) {
                        _handleLogin();
                      } else {
                        print(
                            'Login - Botão clicado mas formulário inválido ou carregando');
                        // Forçar validação e mostrar erros
                        _validateEmail();
                        _validatePassword();
                        setState(() {
                          _hasError = true;
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
                // Botão Criar conta
                TextButton(
                  onPressed: () {
                    context.go('/register');
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
              ] else ...[
                // Quando tab Cadastro está selecionada, navegar para register
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Redirecionando...',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: Colors.black,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? errorText,
    bool hasError = false,
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
            fillColor:
                hasError ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.canfyGreen,
                width: 2,
              ),
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.arimo(
              fontSize: 12,
              color: Colors.red,
            ),
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
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? errorText,
    bool hasError = false,
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
            fillColor:
                hasError ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Colors.red, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.canfyGreen,
                width: 2,
              ),
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.arimo(
              fontSize: 12,
              color: Colors.red,
            ),
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
}
