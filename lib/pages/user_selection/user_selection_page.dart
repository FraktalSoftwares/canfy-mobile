import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import 'dart:math' as math;

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ellipse de fundo (círculo grande centralizado)
          Positioned(
            left: screenWidth / 2 - 435.5, // 871px / 2
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

          // Garrafa da esquerda - posicionada parcialmente fora da tela
          Positioned(
            left: -50, // 12px para a direita
            top: 400,
            child: Transform.rotate(
              angle: 41.544 * math.pi / 180, // 41.544 graus em radianos
              child: Image.asset(
                'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
                width: 176,
                height: 202,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Garrafa da direita - posicionada parcialmente fora da tela
          Positioned(
            left: screenWidth / 2 + 90, // 12px para a direita
            top: 400,
            child: Transform.rotate(
              angle: 138.456 * math.pi / 180, // 138.456 graus em radianos
              child: Transform.scale(
                scaleY: -1, // Espelhar verticalmente
                child: Image.asset(
                  'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
                  width: 176,
                  height: 202,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Logo Vector - posicionado conforme Figma (left: 16px, top: calc(50% - 232.99px))
          Positioned(
            left: 16,
            top: screenHeight / 2 - 232.99,
            child: Image.asset(
              'assets/images/Vector.png',
              width: 77,
              height: 40.02,
              fit: BoxFit.contain,
            ),
          ),

          // Textos centralizados verticalmente (top: calc(50% - 144px))
          Positioned(
            left: 16,
            top: screenHeight / 2 - 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texto "Saúde com liberdade." - Truculenta Bold
                Text(
                  'Saúde com liberdade.',
                  style: AppTextStyles.truculenta(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212121),
                  ),
                ),
                // Texto "Conectamos você ao cuidado certo, sem barreiras."
                Text(
                  'Conectamos você ao cuidado certo,\nsem barreiras.',
                  style: AppTextStyles.truculenta(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9A9A97),
                  ),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                ),
              ],
            ),
          ),

          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Botões na parte inferior
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 34),
                  child: Column(
                    children: [
                      // Botão Usar como paciente
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            context.go('/register?type=patient');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF00994B), // green-800
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(999)), // Muito arredondado
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            'Usar como paciente',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botão Usar como médico/Prescritor
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            context.go('/register?type=doctor');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00994B),
                            side: const BorderSide(
                              color: Color(0xFF00994B),
                              width: 1,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(999)),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            'Usar como médico/Prescritor',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: const Color(0xFF00994B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
