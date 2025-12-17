import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsultationDetailsPage extends StatelessWidget {
  final String consultationId;
  const ConsultationDetailsPage({super.key, required this.consultationId});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final consultation = {
      'id': consultationId,
      'date': '01/09/25',
      'time': '09:30',
      'status': 'Agendada',
      'doctorName': 'Dr Luiz Carlos Souza',
      'doctorSpecialty': 'Clínico geral',
      'doctorAvatar': 'assets/images/avatar_pictures.png',
      'mainComplaint': 'Insônia, Estresse',
      'prescription': {
        'emissionDate': '01/09/25',
        'validityDate': '01/10/25',
        'product': 'Óleo Canabidiol 20mg/ml',
        'prescribedBy': 'Dr. Luiz Carlos Souza',
        'observations': 'Tomar 1ml, 2 vezes ao dia (manhã e noite).',
      },
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708, // 90 graus
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Transform.rotate(
                angle: -1.5708, // -90 graus para compensar
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/consultations');
            }
          },
        ),
        title: const Text(
          'Detalhes da consulta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.push('/patient/account');
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/avatar_pictures.png'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de informações da consulta
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E7F1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${consultation['id']} • ${consultation['date']} • ${consultation['time']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E68C),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Agendada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF654C01),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: AssetImage(consultation['doctorAvatar'] as String),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consultation['doctorName'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF212121),
                              ),
                            ),
                            Text(
                              consultation['doctorSpecialty'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7C7C79),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                          angle: 4.7124, // 270 graus
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F8EF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Transform.rotate(
                              angle: -4.7124, // -270 graus para compensar
                              child: const Icon(Icons.chevron_right, color: Colors.black, size: 20),
                            ),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to doctor profile
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Principal queixa:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        consultation['mainComplaint'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Card de detalhes da receita
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E7F1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalhes da receita',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Emissão:', (consultation['prescription'] as Map<String, dynamic>)['emissionDate'] as String),
                  _buildDetailRow('Validade:', (consultation['prescription'] as Map<String, dynamic>)['validityDate'] as String),
                  _buildDetailRow('Produto:', (consultation['prescription'] as Map<String, dynamic>)['product'] as String),
                  _buildDetailRow('Prescrito por:', (consultation['prescription'] as Map<String, dynamic>)['prescribedBy'] as String),
                  const SizedBox(height: 8),
                  const Text(
                    'Observações:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (consultation['prescription'] as Map<String, dynamic>)['observations'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Botões de ação
            if (consultation['status'] == 'Agendada') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/patient/consultations/live/$consultationId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BB5A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Iniciar consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    // Show cancel consultation modal
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancelar consulta'),
                        content: const Text('Tem certeza que deseja cancelar esta consulta?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Não'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Cancel consultation logic
                            },
                            child: const Text('Sim'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE53935)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cancelar consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ),
            ] else if (consultation['status'] == 'Finalizada') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // View prescription details
                    context.push('/patient/prescriptions');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7048C3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Ver receita',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

