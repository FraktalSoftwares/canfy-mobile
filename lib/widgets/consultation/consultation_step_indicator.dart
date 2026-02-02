import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Indicador de progresso padronizado para o fluxo de nova consulta
class ConsultationStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ConsultationStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 6,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.canfyGreen : AppColors.neutral300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
