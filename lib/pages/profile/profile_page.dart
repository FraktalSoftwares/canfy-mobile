import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

/// Página de perfil do médico conforme design Figma (node 2531-11892).
/// Header cinza claro, título "Perfil", avatar à direita; lista de itens com ícone verde em círculo verde claro.
/// Tipografia: Inter Tight (títulos), Inter (corpo), conforme tema do app.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral000,
      appBar: AppBar(
        backgroundColor: AppColors.neutral050,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Perfil',
          style: GoogleFonts.interTight(
            color: AppColors.neutral800,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          DoctorAppBarAvatar(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil',
              style: GoogleFonts.truculenta(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral800,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'Dados básicos',
              onTap: () => context.go('/profile/basic-data'),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Agenda',
              onTap: () => context.go('/profile/schedule'),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Configurações',
              onTap: () => context.go('/profile/settings'),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'Sobre',
              onTap: () => context.go('/profile/about'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: -1),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.neutral050,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(icon, color: AppColors.canfyGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.neutral800,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.neutral600,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
