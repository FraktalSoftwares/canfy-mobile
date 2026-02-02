import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';

/// Bottom Navigation Bar do paciente conforme design Figma (navMenu).
/// Três abas: Home, Pedidos, Consultas.
/// Item ativo: ícone preenchido, texto em negrito e indicador preto centralizado.
class PatientBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const PatientBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral000,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                isActive: currentIndex == 0,
                onTap: () => context.go('/patient/home'),
                showIndicator: currentIndex == 0,
              ),
              _NavItem(
                label: 'Pedidos',
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                isActive: currentIndex == 1,
                onTap: () => context.go('/patient/orders'),
                showIndicator: currentIndex == 1,
              ),
              _NavItem(
                label: 'Consultas',
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                isActive: currentIndex == 2,
                onTap: () => context.go('/patient/consultations'),
                showIndicator: currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final bool showIndicator;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    required this.showIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? AppColors.neutral900 : AppColors.neutral600,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color:
                        isActive ? AppColors.neutral900 : AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: showIndicator ? 24 : 0,
                  height: showIndicator ? 3 : 0,
                  decoration: BoxDecoration(
                    color: showIndicator
                        ? AppColors.neutral900
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
