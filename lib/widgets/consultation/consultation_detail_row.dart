import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Linha de detalhe padronizada para resumos no fluxo de nova consulta
class ConsultationDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const ConsultationDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
