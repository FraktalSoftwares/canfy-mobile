import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_theme.dart';

class ValidationStatusPage extends StatelessWidget {
  const ValidationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user-selection');
            }
          },
        ),
        title: Text(
          'Disponibilidade de atendimento',
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              // Ícone de check
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8EF), // green-100
                  borderRadius: BorderRadius.circular(117.647),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF66DDA2), // green-300
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Título
              Text(
                'Sua documentação foi enviada com sucesso!',
                textAlign: TextAlign.center,
                style: AppTextStyles.truculenta(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Tag "Em análise"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9E68C), // yellow-300
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Em análise',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF654C01), // yellow-900
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Texto explicativo
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    color: const Color(0xFF5E5E5B), // neutral-700
                  ),
                  children: [
                    const TextSpan(
                      text: 'Agora vamos validar suas informações e documentos.\n\n',
                    ),
                    const TextSpan(
                      text: 'Estamos analisando seus documentos. \n',
                    ),
                    const TextSpan(
                      text: 'Normalmente é rápido, mas pode levar mais tempo dependendo da fila de validações.\n\n',
                    ),
                    TextSpan(
                      text: 'Você receberá uma notificação assim que sua conta\nfor aprovada.',
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 124),
              // Botão de contato
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Abrir WhatsApp ou canal de suporte
                  },
                  icon: const Icon(
                    Icons.headset_mic,
                    size: 16,
                    color: AppTheme.canfyGreen,
                  ),
                  label: Text(
                    'Entrar em contato com o suporte',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: AppTheme.canfyGreen,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.canfyGreen,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
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






