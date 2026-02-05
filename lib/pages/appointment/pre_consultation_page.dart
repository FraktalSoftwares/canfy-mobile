import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class PreConsultationPage extends StatelessWidget {
  const PreConsultationPage({super.key});

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
              context.go('/appointment');
            }
          },
        ),
        title: const Text(
          'Pré-consulta',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: const [
          DoctorAppBarAvatar(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Pré-consulta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Card do paciente
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right,
                            color: Colors.transparent),
                        onPressed: null,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Telefone:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(99) 99999-9999',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 32),
            const Text(
              'Consultas anteriores',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            // Consultas anteriores
            _buildPreviousConsultation('01/04/2025', 'Insônia'),
            const SizedBox(height: 16),
            _buildPreviousConsultation('01/04/2025', 'Insônia'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/appointment/live-consultation');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00994B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Iniciar atendimento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF33CC80),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.video_call, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Expanded(
                    child: Text(
                      'Disponível 10 minutos antes do horário',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.info_outline, color: Colors.white, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(
        currentIndex: 1, // Atendimento tab is active
      ),
    );
  }

  Widget _buildPreviousConsultation(String date, String complaint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Principal queixa:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C79),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                complaint,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F5),
              border: Border.all(color: const Color(0xFF33CC80)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Color(0xFF00994B)),
                  onPressed: () {},
                ),
                const Expanded(
                  child: Text(
                    'receita_médica.pdf',
                    style: TextStyle(
                      color: Color(0xFF00994B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Color(0xFF00994B)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
