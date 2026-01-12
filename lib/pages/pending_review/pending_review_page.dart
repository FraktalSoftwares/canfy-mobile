import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class PendingReviewPage extends StatelessWidget {
  const PendingReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ellipse de fundo
          Positioned(
            left: screenWidth / 2 - 435.5,
            top: screenHeight / 2 - 435.5,
            child: Container(
              width: 871,
              height: 871,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE1BEE7).withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 54),
                  // Ícone de aguardando
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.canfyGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_empty,
                      size: 36,
                      color: AppTheme.canfyGreen,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Título
                  Text(
                    'Seus documentos estão em análise',
                    style: AppTextStyles.truculenta(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nossa equipe está analisando seus documentos. Este processo pode levar até 24 horas.',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: const Color(0xFF9A9A97),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você receberá uma notificação quando a análise for concluída.',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: const Color(0xFF9A9A97),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Botão Entendi
                  Padding(
                    padding: const EdgeInsets.only(bottom: 34),
                    child: SizedBox(
                      width: double.infinity,
                      height: 49,
                      child: ElevatedButton(
                        onPressed: () {
                          // Pacientes vão para home, médicos para user-selection
                          // Por enquanto, redirecionar todos para user-selection
                          // (em produção, verificar tipo de usuário)
                          context.go('/patient/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.canfyGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Entendi',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}
