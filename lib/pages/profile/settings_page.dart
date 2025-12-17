import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Preferências de notificação
  bool _emailAlerts = true;
  bool _smsAlerts = true;
  bool _pushAlerts = false;

  // Tipos de notificações
  bool _consultationAlerts = true;
  bool _deliveryAlerts = false;
  bool _anvisaAlerts = false;
  bool _newPrescriptionAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus em radianos
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Preferências',
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
              child: const Icon(Icons.person, color: Colors.grey),
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
              'Configurações',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Preferências de notificação
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferências de notificação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas por e-mail',
                    _emailAlerts,
                    (value) => setState(() => _emailAlerts = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas por SMS',
                    _smsAlerts,
                    (value) => setState(() => _smsAlerts = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas por push',
                    _pushAlerts,
                    (value) => setState(() => _pushAlerts = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tipos de notificações
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipos de notificações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre consultas',
                    _consultationAlerts,
                    (value) => setState(() => _consultationAlerts = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre entregas',
                    _deliveryAlerts,
                    (value) => setState(() => _deliveryAlerts = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre a Anvisa',
                    _anvisaAlerts,
                    (value) => setState(() => _anvisaAlerts = value),
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchRow(
                    'Alertas sobre novas receitas',
                    _newPrescriptionAlerts,
                    (value) => setState(() => _newPrescriptionAlerts = value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF3F3F3D),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00994B),
        ),
      ],
    );
  }
}

