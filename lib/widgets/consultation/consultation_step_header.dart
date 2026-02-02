import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Header padronizado para cada etapa do fluxo de nova consulta
class ConsultationStepHeader extends StatelessWidget {
  final int stepNumber;
  final String stepTitle;
  final String? valueText;

  const ConsultationStepHeader({
    super.key,
    required this.stepNumber,
    required this.stepTitle,
    this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Etapa $stepNumber - $stepTitle',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ),
        if (valueText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              valueText!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.canfyGreen,
              ),
            ),
          ),
      ],
    );
  }
}
