import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../models/order/new_order_form_data.dart';
import '../../../services/api/docusign_service.dart';
import '../../../services/api/patient_service.dart';
import '../../../widgets/patient/new_order_step_header.dart';
import '../../../widgets/patient/new_order_step_progress.dart';
import '../../../widgets/patient/patient_app_bar.dart';

/// Etapa opcional do fluxo de novo pedido: assinatura da procuração Canfy
/// via DocuSign.
class ProcuracaoDocusignPage extends StatefulWidget {
  final NewOrderFormData? formData;

  const ProcuracaoDocusignPage({super.key, this.formData});

  @override
  State<ProcuracaoDocusignPage> createState() =>
      _ProcuracaoDocusignPageState();
}

class _ProcuracaoDocusignPageState extends State<ProcuracaoDocusignPage> {
  final PatientService _patientService = PatientService();
  final DocusignService _docusignService = DocusignService();

  final _nomeController = TextEditingController();
  final _nacionalidadeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _numeroController = TextEditingController();
  final _cepController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _bairroController = TextEditingController();

  bool _loading = true;
  bool _assinando = false;
  bool _assinaturaConcluida = false;
  String? _erro;
  bool? _naoConfigurado;
  String? _envelopeId;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nacionalidadeController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _enderecoController.dispose();
    _numeroController.dispose();
    _cepController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    final res = await _patientService.getCurrentPatient();
    if (!mounted) return;
    final data = res['data'] as Map<String, dynamic>?;
    final profile = data?['profile'] as Map<String, dynamic>?;
    final paciente = data?['paciente'] as Map<String, dynamic>?;
    _nomeController.text = profile?['nome_completo'] as String? ?? '';
    _nacionalidadeController.text =
        paciente?['nacionalidade'] as String? ?? 'Brasileiro';
    _cpfController.text = paciente?['cpf'] as String? ?? '';
    _rgController.text = paciente?['rg'] as String? ?? '';
    _enderecoController.text =
        paciente?['endereco_logradouro'] as String? ?? '';
    _numeroController.text = paciente?['endereco_numero'] as String? ?? '';
    _cepController.text = paciente?['cep'] as String? ?? '';
    _estadoController.text = paciente?['estado'] as String? ?? '';
    _cidadeController.text = paciente?['cidade'] as String? ?? '';
    _bairroController.text = paciente?['bairro'] as String? ?? '';
    setState(() => _loading = false);
  }

  void _continuar() {
    final updated = (widget.formData ?? NewOrderFormData(
      prescriptionId: '',
      productName: '',
      doctorName: '',
      valorTotal: 0,
    )).copyWith(
      procuracaoAssinada: _assinaturaConcluida,
      procuracaoEnvelopeId: _envelopeId,
    );
    context.push('/patient/orders/new/step4', extra: updated);
  }

  Future<void> _assinarProcuracao() async {
    setState(() {
      _assinando = true;
      _erro = null;
      _naoConfigurado = null;
    });
    final res = await _docusignService.getSigningUrl();
    if (!mounted) return;
    if (res['success'] != true) {
      setState(() {
        _assinando = false;
        _naoConfigurado = res['notConfigured'] == true;
        _erro = _naoConfigurado == true
            ? 'A assinatura digital via DocuSign ainda não está configurada. Você pode continuar sem assinar agora.'
            : (res['message'] as String? ?? 'Erro ao gerar link de assinatura.');
      });
      return;
    }
    final data = res['data'] as Map<String, dynamic>;
    final url = data['url'] as String;
    final envelopeId = data['envelopeId'] as String?;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!mounted) return;
    setState(() {
      _assinando = false;
      _assinaturaConcluida = true;
      _envelopeId = envelopeId;
    });
  }

  Widget _field(String label, TextEditingController controller,
      {IconData icon = Icons.person_outline}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral900)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14, color: AppColors.neutral900),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: AppColors.neutral600),
              filled: true,
              fillColor: AppColors.neutral050,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.neutral300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.neutral300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.canfyGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Procuração',
        fallbackRoute: '/patient/orders/new/step3',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const NewOrderStepProgress(currentStep: 3),
                  const SizedBox(height: 24),
                  const NewOrderStepHeader(
                    stepLabel: 'Etapa opcional - Procuração',
                    valueText: 'DocuSign',
                  ),
                  const SizedBox(height: 24),
                  if (_assinaturaConcluida) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: AppColors.neutral050,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.canfyGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 24),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Assinatura iniciada no navegador. Assim que você'
                              ' concluir a assinatura da procuração, poderá'
                              ' continuar com o seu pedido.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: AppColors.neutral600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined,
                            color: AppColors.canfyGreen, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'DocuSign',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Procuração Canfy',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral900),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Preencha os dados abaixo para assinar a procuração.',
                      style: TextStyle(fontSize: 14, color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 24),
                    _field('Nome Completo', _nomeController),
                    _field('Nacionalidade', _nacionalidadeController),
                    _field('CPF', _cpfController, icon: Icons.badge_outlined),
                    _field('RG', _rgController, icon: Icons.badge_outlined),
                    Row(
                      children: [
                        Expanded(
                            child: _field('Endereço', _enderecoController,
                                icon: Icons.location_on_outlined)),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 90,
                          child: _field('Número', _numeroController),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field('CEP', _cepController)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Estado', _estadoController)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: _field('Cidade', _cidadeController)),
                        const SizedBox(width: 12),
                        Expanded(child: _field('Bairro', _bairroController)),
                      ],
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: 8),
                      Text(_erro!,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.error)),
                    ],
                  ],
                  const SizedBox(height: 24),
                  if (!_assinaturaConcluida)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _assinando ? null : _assinarProcuracao,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.canfyGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: _assinando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Assinar procuração'),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _continuar,
                      child: Text(
                        _assinaturaConcluida
                            ? 'Continuar'
                            : 'Pular por agora',
                        style: const TextStyle(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
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
