import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Tag de sintoma padronizada para o fluxo de nova consulta
class ConsultationSymptomTag extends StatelessWidget {
  final String symptom;
  final bool isSelected;
  final bool isReadOnly;
  final VoidCallback? onTap;

  const ConsultationSymptomTag({
    super.key,
    required this.symptom,
    this.isSelected = false,
    this.isReadOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReadOnly ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isReadOnly ? 12 : 14,
          vertical: isReadOnly ? 6 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected || isReadOnly
              ? AppColors.neutral100
              : AppColors.neutral050,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.canfyGreen
                : isReadOnly
                    ? Colors.transparent
                    : AppColors.neutral200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          symptom,
          style: TextStyle(
            fontSize: isReadOnly ? 12 : 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected || isReadOnly
                ? AppColors.canfyGreen
                : AppColors.neutral900,
          ),
        ),
      ),
    );
  }
}
