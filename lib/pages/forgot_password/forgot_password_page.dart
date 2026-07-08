import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/api_service.dart';
import '../../utils/input_masks.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
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

  Future<void> _handleSendResetEmail() async {
    _validateEmail();
    
    if (_emailError != null || _emailController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      final email = _emailController.text.trim();
      final result = await _apiService.resetPasswordForEmail(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Navegar para tela de confirmação
          context.go('/forgot-password/email-sent');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erro ao enviar email de recuperação'),
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
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: AppTokens.green100,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppTokens.neutral900, size: 20),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
            ),
          ),
        ),
        title: Text(
          'Recuperação de senha',
          style: AppTextStyles.bodySm(
            color: AppTokens.neutral900,
            weight: AppTokens.weightSemibold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Recuperação de senha',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900),
              ),
              const SizedBox(height: AppTokens.spacingXs),
              Text(
                'Digite seu e-mail e enviaremos um link para redefinir sua senha.',
                style: AppTextStyles.bodySm(color: AppTokens.neutral600),
              ),
              const SizedBox(height: AppTokens.spacingXl),
              AppTextField(
                controller: _emailController,
                label: 'E-mail ou telefone',
                hint: 'Insira seu e-mail ou telefone',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: AppTokens.spacingXl),
              AppButton(
                text: 'Enviar link de recuperação',
                isLoading: _isLoading,
                onPressed:
                    _emailError != null ? null : _handleSendResetEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

