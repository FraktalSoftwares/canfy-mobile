import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Estilos de texto do Canfy, derivados de [AppTokens] (Fase 0).
///
/// Duas famílias, conforme o Figma: [truculenta] para títulos/headings e
/// [arimo] para corpo de texto. Os helpers genéricos são mantidos por
/// compatibilidade; prefira as escalas nomeadas (headingMd, bodyMd, …) em
/// código novo para garantir tamanho/peso/altura de linha consistentes.
class AppTextStyles {
  AppTextStyles._();

  // Helpers genéricos (compat) --------------------------------------------------

  /// Fonte Truculenta para títulos.
  static TextStyle truculenta({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.truculenta(
      fontSize: fontSize ?? AppTokens.headingMd,
      fontWeight: fontWeight ?? AppTokens.weightBold,
      color: color ?? AppTokens.neutral900,
      height: height,
    );
  }

  /// Fonte Arimo para textos.
  static TextStyle arimo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return GoogleFonts.arimo(
      fontSize: fontSize ?? AppTokens.bodyMd,
      fontWeight: fontWeight ?? AppTokens.weightRegular,
      color: color ?? AppTokens.neutral900,
      height: height,
    );
  }

  // Escala nomeada (Figma) ------------------------------------------------------

  // Headings (Truculenta)
  static TextStyle headingLg({Color? color}) => truculenta(
        fontSize: AppTokens.headingLg,
        fontWeight: AppTokens.weightBold,
        color: color,
      );
  static TextStyle headingMd({Color? color}) => truculenta(
        fontSize: AppTokens.headingMd,
        fontWeight: AppTokens.weightSemibold,
        color: color,
      );
  static TextStyle headingSm({Color? color}) => truculenta(
        fontSize: AppTokens.headingSm,
        fontWeight: AppTokens.weightSemibold,
        color: color,
      );

  // Body (Arimo) — altura de linha 1.5
  static TextStyle bodyMd({Color? color, FontWeight? weight}) => arimo(
        fontSize: AppTokens.bodyMd,
        fontWeight: weight ?? AppTokens.weightRegular,
        color: color,
        height: AppTokens.lineHeight,
      );
  static TextStyle bodySm({Color? color, FontWeight? weight}) => arimo(
        fontSize: AppTokens.bodySm,
        fontWeight: weight ?? AppTokens.weightRegular,
        color: color,
        height: AppTokens.lineHeight,
      );
  static TextStyle bodyXs({Color? color, FontWeight? weight}) => arimo(
        fontSize: AppTokens.bodyXs,
        fontWeight: weight ?? AppTokens.weightRegular,
        color: color,
        height: AppTokens.lineHeight,
      );
}
