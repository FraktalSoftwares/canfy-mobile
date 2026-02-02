import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class PatientAccountPage extends StatefulWidget {
  const PatientAccountPage({super.key});

  @override
  State<PatientAccountPage> createState() => _PatientAccountPageState();
}

class _PatientAccountPageState extends State<PatientAccountPage> {
  final PatientService _patientService = PatientService();

  String _patientName = 'Usuário';
  String? _patientAvatar;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    final result = await _patientService.getCurrentPatient();
    if (result['success'] == true && mounted) {
      final data = result['data'] as Map<String, dynamic>?;
      final profile = data?['profile'] as Map<String, dynamic>?;
      if (profile != null) {
        setState(() {
          _patientName = profile['nome_completo'] as String? ?? 'Usuário';
          _patientAvatar = profile['foto_perfil_url'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
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
      appBar: PatientAppBar(
        title: 'Conta',
        showLeading: false,
        avatarUrl: _patientAvatar,
        avatarTappable: false,
        avatarLoading: _isLoading,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLoading ? 'Carregando...' : 'Conta e configurações',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            if (!_isLoading && _patientName != 'Usuário') ...[
              const SizedBox(height: 8),
              Text(
                _patientName,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7C7C79),
                ),
              ),
            ],
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
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 0, // Usar índice 0 (Home) já que conta não está no menu
      ),
    );
  }
}
