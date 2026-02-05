import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Indicador de progresso padronizado do fluxo de novo pedido (6 segmentos).
/// [currentStep] deve ser entre 1 e 6.
class NewOrderStepProgress extends StatelessWidget {
  static const int totalSteps = 6;
  static const double segmentWidth = 53;
  static const double segmentHeight = 6;
  static const double spacing = 8;

  /// Etapa atual (1 a 6). Representa quantos segmentos estão preenchidos.
  final int currentStep;

  const NewOrderStepProgress({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final filledCount = currentStep.clamp(0, totalSteps);
    return Row(
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          if (i > 0) const SizedBox(width: spacing),
          Container(
            width:
                i == 3 ? 52 : segmentWidth, // 4º segmento é 52px conforme Figma
            height: segmentHeight,
            decoration: BoxDecoration(
              color: i < filledCount ? _progressGreen : AppColors.neutral300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ],
    );
  }

  static const Color _progressGreen = Color(0xFF00BB5A);
}
