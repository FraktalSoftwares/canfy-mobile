import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_button.dart';

class PasswordUpdatedPage extends StatelessWidget {
  const PasswordUpdatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                'Sua senha foi atualizada com sucesso',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTokens.spacingXl),
              AppButton(
                text: 'Ir para o login',
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
