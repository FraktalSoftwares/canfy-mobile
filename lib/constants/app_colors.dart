import 'package:flutter/material.dart';

import '../core/theme/app_tokens.dart';

/// Constantes de cores do aplicativo.
///
/// A partir da Fase 0 (design system), esta classe é uma fachada sobre
/// [AppTokens] — a fonte única de tokens espelhada do Figma. Os valores foram
/// preservados 1:1 para não alterar a aparência das telas já implementadas;
/// novos usos devem preferir [AppTokens] diretamente.
class AppColors {
  AppColors._();

  // Cores principais
  static const Color primary = AppTokens.primary; // marca (verde)
  static const Color secondary = AppTokens.green900;
  static const Color tertiary = AppTokens.accentPurpleMedium;
  static const Color error = Color(0xFFFF5963);
  static const Color success = AppTokens.green800;
  static const Color warning = Color(0xFFF9CF58);

  // Cores do Canfy
  static const Color canfyGreen = AppTokens.green800; // #00994B
  static const Color canfyPurple = AppTokens.accentPurple;
  static const Color canfyPurpleLight = AppTokens.accentPurpleLight;
  static const Color canfyPurpleMedium = AppTokens.accentPurpleMedium;
  static const Color canfyLime = AppTokens.accentLime;
  static const Color canfyLimeMedium = AppTokens.accentLimeMedium;

  // Cores neutras
  static const Color neutral000 = AppTokens.neutral000;
  static const Color neutral050 = AppTokens.neutral050;
  // Nota: historicamente "neutral100" no código é o verde-100 do Figma
  // (#E6F8EF), usado como superfície de fundo clara. Mantido por compat.
  static const Color neutral100 = AppTokens.green100;
  static const Color neutral200 = AppTokens.neutral200;
  static const Color neutral300 = AppTokens.neutral300;
  static const Color neutral600 = AppTokens.neutral600;
  static const Color neutral800 = AppTokens.neutral800;
  static const Color neutral900 = AppTokens.neutral900;

  // Cores de status (tags de agendamento – Figma)
  static const Color statusYellow = Color(0xFFF9E68C);
  static const Color statusYellowDark = Color(0xFF654C01);
  static const Color statusBlue = Color(0xFFA6BBF9);
  static const Color statusBlueDark = Color(0xFF102D57);
  static const Color statusGrey = AppTokens.neutral300;
  static const Color statusGreyDark = Color(0xFF2C333A);
  static const Color statusCancelBg = Color(0xFFFFE5E5);
  static const Color statusCancelText = Color(0xFFB71C1C);

  // Tags de status de pedidos (Figma – node 2770-18996)
  static const Color orderTagEmAnaliseBg = Color(0xFFF9E68C);
  static const Color orderTagAprovadoBg = Color(0xFFC8E6C9);
  static const Color orderTagCanceladoBg = Color(0xFFFFCDD2);
  static const Color orderTagEnviadoBg = Color(0xFFB3E5FC);
  static const Color orderTagEntregueBg = AppTokens.neutral300;
  static const Color orderTagText = Color(0xFF2C333A);
}
