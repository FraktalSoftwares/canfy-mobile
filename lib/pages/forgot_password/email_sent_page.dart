import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/api_service.dart';
import '../../widgets/common/app_button.dart';

const _resendCooldownSeconds = 60;

class EmailSentPage extends StatefulWidget {
  final String? email;

  const EmailSentPage({super.key, this.email});

  @override
  State<EmailSentPage> createState() => _EmailSentPageState();
}

class _EmailSentPageState extends State<EmailSentPage> {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  int _cooldown = 0;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _resend() async {
    final email = widget.email;
    if (email == null || email.isEmpty || _cooldown > 0 || _resending) return;
    setState(() => _resending = true);
    final result = await _apiService.resetPasswordForEmail(email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (result['success'] == true) {
      _startCooldown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(result['message'] as String? ?? 'Erro ao reenviar email'),
          backgroundColor: Colors.red,
        ),
      );
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
                  context.go('/forgot-password');
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
            children: [
              const SizedBox(height: 120),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppTokens.green100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 40, color: AppTokens.primary),
              ),
              const SizedBox(height: 40),
              Text(
                'Um link de recuperação foi enviado para o seu e-mail',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.spacingXl),
              AppButton(
                text: 'Voltar para o login',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: AppTokens.spacingS),
              if (widget.email != null)
                TextButton(
                  onPressed: _cooldown > 0 || _resending ? null : _resend,
                  child: Text(
                    _cooldown > 0
                        ? 'Reenviar email (${_cooldown}s)'
                        : 'Reenviar email',
                    style: AppTextStyles.bodySm(
                      color: _cooldown > 0
                          ? AppTokens.neutral500
                          : AppTokens.primary,
                      weight: AppTokens.weightSemibold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
