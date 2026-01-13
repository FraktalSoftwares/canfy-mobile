import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom Navigation Bar reutilizável para usuários pacientes
class PatientBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const PatientBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3F3F3D),
        unselectedItemColor: const Color.fromARGB(255, 153, 153, 146),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        onTap: (index) {
          if (index == 0) {
            context.go('/patient/home');
          } else if (index == 1) {
            context.go('/patient/orders');
          } else if (index == 2) {
            context.go('/patient/consultations');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Icon(Icons.local_mall),
            ),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Icon(Icons.calendar_today),
            ),
            label: 'Consultas',
          ),
        ],
      ),
    );
  }
}
