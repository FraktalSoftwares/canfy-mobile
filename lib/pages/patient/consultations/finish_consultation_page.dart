import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class FinishConsultationPage extends StatefulWidget {
  final String consultationId;
  const FinishConsultationPage({super.key, required this.consultationId});

  @override
  State<FinishConsultationPage> createState() => _FinishConsultationPageState();
}

class _FinishConsultationPageState extends State<FinishConsultationPage> {
  final TextEditingController _summaryController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Finalização da consulta',
        fallbackRoute: '/patient/consultations',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo da consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Consulta realizada com Dr. Luiz Carlos Souza em 01/09/25 às 10:00',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Card de avaliação
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
                    'Avalie a consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            size: 48,
                            color: index < _rating
                                ? const Color(0xFFF9CF58)
                                : const Color(0xFFD6D6D3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Resumo (opcional)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _summaryController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Descreva como foi sua experiência...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF7048C3)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Finalize consultation logic
                  context.go('/patient/consultations');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BB5A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Finalizar atendimento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
