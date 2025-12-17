import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _hasError = false;
  String? _emailError;
  String? _passwordError;

  bool _isLoginTab = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1); // Login tab selecionada por padrão
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validação simples
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _hasError = true;
        _emailError = 'Email inválido';
      });
      return;
    }

    if (password.isEmpty || password.length < 6) {
      setState(() {
        _hasError = true;
        _passwordError = 'Senha incorreta';
      });
      return;
    }

    // Login bem-sucedido
    context.go('/user-selection');
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
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.canfyGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
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
            fillColor: hasError ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
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
            fillColor: hasError ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
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

