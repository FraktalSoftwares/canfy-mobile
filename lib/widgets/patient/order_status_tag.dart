import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Tag de status de pedido conforme design Figma (node 2770-18996).
/// Usar em todo o sistema onde o status do pedido é exibido.
class OrderStatusTag extends StatelessWidget {
  /// Status já formatado para a UI: "Em análise", "Aprovado", "Cancelado",
  /// "Enviado", "Entregue", "Em separação", "Recusado".
  final String status;

  const OrderStatusTag({super.key, required this.status});

  static Color _backgroundColor(String status) {
    switch (status) {
      case 'Em análise':
      case 'Pendente':
        return AppColors.orderTagEmAnaliseBg;
      case 'Aprovado':
        return AppColors.orderTagAprovadoBg;
      case 'Cancelado':
      case 'Recusado':
        return AppColors.orderTagCanceladoBg;
      case 'Enviado':
      case 'Em separação':
        return AppColors.orderTagEnviadoBg;
      case 'Entregue':
        return AppColors.orderTagEntregueBg;
      default:
        return AppColors.orderTagEntregueBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor(status),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.orderTagText,
        ),
      ),
    );
  }
}
