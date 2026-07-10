import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';

/// Campo de texto padrão do design system (Fase 0): rótulo opcional com
/// asterisco de obrigatório, contorno "pill", ícone à esquerda e estados de
/// erro/foco. Espelha o input do protótipo (Login/Cadastro/Recuperação).
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final bool required;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffix;
  final List<dynamic>? inputFormatters; // TextInputFormatter (evita import extra)
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.required = false,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.suffix,
    this.inputFormatters,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.bodySm(
                color: AppTokens.neutral800,
                weight: AppTokens.weightSemibold,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: AppTextStyles.bodySm(color: AppTokens.primary),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: AppTokens.spacingXs),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: inputFormatters?.cast(),
          style: AppTextStyles.bodySm(color: AppTokens.neutral900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySm(color: AppTokens.neutral500),
            prefixIcon: icon != null
                ? Icon(icon,
                    color: hasError
                        ? AppTokens.errorFieldBorder
                        : AppTokens.neutral600,
                    size: 22)
                : null,
            suffixIcon: suffix,
            filled: hasError,
            fillColor: AppTokens.errorFieldFill,
            isDense: true,
            border: border(AppTokens.neutral300),
            enabledBorder: border(
                hasError ? AppTokens.errorFieldBorder : AppTokens.neutral300),
            focusedBorder: border(
                hasError ? AppTokens.errorFieldBorder : AppTokens.primary, 2),
            errorText: errorText,
            errorStyle: AppTextStyles.bodyXs(
                color: AppTokens.errorFieldBorder,
                weight: AppTokens.weightSemibold),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTokens.spacingM,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
