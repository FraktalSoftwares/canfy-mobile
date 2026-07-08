import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_button.dart';

class EmailSentPage extends StatelessWidget {
  const EmailSentPage({super.key});

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
            ],
          ),
        ),
      ),
    );
  }
}
