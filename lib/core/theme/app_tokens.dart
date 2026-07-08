import 'package:flutter/material.dart';

/// Fonte única de tokens de design do Canfy, espelhando as variáveis do
/// protótipo Figma ("Canfy Aditivo", file n24qmDfYEaHOMAMkumCdgG).
///
/// Estes tokens são a base do design system (Fase 0). `AppColors`, `AppTheme`
/// e `AppTextStyles` devem derivar destes valores em vez de redefinir cores/
/// tamanhos soltos. Nomes seguem a taxonomia do Figma (Brand/…, spacing-…,
/// radius-…) para facilitar o rastreio design↔código.
class AppTokens {
  AppTokens._();

  // ---------------------------------------------------------------------------
  // Cores — Brand/green (cor primária da marca)
  // ---------------------------------------------------------------------------
  static const Color green100 = Color(0xFFE6F8EF);
  static const Color green800 = Color(0xFF00994B); // primária
  static const Color green900 = Color(0xFF007A3B);

  // Cores — Brand/neutral (escala de cinzas)
  static const Color neutral000 = Color(0xFFFFFFFF);
  static const Color neutral050 = Color(0xFFF7F7F5);
  static const Color neutral100 = Color(0xFFF0F0EE);
  static const Color neutral200 = Color(0xFFE6E6E3);
  static const Color neutral300 = Color(0xFFD6D6D3);
  static const Color neutral400 = Color(0xFFB8B8B5);
  static const Color neutral500 = Color(0xFF9A9A97);
  static const Color neutral600 = Color(0xFF7C7C79);
  static const Color neutral700 = Color(0xFF5E5E5B);
  static const Color neutral800 = Color(0xFF3F3F3D);
  static const Color neutral900 = Color(0xFF212121);

  // Cores — Brand/yellow (avisos / tags "em análise")
  static const Color yellow100 = Color(0xFFFDF7E3);
  static const Color yellow300 = Color(0xFFF9E68C);
  static const Color yellow700 = Color(0xFFF2CF31);
  static const Color yellow900 = Color(0xFF9E831B);
  static const Color tagYellowOnLight = Color(0xFF654C01);

  // Cores — Brand/orange (erros suaves)
  static const Color orange900 = Color(0xFFA64740);

  // Cores — Primary/blue (destaques secundários)
  static const Color blue100 = Color(0xFFE7E7F1);
  static const Color blue900 = Color(0xFF0C0C3E);

  // Superfícies
  static const Color surface = Color(0xFFF3F4F6); // surface/surface
  static const Color surfaceTransparent = Color(0x00000000); // surface/default
  static const Color neutralGray100 = Color(0xFFF2F2F2);

  // Acentos legados (mantidos por compatibilidade; usados em telas antigas /
  // landing). Não fazem parte da paleta central do protótipo mobile.
  static const Color accentPurple = Color(0xFF9067F1);
  static const Color accentPurpleLight = Color(0xFFF1EDFC);
  static const Color accentPurpleMedium = Color(0xFFC3A6F9);
  static const Color accentLime = Color(0xFFD7FA80);
  static const Color accentLimeMedium = Color(0xFFC5F740);

  // Semânticos
  static const Color primary = green800;
  static const Color primaryDark = green900;
  static const Color error = orange900;
  static const Color success = green800;
  static const Color warning = yellow700;

  // ---------------------------------------------------------------------------
  // Tipografia — famílias (Google Fonts)
  // ---------------------------------------------------------------------------
  static const String fontHeading = 'Truculenta';
  static const String fontBody = 'Arimo';

  // Pesos
  static const FontWeight weightRegular = FontWeight.w400;
  static const FontWeight weightMedium = FontWeight.w500;
  static const FontWeight weightSemibold = FontWeight.w600;
  static const FontWeight weightBold = FontWeight.w700;

  // Tamanhos de fonte
  static const double bodyXs = 12;
  static const double bodySm = 14;
  static const double bodyMd = 16;
  static const double headingSm = 20;
  static const double headingMd = 24;
  static const double headingLg = 32;

  static const double lineHeight = 1.5; // altura de linha padrão do protótipo

  // ---------------------------------------------------------------------------
  // Espaçamento (spacing-*)
  // ---------------------------------------------------------------------------
  static const double spacingXxs = 4;
  static const double spacingXs = 8; // spacing-3xs / spacing-xs
  static const double spacingS = 12;
  static const double spacingM = 16; // spacing-m
  static const double spacingL = 24;
  static const double spacingXl = 32;

  // ---------------------------------------------------------------------------
  // Raios (radius-*)
  // ---------------------------------------------------------------------------
  static const double radiusNone = 0;
  static const double radiusInput = 4; // radius-input
  static const double radiusButton = 8; // buttonCornerRadius/some
  static const double radius16 = 16;
  static const double radius32 = 32;
  static const double radiusPill = 999;

  // ---------------------------------------------------------------------------
  // Botões (padding/tamanho medium do Figma)
  // ---------------------------------------------------------------------------
  static const double buttonPaddingH = 20; // buttonPadding/leftRight/medium
  static const double buttonPaddingV = 14; // buttonPadding/topBottom/medium
  static const double buttonMinWidth = 112; // buttonSize/minWidth/medium

  // ---------------------------------------------------------------------------
  // Sombra (dropShadow)
  // ---------------------------------------------------------------------------
  static const List<BoxShadow> dropShadow = [
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
