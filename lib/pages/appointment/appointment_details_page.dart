import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class AppointmentDetailsPage extends StatefulWidget {
  const AppointmentDetailsPage({super.key});

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  final MedicoService _medicoService = MedicoService();
  static const String _valorConsulta = r'R$ 200,00';

  Map<String, dynamic>? _consulta;
  Map<String, dynamic>? _detalhe;
  bool _loading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map<String, dynamic>) _consulta = extra;
    _load();
  }

  Future<void> _load() async {
    final id = _consulta?['id'] as String?;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final res = await _medicoService.getAtendimentoDetalhe(id);
    if (!mounted) return;
    setState(() {
      _detalhe = res['data'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paciente = (_consulta?['paciente_nome'] as String?)?.trim();
    final queixa = (_consulta?['queixa_principal'] as String?)?.trim();
    final dt = DateTime.tryParse(_consulta?['data_consulta']?.toString() ?? '');
    final resumo = _detalhe?['resumo'] as String?;
    final receita = _detalhe?['receita'] as Map<String, dynamic>?;
    final itens = (_detalhe?['itens'] as List?)?.cast<Map<String, dynamic>>() ?? [];

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
        title: Text('Detalhes da consulta',
            style: AppTextStyles.bodySm(
              color: AppTokens.neutral900,
              weight: AppTokens.weightSemibold,
            )),
        centerTitle: true,
        actions: const [DoctorAppBarAvatar()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dt != null ? _fmtDateTime(dt) : 'Consulta',
                                style: AppTextStyles.bodySm(
                                  color: AppTokens.neutral900,
                                  weight: AppTokens.weightSemibold,
                                ),
                              ),
                            ),
                            _statusChip(_consulta?['status'] as String? ?? ''),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Paciente',
                            style: AppTextStyles.bodySm(
                                color: AppTokens.neutral600)),
                        const SizedBox(height: 4),
                        Text(
                          paciente?.isNotEmpty == true ? paciente! : 'Paciente',
                          style: AppTextStyles.bodyMd(
                            color: AppTokens.neutral900,
                            weight: AppTokens.weightSemibold,
                          ),
                        ),
                        if (queixa?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          _inline('Principal queixa:', queixa!),
                        ],
                        const SizedBox(height: 12),
                        _inline('Valor da consulta:', _valorConsulta),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (receita != null) ...[
                    Text('Receita médica',
                        style:
                            AppTextStyles.headingSm(color: AppTokens.neutral900)),
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _inline('Nº:',
                              receita['numero_receita']?.toString() ?? '--'),
                          const SizedBox(height: 4),
                          _inline('Validade:',
                              _fmtDateOnly(receita['validade']?.toString())),
                          if ((receita['observacoes'] as String?)
                                  ?.trim()
                                  .isNotEmpty ==
                              true) ...[
                            const SizedBox(height: 8),
                            Text(receita['observacoes'] as String,
                                style: AppTextStyles.bodySm(
                                    color: AppTokens.neutral600)),
                          ],
                          const Divider(height: 24),
                          ...itens.map((it) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it['produto_nome']?.toString() ?? 'Produto',
                                        style: AppTextStyles.bodyMd(
                                          color: AppTokens.neutral900,
                                          weight: AppTokens.weightSemibold,
                                        )),
                                    if ((it['posologia'] as String?)
                                            ?.trim()
                                            .isNotEmpty ==
                                        true)
                                      Text(it['posologia'] as String,
                                          style: AppTextStyles.bodySm(
                                              color: AppTokens.neutral600)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (resumo?.trim().isNotEmpty == true) ...[
                    Text('Observações',
                        style:
                            AppTextStyles.headingSm(color: AppTokens.neutral900)),
                    const SizedBox(height: 12),
                    _card(
                      child: Text(resumo!,
                          style:
                              AppTextStyles.bodySm(color: AppTokens.neutral600)),
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTokens.neutral050,
          borderRadius: BorderRadius.circular(AppTokens.radius16),
        ),
        child: child,
      );

  Widget _inline(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodySm(
                  color: AppTokens.neutral900,
                  weight: AppTokens.weightSemibold,
                )),
          ),
        ],
      );

  Widget _statusChip(String status) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case 'finalizada':
        bg = AppTokens.green100;
        fg = AppTokens.green900;
        label = 'Concluída';
        break;
      case 'cancelada':
        bg = AppTokens.neutral200;
        fg = AppTokens.neutral700;
        label = 'Cancelada';
        break;
      case 'em_andamento':
        bg = AppTokens.blue100;
        fg = AppTokens.blue900;
        label = 'Em andamento';
        break;
      default:
        bg = AppTokens.green100;
        fg = AppTokens.green900;
        label = 'Agendada';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(label,
          style: AppTextStyles.bodyXs(color: fg, weight: AppTokens.weightSemibold)),
    );
  }

  String _fmtDateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${two(d.year % 100)} • ${two(d.hour)}:${two(d.minute)}';
  }

  String _fmtDateOnly(String? iso) {
    if (iso == null) return '--';
    final d = DateTime.tryParse(iso);
    if (d == null) return '--';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}
