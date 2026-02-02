import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../patient/patient_app_bar.dart';

/// AppBar padronizado para o fluxo de nova consulta. Usa [PatientAppBar] com fallback para consultas.
class ConsultationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? avatarWidget;

  const ConsultationAppBar({
    super.key,
    this.title = 'Nova consulta',
    this.onBack,
    this.avatarWidget,
  });

  @override
  Widget build(BuildContext context) {
    return PatientAppBar(
      title: title,
      fallbackRoute: '/patient/consultations',
      onBack: onBack ?? () => _defaultBack(context),
      trailingWidget: avatarWidget,
      avatarTappable: false,
    );
  }

  void _defaultBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/patient/consultations');
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
