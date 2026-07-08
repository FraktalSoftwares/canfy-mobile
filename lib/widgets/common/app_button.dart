import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';

/// Variantes de botão do design system Canfy (Fase 0).
enum AppButtonVariant {
  /// Fundo verde da marca, texto branco (CTA principal).
  primary,

  /// Fundo transparente com borda verde, texto verde.
  secondary,

  /// Sem borda/fundo, apenas texto verde (ação terciária).
  text,
}

/// Botão padronizado do app, derivado de [AppTokens].
///
/// Consolida o padrão de CTA já usado nas telas (full-width, cantos "pill",
/// altura 52) numa única primitiva reutilizável pelos dois ambientes
/// (paciente e médico). Substitui gradualmente os botões duplicados por tela.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || onPressed == null;
    final Color fg = switch (variant) {
      AppButtonVariant.primary => AppTokens.neutral000,
      AppButtonVariant.secondary => AppTokens.primary,
      AppButtonVariant.text => AppTokens.primary,
    };

    final Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? AppTokens.neutral000
                  : AppTokens.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: AppTokens.spacingXs),
              ],
              Text(
                text,
                style: AppTextStyles.bodyMd(
                  color: disabled && variant != AppButtonVariant.primary
                      ? AppTokens.neutral500
                      : fg,
                  weight: AppTokens.weightSemibold,
                ),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    );
    const padding = EdgeInsets.symmetric(
      horizontal: AppTokens.buttonPaddingH,
      vertical: AppTokens.buttonPaddingV,
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTokens.primary,
            disabledBackgroundColor: AppTokens.neutral300,
            foregroundColor: fg,
            disabledForegroundColor: AppTokens.neutral600,
            elevation: 0,
            minimumSize: const Size(AppTokens.buttonMinWidth, 52),
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fg,
            side: BorderSide(
              color: disabled ? AppTokens.neutral300 : AppTokens.primary,
            ),
            minimumSize: const Size(AppTokens.buttonMinWidth, 52),
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: fg,
            padding: padding,
            shape: shape,
          ),
          child: child,
        ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
