import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';

/// AppBar padronizado para todas as páginas da área do paciente.
/// Garante consistência de UX/UI: botão voltar, título e avatar.
class PatientAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título centralizado (ignorado se [titleWidget] for fornecido).
  final String title;

  /// Título customizado (ex.: Row com avatar e texto na live consultation).
  final Widget? titleWidget;

  /// Exibe o botão de voltar. Use false na Home e na página principal da Conta.
  final bool showLeading;

  /// Rota de fallback quando [context.canPop()] é false (ex.: '/patient/home').
  final String? fallbackRoute;

  /// URL do avatar do paciente. Se null, exibe placeholder.
  final String? avatarUrl;

  /// Se true, o avatar leva para /patient/account ao toque.
  final bool avatarTappable;

  /// Exibe indicador de loading no lugar do avatar (ex.: ao carregar dados da conta).
  final bool avatarLoading;

  /// Widget customizado à direita (ex.: avatar do fluxo de consulta). Se null, usa [avatarUrl]/[avatarTappable].
  final Widget? trailingWidget;

  /// Ações extras à direita (ex.: ícone de filtro). Aparecem antes do avatar/trailing.
  final List<Widget>? actions;

  /// Barra inferior (ex.: TabBar).
  final PreferredSizeWidget? bottom;

  /// Callback customizado ao pressionar voltar. Se null, usa pop/fallbackRoute.
  final VoidCallback? onBack;

  const PatientAppBar({
    super.key,
    this.title = '',
    this.titleWidget,
    this.showLeading = true,
    this.fallbackRoute,
    this.avatarUrl,
    this.avatarTappable = true,
    this.avatarLoading = false,
    this.trailingWidget,
    this.actions,
    this.bottom,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.neutral000,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: showLeading
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: _PatientBackButton(
                  onPressed: onBack ?? () => _handleBack(context),
                ),
              ),
            )
          : null,
      leadingWidth: showLeading ? 56 : 0,
      title: titleWidget ??
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
      centerTitle: true,
      actions: [
        ...?actions,
        if (trailingWidget != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: trailingWidget!,
          )
        else
          _buildAvatar(context),
      ],
      bottom: bottom,
    );
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else if (fallbackRoute != null && fallbackRoute!.isNotEmpty) {
      context.go(fallbackRoute!);
    }
  }

  Widget _buildAvatar(BuildContext context) {
    final showAvatar = avatarUrl != null || avatarTappable || avatarLoading;
    if (!showAvatar) return const SizedBox.shrink();

    if (avatarLoading) {
      return const Padding(
        padding: EdgeInsets.only(right: 16),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.neutral900,
              ),
            ),
          ),
        ),
      );
    }

    final avatar = avatarUrl != null && avatarUrl!.isNotEmpty
        ? CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl!),
            onBackgroundImageError: (_, __) {},
          )
        : const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.neutral200,
            child: Icon(Icons.person, color: AppColors.neutral900, size: 22),
          );

    Widget child = Padding(
      padding: const EdgeInsets.only(right: 16),
      child: avatar,
    );
    if (avatarTappable) {
      child = GestureDetector(
        onTap: () => context.push('/patient/account'),
        child: child,
      );
    }
    return child;
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}

/// Botão de voltar padronizado: círculo verde (neutral100) + chevron.
class _PatientBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PatientBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.neutral900,
          size: 24,
        ),
      ),
    );
  }
}
