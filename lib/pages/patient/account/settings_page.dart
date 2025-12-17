import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PatientSettingsPage extends StatefulWidget {
  const PatientSettingsPage({super.key});

  @override
  State<PatientSettingsPage> createState() => _PatientSettingsPageState();
}

class _PatientSettingsPageState extends State<PatientSettingsPage> {
  bool _emailAlerts = true;
  bool _smsAlerts = true;
  bool _pushAlerts = false;
  bool _consultationAlerts = true;
  bool _deliveryAlerts = false;
  bool _anvisaAlerts = false;
  bool _prescriptionAlerts = true;

  Widget _buildNotificationSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/account');
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
              'Configurações',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
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
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas por e-mail',
                    value: _emailAlerts,
                    onChanged: (value) {
                      setState(() {
                        _emailAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas por SMS',
                    value: _smsAlerts,
                    onChanged: (value) {
                      setState(() {
                        _smsAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas por push',
                    value: _pushAlerts,
                    onChanged: (value) {
                      setState(() {
                        _pushAlerts = value;
                      });
                    },
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
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre consultas',
                    value: _consultationAlerts,
                    onChanged: (value) {
                      setState(() {
                        _consultationAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre entregas',
                    value: _deliveryAlerts,
                    onChanged: (value) {
                      setState(() {
                        _deliveryAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre a Anvisa',
                    value: _anvisaAlerts,
                    onChanged: (value) {
                      setState(() {
                        _anvisaAlerts = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildNotificationSwitch(
                    title: 'Alertas sobre novas receitas',
                    value: _prescriptionAlerts,
                    onChanged: (value) {
                      setState(() {
                        _prescriptionAlerts = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





