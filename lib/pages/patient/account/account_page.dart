import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientAccountPage extends StatelessWidget {
  const PatientAccountPage({super.key});

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Transform.rotate(
                  angle: 1.5708, // 90 graus
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Transform.rotate(
                      angle: 4.7124, // 270 graus
                      child: Icon(icon, color: Colors.black, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF3F3F3D),
                  ),
                ),
              ],
            ),
            Transform.rotate(
              angle: 1.5708,
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF7C7C79),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Conta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conta e configurações',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Dados básicos',
                  route: '/patient/account/basic-data',
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.shield_outlined,
                  title: 'Anvisa',
                  route: '/patient/account/anvisa',
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configurações',
                  route: '/patient/account/settings',
                ),
                const SizedBox(height: 16),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Sobre',
                  route: '/patient/account/about',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





