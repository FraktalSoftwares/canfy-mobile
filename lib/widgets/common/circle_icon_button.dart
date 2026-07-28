import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Botão de ícone circular com fundo verde-claro (`AppColors.neutral100`) e
/// ícone verde (`AppColors.canfyGreen`) — padrão de marca usado em botões
/// voltar/chevron/filtro/compartilhar nas telas do médico e do paciente.
///
/// Não usar para os poucos casos legítimos de círculo verde-escuro sólido
/// (ex. navegação de agenda) — conferir o frame Figma correspondente antes.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 40,
    this.iconSize = 22,
    this.backgroundColor = AppColors.neutral100,
    this.iconColor = AppColors.canfyGreen,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}
