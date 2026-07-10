import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_tokens.dart';
import '../../services/api/api_service.dart';
import '../../services/api/auth_service.dart';
import '../../utils/input_masks.dart';
import '../../widgets/common/app_button.dart';

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
    // Validar formulário novamente antes de prosseguir
    _validateEmail();
    _validatePassword();

    // Verificar se o formulário está válido ANTES de fazer qualquer coisa
    final isValid = _isFormValid();

    if (!isValid) {
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

    setState(() {
      _isLoading = true;
      _hasError = false;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final email = _emailController.text.trim();
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

          if (tipoUsuario == 'medico' || tipoUsuario == 'prescritor') {
            // Médico: se status pendente_aprovacao, vai para fluxo de validação
            final user = data?['user'] as Map<String, dynamic>?;
            final userId = user?['id'] as String?;
            targetRoute = '/home';
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
                if (medico['status'] == 'pendente_aprovacao') {
                  targetRoute = '/professional-validation/status';
                }
              }
            }
          }

          // Usar addPostFrameCallback para redirecionar após o build atual
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go(targetRoute);
            }
          });
        } else {
          setState(() {
            _hasError = true;
            _emailError = 'E-mail incorreto';
            _passwordError = 'Senha incorreta';
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

  void _submit() {
    if (_isFormValid() && !_isLoading) {
      _handleLogin();
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTokens.neutral900),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spacingM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTokens.spacingXl),
                    Text(
                      'Bem-vindo de volta!',
                      style: AppTextStyles.truculenta(
                        fontSize: 40,
                        fontWeight: AppTokens.weightSemibold,
                        color: AppTokens.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spacingXs),
                    Text(
                      'Entre para continuar sua jornada.',
                      style: AppTextStyles.bodySm(color: AppTokens.neutral700),
                    ),
                    const SizedBox(height: AppTokens.spacingL),
                    _buildSegmentedTabs(),
                    const SizedBox(height: AppTokens.spacingL),
                    if (_isLoginTab) ...[
                      _inputField(
                        controller: _emailController,
                        label: 'E-mail ou telefone',
                        hint: 'Insira seu e-mail ou telefone',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        errorText:
                            _hasError && _emailError != null ? _emailError : null,
                      ),
                      const SizedBox(height: AppTokens.spacingM),
                      _inputField(
                        controller: _passwordController,
                        label: 'Senha',
                        hint: 'Insira sua senha',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        errorText: _hasError && _passwordError != null
                            ? _passwordError
                            : null,
                        trailing: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppTokens.neutral500,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: Text(
                            'Esqueceu sua senha?',
                            style: AppTextStyles.bodyXs(
                              color: AppTokens.orange900,
                              weight: AppTokens.weightMedium,
                            ),
                          ),
                        ),
                      ),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppTokens.spacingL),
                          child: Text(
                            'Redirecionando...',
                            style:
                                AppTextStyles.bodySm(color: AppTokens.neutral700),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isLoginTab) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTokens.green100,
        borderRadius: BorderRadius.circular(AppTokens.radius32),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppTokens.primary,
          borderRadius: BorderRadius.circular(AppTokens.radius32),
        ),
        labelColor: AppTokens.neutral000,
        unselectedLabelColor: AppTokens.neutral900,
        labelStyle: AppTextStyles.bodyMd(weight: AppTokens.weightSemibold),
        unselectedLabelStyle: AppTextStyles.bodyMd(),
        tabs: const [
          Tab(text: 'Cadastro'),
          Tab(text: 'Login'),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spacingM,
        AppTokens.spacingXs,
        AppTokens.spacingM,
        AppTokens.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            text: 'Entrar',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppTokens.spacingXs),
          TextButton(
            onPressed: () => context.go('/register'),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySm(
                  color: AppTokens.neutral900,
                  weight: AppTokens.weightSemibold,
                ),
                children: [
                  const TextSpan(text: 'Não tem uma conta? '),
                  TextSpan(
                    text: 'Crie agora',
                    style: AppTextStyles.bodySm(
                      color: AppTokens.primaryDark,
                      weight: AppTokens.weightSemibold,
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

  /// Campo de texto no estilo do protótipo: contorno "pill", ícone à esquerda.
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    String? errorText,
    Widget? trailing,
  }) {
    final bool hasError = errorText != null;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySm(
            color: AppTokens.neutral800,
            weight: AppTokens.weightSemibold,
          ),
        ),
        const SizedBox(height: AppTokens.spacingXs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: AppTextStyles.bodySm(color: AppTokens.neutral900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySm(color: AppTokens.neutral500),
            prefixIcon: Icon(icon,
                color: hasError
                    ? AppTokens.errorFieldBorder
                    : AppTokens.neutral600,
                size: 22),
            suffixIcon: trailing,
            filled: hasError,
            fillColor: AppTokens.errorFieldFill,
            isDense: true,
            border: border(AppTokens.neutral300),
            enabledBorder: border(
                hasError ? AppTokens.errorFieldBorder : AppTokens.neutral300),
            focusedBorder: border(
                hasError ? AppTokens.errorFieldBorder : AppTokens.primary, 2),
            errorText: errorText,
            errorStyle: AppTextStyles.bodyXs(
                color: AppTokens.errorFieldBorder,
                weight: AppTokens.weightSemibold),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTokens.spacingM,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
