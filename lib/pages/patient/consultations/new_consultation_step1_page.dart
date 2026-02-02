import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../models/consultation/consultation_model.dart';
import '../../../widgets/consultation/consultation_widgets.dart';

class NewConsultationStep1Page extends StatefulWidget {
  const NewConsultationStep1Page({super.key});

  @override
  State<NewConsultationStep1Page> createState() =>
      _NewConsultationStep1PageState();
}

class _NewConsultationStep1PageState extends State<NewConsultationStep1Page> {
  final PatientService _patientService = PatientService();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedSymptoms = [];

  String? _patientAvatar;
  bool _isLoadingAvatar = true;

  final List<String> _symptoms = [
    'Ansiedade',
    'Insônia',
    'Estresse',
    'Dor crônica',
    'Epilepsia',
    'TDAM',
    'Autismo',
    'Depressão',
    'PTSD',
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientAvatar();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientAvatar() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>?;
        final profile = data?['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          setState(() {
            _patientAvatar = profile['foto_perfil_url'] as String?;
            _isLoadingAvatar = false;
          });
        } else {
          setState(() {
            _isLoadingAvatar = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAvatar = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAvatar = false;
      });
    }
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        if (_selectedSymptoms.length < 2) {
          _selectedSymptoms.add(symptom);
        }
      }
    });
  }

  void _goToNextStep() {
    final formData = NewConsultationFormData(
      symptoms: List<String>.from(_selectedSymptoms),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );
    context.push(
      '/patient/consultations/new/step2',
      extra: formData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ConsultationAppBar(
        avatarWidget: ConsultationAvatar(
          avatarUrl: _patientAvatar,
          isLoading: _isLoadingAvatar,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  const ConsultationStepIndicator(currentStep: 1),
                  const SizedBox(height: 20),

                  // Step header
                  const ConsultationStepHeader(
                    stepNumber: 1,
                    stepTitle: 'Motivo da consulta',
                    valueText: 'Valor: R\$ 200,00',
                  ),
                  const SizedBox(height: 24),

                  // Symptoms selection
                  ConsultationSectionCard(
                    title: 'Sintomas',
                    subtitle:
                        'Marque até 2 sintomas que melhor descrevem seu caso',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _symptoms
                          .map((symptom) => ConsultationSymptomTag(
                                symptom: symptom,
                                isSelected: _selectedSymptoms.contains(symptom),
                                onTap: () => _toggleSymptom(symptom),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  ConsultationSectionCard(
                    title: 'Descrição',
                    subtitle: 'Ajude o médico a entender melhor seu caso',
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.neutral900,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Descreva seus sintomas e como eles afetam seu dia a dia...',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: AppColors.neutral600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.neutral200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.neutral200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.canfyPurple,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ConsultationPrimaryButton(
                text: 'Próximo',
                onPressed: _selectedSymptoms.isNotEmpty ? _goToNextStep : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
