import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _hasError = false;
  String? _confirmPasswordError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _newPasswordController.text;
    if (password.isEmpty) {
      setState(() => _passwordError = 'Senha é obrigatória');
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Senha deve ter no mínimo 6 caracteres');
    } else {
      setState(() => _passwordError = null);
    }
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    final password = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = null);
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'As senhas não coincidem');
    } else {
      setState(() => _confirmPasswordError = null);
    }
  }

  bool _isFormValid() {
    return _passwordError == null &&
        _confirmPasswordError == null &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.length >= 6;
  }

  Future<void> _handleReset() async {
    _validatePassword();
    _validateConfirmPassword();

    if (!_isFormValid()) {
      setState(() {
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    try {
      final newPassword = _newPasswordController.text;
      final result = await _apiService.updatePassword(newPassword);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Senha resetada com sucesso
          context.go('/forgot-password/password-updated');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erro ao atualizar senha'),
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
                  context.go('/forgot-password/email-sent');
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
                'Defina sua nova senha',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900),
              ),
              const SizedBox(height: AppTokens.spacingXs),
              Text(
                'Crie uma senha forte para proteger sua conta',
                style: AppTextStyles.bodySm(color: AppTokens.neutral600),
              ),
              const SizedBox(height: AppTokens.spacingXl),
              AppTextField(
                controller: _newPasswordController,
                label: 'Nova senha',
                hint: 'Digite sua nova senha',
                icon: Icons.lock_outline,
                obscureText: _obscureNewPassword,
                errorText: _hasError ? _passwordError : null,
                suffix: _visibilityToggle(_obscureNewPassword, () {
                  setState(() => _obscureNewPassword = !_obscureNewPassword);
                }),
              ),
              const SizedBox(height: AppTokens.spacingM),
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirmar senha',
                hint: 'Digite novamente sua nova senha',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                errorText: _hasError ? _confirmPasswordError : null,
                suffix: _visibilityToggle(_obscureConfirmPassword, () {
                  setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword);
                }),
              ),
              const SizedBox(height: AppTokens.spacingL),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: AppTokens.primary),
                  const SizedBox(width: 8),
                  Text('No mínimo 6 caracteres',
                      style: AppTextStyles.bodyXs(color: AppTokens.neutral600)),
                ],
              ),
              const SizedBox(height: AppTokens.spacingXl),
              AppButton(
                text: 'Atualizar senha',
                isLoading: _isLoading,
                onPressed: _isFormValid() ? _handleReset : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visibilityToggle(bool obscured, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppTokens.neutral500,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}
