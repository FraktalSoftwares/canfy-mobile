import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:convert';
import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../models/consultation/consultation_model.dart';
import '../../../widgets/consultation/consultation_widgets.dart';

class NewConsultationStep3Page extends StatefulWidget {
  final NewConsultationFormData? formData;

  const NewConsultationStep3Page({super.key, this.formData});

  @override
  State<NewConsultationStep3Page> createState() =>
      _NewConsultationStep3PageState();
}

class _NewConsultationStep3PageState extends State<NewConsultationStep3Page> {
  final PatientService _patientService = PatientService();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();

  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String? _patientAvatar;
  bool _isLoadingAvatar = true;
  bool _isLoadingAddress = true;
  bool _isLoadingCep = false;

  NewConsultationFormData get _formData =>
      widget.formData ?? NewConsultationFormData();

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>?;
        final profile = data?['profile'] as Map<String, dynamic>?;
        final paciente = data?['paciente'] as Map<String, dynamic>?;

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

        // Carregar endereço do paciente se disponível
        if (paciente != null && mounted) {
          final endereco = paciente['endereco'] as String? ?? '';
          final cidade = paciente['cidade'] as String? ?? '';
          final estado = paciente['estado'] as String? ?? '';
          final cep = paciente['cep'] as String? ?? '';

          String logradouro = endereco;
          String numero = '';
          String bairro = '';

          if (endereco.isNotEmpty) {
            final parts = endereco.split(',').map((e) => e.trim()).toList();
            if (parts.isNotEmpty) {
              logradouro = parts[0];
            }
            if (parts.length > 1) {
              final possibleNumber = parts[1];
              if (RegExp(r'^\d+').hasMatch(possibleNumber)) {
                numero = possibleNumber;
              } else {
                bairro = possibleNumber;
              }
            }
            if (parts.length > 2) {
              bairro = parts[2];
            }
          }

          setState(() {
            if (logradouro.isNotEmpty) _streetController.text = logradouro;
            if (numero.isNotEmpty) _numberController.text = numero;
            if (bairro.isNotEmpty) _neighborhoodController.text = bairro;
            if (cidade.isNotEmpty) _cityController.text = cidade;
            if (estado.isNotEmpty) _stateController.text = estado;
            if (cep.isNotEmpty) _zipCodeController.text = cep;
            _isLoadingAddress = false;
          });
        } else {
          setState(() {
            _isLoadingAddress = false;
          });
        }
      } else {
        setState(() {
          _isLoadingAvatar = false;
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingAvatar = false;
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) return;

    setState(() {
      _isLoadingCep = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'),
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data['erro'] != true) {
          setState(() {
            _streetController.text = data['logradouro'] ?? '';
            _neighborhoodController.text = data['bairro'] ?? '';
            _cityController.text = data['localidade'] ?? '';
            _stateController.text = data['uf'] ?? '';
          });
        }
      }
    } catch (e) {
      // Silently fail - user can fill manually
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCep = false;
        });
      }
    }
  }

  bool _isFormValid() {
    return !_isLoadingAddress &&
        !_isLoadingCep &&
        _streetController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _neighborhoodController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty &&
        _stateController.text.trim().isNotEmpty &&
        _zipCodeController.text.trim().isNotEmpty;
  }

  void _goToNextStep() {
    final billingAddress = BillingAddress(
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      complement: _complementController.text.trim().isNotEmpty
          ? _complementController.text.trim()
          : null,
    );
    final updatedFormData = _formData.copyWith(
      billingAddress: billingAddress,
    );
    context.push(
      '/patient/consultations/new/step4',
      extra: updatedFormData,
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
                  const ConsultationStepIndicator(currentStep: 3),
                  const SizedBox(height: 20),

                  // Step header
                  ConsultationStepHeader(
                    stepNumber: 3,
                    stepTitle: 'Endereço de cobrança',
                    valueText: 'Valor: ${_formData.formattedValue}',
                  ),
                  const SizedBox(height: 24),

                  // Summary card
                  _buildSummaryCard(),
                  const SizedBox(height: 16),

                  // Address form
                  _buildAddressForm(),
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
                onPressed: _isFormValid() ? _goToNextStep : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return ConsultationSectionCard(
      title: 'Resumo da consulta',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConsultationDetailRow(
            label: 'Dia e horário',
            value: _formData.formattedDateTime,
          ),
          ConsultationDetailRow(
            label: 'Valor da consulta',
            value: _formData.formattedValue,
          ),
          const Text(
            'Queixas principais',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _formData.symptoms
                .map((symptom) => ConsultationSymptomTag(
                      symptom: symptom,
                      isReadOnly: true,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return ConsultationSectionCard(
      title: 'Endereço de cobrança',
      child: Column(
        children: [
          // CEP
          ConsultationTextField(
            label: 'CEP',
            controller: _zipCodeController,
            hintText: '00000-000',
            keyboardType: TextInputType.number,
            inputFormatters: [_cepMaskFormatter],
            isLoading: _isLoadingCep,
            onChanged: (value) {
              setState(() {});
              final cleanCep = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (cleanCep.length == 8) {
                _searchCep(cleanCep);
              }
            },
          ),
          const SizedBox(height: 16),

          // Logradouro e Número
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ConsultationTextField(
                  label: 'Logradouro',
                  controller: _streetController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ConsultationTextField(
                  label: 'Nº',
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bairro
          ConsultationTextField(
            label: 'Bairro',
            controller: _neighborhoodController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Cidade e Estado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ConsultationTextField(
                  label: 'Cidade',
                  controller: _cityController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: ConsultationTextField(
                  label: 'UF',
                  controller: _stateController,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Complemento
          ConsultationTextField(
            label: 'Complemento (opcional)',
            controller: _complementController,
          ),
        ],
      ),
    );
  }
}
