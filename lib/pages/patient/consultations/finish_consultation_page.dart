import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class FinishConsultationPage extends StatefulWidget {
  final String consultationId;
  const FinishConsultationPage({super.key, required this.consultationId});

  @override
  State<FinishConsultationPage> createState() => _FinishConsultationPageState();
}

class _FinishConsultationPageState extends State<FinishConsultationPage> {
  final PatientService _patientService = PatientService();
  final TextEditingController _summaryController = TextEditingController();
  int _rating = 0;

  bool _loading = true;
  bool _submitting = false;
  Map<String, dynamic>? _consulta;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final res = await _patientService.getConsultationById(widget.consultationId);
    if (!mounted) return;
    setState(() {
      _consulta = res['success'] == true
          ? res['data'] as Map<String, dynamic>?
          : null;
      _loading = false;
    });
  }

  Future<void> _finalizar() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma avaliação de 1 a 5 estrelas.')),
      );
      return;
    }
    setState(() => _submitting = true);
    final pacienteId = _consulta?['pacienteId'] as String?;
    if (pacienteId != null) {
      await _patientService.avaliarConsulta(
        pacienteId: pacienteId,
        medicoId: _consulta?['medicoId'] as String?,
        nota: _rating,
        comentario: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
        dataConsulta: _consulta?['data_consulta_raw'],
      );
    }
    if (!mounted) return;
    context.go('/patient/consultations');
  }

  @override
  Widget build(BuildContext context) {
    final doctorName = _consulta?['doctorName'] as String? ?? 'Médico';
    final date = _consulta?['date'] as String? ?? '--';
    final time = _consulta?['time'] as String? ?? '--';
    final resumo = _consulta?['resumoAtendimento'] as String?;
    final prescription = _consulta?['prescription'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Finalização da consulta',
        fallbackRoute: '/patient/consultations',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        const Text(
                          'Resumo da consulta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Consulta realizada com $doctorName em $date às $time',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                        if (resumo != null && resumo.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            resumo,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3F3F3D),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (prescription != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EDFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC3A6F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Receita médica',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prescription['product'] as String? ?? 'Produto',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4E3390),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Validade: ${prescription['validityDate'] ?? '--'}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4E3390),
                            ),
                          ),
                          if ((prescription['documentoUrl'] as String?)
                                  ?.isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.tryParse(
                                      prescription['documentoUrl'] as String);
                                  if (uri != null) {
                                    await launchUrl(uri,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                                icon: const Icon(Icons.download_outlined,
                                    color: Color(0xFF4E3390)),
                                label: const Text('Baixar receita',
                                    style: TextStyle(color: Color(0xFF4E3390))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0xFFC3A6F9)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_border,
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
                              borderSide:
                                  const BorderSide(color: Color(0xFFE7E7F1)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE7E7F1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  const BorderSide(color: Color(0xFF7048C3)),
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
                      onPressed: _submitting ? null : _finalizar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BB5A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
