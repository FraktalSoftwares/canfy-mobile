import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Header padronizado de cada etapa do fluxo de novo pedido:
/// título "Novo pedido" e linha de badges (Etapa N - ... e Valor).
class NewOrderStepHeader extends StatelessWidget {
  /// Texto do badge da etapa (ex: "Etapa 1 - Selecione a receita").
  final String stepLabel;

  /// Texto do valor formatado (ex: "Valor: R$ 100,00"). Exibido ao lado do badge da etapa.
  final String valueText;

  const NewOrderStepHeader({
    super.key,
    required this.stepLabel,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Novo pedido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0EE),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                stepLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007A3B),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
