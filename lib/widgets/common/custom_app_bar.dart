import 'package:flutter/material.dart';

/// AppBar customizado reutilizável
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          fontSize: centerTitle ? 14 : 24,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? const Color(0xFF212121),
          fontFamily: centerTitle ? null : 'Truculenta',
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}





