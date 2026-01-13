import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/safe_image_asset.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';

class AppointmentDetailsPage extends StatelessWidget {
  const AppointmentDetailsPage({super.key});

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
              context.go('/appointment');
            }
          },
        ),
        title: const Text(
          'Detalhes da consulta',
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
            const SizedBox(height: 16),
            // Card da consulta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '#12345 • 01/09/25 • 09:30',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF66DDA2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Concluída',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF174F38),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Paciente',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7C7C79),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Laura Flores',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Principal queixa:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7C7C79),
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Insônia',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert,
                            color: Color(0xFF00994B)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text(
                        'Valor da consulta:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'R\$100,00',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Card de receita
            _buildPrescriptionCard(),
            const SizedBox(height: 16),
            // Card de observações
            _buildObservationsCard(),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(
        currentIndex: 1, // Atendimento tab is active
      ),
    );
  }

  Widget _buildPrescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receita médica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: SafeImageAsset(
                  imagePath:
                      'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
                  fit: BoxFit.contain,
                  placeholderIcon: Icons.local_pharmacy,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Formas de uso:', value: 'Óleo'),
                    SizedBox(height: 4),
                    _InfoRow(label: 'Dosagem:', value: '20mg/ml'),
                    SizedBox(height: 4),
                    _InfoRow(label: 'Concentração:', value: '20mg/ml de THC'),
                    SizedBox(height: 4),
                    _InfoRow(label: 'Data de emissão:', value: '05/09/2025'),
                    SizedBox(height: 4),
                    _InfoRow(label: 'Validade:', value: '04/03/2026 (6 meses)'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Indicado para:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(text: 'Insônia'),
              _Tag(text: 'Ansiedade'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Paciente relatou melhora significativa após início do tratamento. Manter acompanhamento mensal.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
        ],
      ),
    );
  }

}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7C7C79),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F8EF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF00994B),
        ),
      ),
    );
  }
}
