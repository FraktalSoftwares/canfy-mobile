import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class PreConsultationPage extends StatefulWidget {
  /// Consulta a ser atendida (mapa retornado por medico_listar_atendimentos),
  /// recebida via GoRouter `extra`.
  final Map<String, dynamic>? consulta;

  const PreConsultationPage({super.key, this.consulta});

  @override
  State<PreConsultationPage> createState() => _PreConsultationPageState();
}

class _PreConsultationPageState extends State<PreConsultationPage> {
  final MedicoService _medicoService = MedicoService();
  bool _iniciando = false;

  Map<String, dynamic>? get _consulta =>
      widget.consulta ??
      (GoRouterState.of(context).extra as Map<String, dynamic>?);

  Future<void> _iniciarAtendimento(Map<String, dynamic> consulta) async {
    final id = consulta['id'] as String;
    setState(() => _iniciando = true);
    // Marca em andamento (idempotente se já estiver).
    await _medicoService.atualizarStatusConsulta(id, 'em_andamento');
    if (!mounted) return;
    setState(() => _iniciando = false);
    context.go('/appointment/live/$id', extra: consulta);
  }

  @override
  Widget build(BuildContext context) {
    final consulta = _consulta;
    final paciente = (consulta?['paciente_nome'] as String?)?.trim();
    final queixa = (consulta?['queixa_principal'] as String?)?.trim();
    final dt = DateTime.tryParse(consulta?['data_consulta']?.toString() ?? '');

    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTokens.neutral900),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/appointment');
            }
          },
        ),
        title: Text(
          'Pré-consulta',
          style: AppTextStyles.bodySm(
            color: AppTokens.neutral900,
            weight: AppTokens.weightSemibold,
          ),
        ),
        centerTitle: true,
        actions: const [DoctorAppBarAvatar()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Pré-consulta',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTokens.neutral050,
                borderRadius: BorderRadius.circular(AppTokens.radius16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoLabel('Paciente'),
                  const SizedBox(height: 4),
                  Text(
                    paciente?.isNotEmpty == true ? paciente! : 'Paciente',
                    style: AppTextStyles.bodyMd(
                      color: AppTokens.neutral900,
                      weight: AppTokens.weightSemibold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoRow('Data:',
                      dt != null ? _fmtDate(dt) : 'A definir'),
                  const SizedBox(height: 4),
                  _infoRow('Principal queixa:',
                      queixa?.isNotEmpty == true ? queixa! : 'Não informada'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Iniciar atendimento',
              isLoading: _iniciando,
              onPressed: consulta == null
                  ? null
                  : () => _iniciarAtendimento(consulta),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTokens.green100,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTokens.green900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Disponível 10 minutos antes do horário',
                      style: AppTextStyles.bodyXs(
                        color: AppTokens.green900,
                        weight: AppTokens.weightSemibold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _infoLabel(String text) =>
      Text(text, style: AppTextStyles.bodySm(color: AppTokens.neutral600));

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySm(
              color: AppTokens.neutral900,
              weight: AppTokens.weightSemibold,
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
