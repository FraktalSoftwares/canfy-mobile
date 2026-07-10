import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _loadingContexto = true;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _anamnese;
  List<Map<String, dynamic>> _consultasAnteriores = [];

  bool _resumoExpandido = false;
  bool _canabinoidesExpandido = false;

  Map<String, dynamic>? get _consulta =>
      widget.consulta ??
      (GoRouterState.of(context).extra as Map<String, dynamic>?);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContexto());
  }

  Future<void> _loadContexto() async {
    final consultaId = _consulta?['id'] as String?;
    if (consultaId == null) {
      setState(() => _loadingContexto = false);
      return;
    }
    final res = await _medicoService.getProntuarioContexto(consultaId);
    if (!mounted) return;
    final data = res['data'] as Map<String, dynamic>?;
    final paciente = data?['paciente'] as Map<String, dynamic>?;
    List<Map<String, dynamic>> anteriores = [];
    final pacienteId = paciente?['id'] as String?;
    if (pacienteId != null) {
      anteriores = await _medicoService.getConsultasAnteriores(
        pacienteId,
        excludeConsultaId: consultaId,
      );
    }
    if (!mounted) return;
    setState(() {
      _profile = data?['profile'] as Map<String, dynamic>?;
      _anamnese = data?['anamnese'] as Map<String, dynamic>?;
      _consultasAnteriores = anteriores;
      _loadingContexto = false;
    });
  }

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
    final telefone = (_profile?['telefone'] as String?)?.trim();
    final sintomas =
        (consulta?['sintomas'] as List?)?.cast<String>() ?? const <String>[];
    final peso = _anamnese?['peso'];
    final altura = _anamnese?['altura'];

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
      body: _loadingContexto
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Pré-consulta',
                      style:
                          AppTextStyles.headingMd(color: AppTokens.neutral900)),
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
                        _infoRow('Telefone:',
                            telefone?.isNotEmpty == true ? telefone! : '--'),
                        const SizedBox(height: 4),
                        _infoRow('Principal queixa:',
                            queixa?.isNotEmpty == true ? queixa! : 'Não informada'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Informações do paciente',
                      style:
                          AppTextStyles.headingSm(color: AppTokens.neutral900)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTokens.neutral050,
                      borderRadius: BorderRadius.circular(AppTokens.radius16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoLabel('Queixas'),
                        const SizedBox(height: 8),
                        if (sintomas.isEmpty)
                          Text('Não informado',
                              style: AppTextStyles.bodySm(
                                  color: AppTokens.neutral900,
                                  weight: AppTokens.weightSemibold))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: sintomas
                                .map((s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                            color: AppTokens.green800),
                                      ),
                                      child: Text(s,
                                          style: AppTextStyles.bodyXs(
                                              color: AppTokens.green900,
                                              weight:
                                                  AppTokens.weightSemibold)),
                                    ))
                                .toList(),
                          ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoLabel('Peso'),
                                  const SizedBox(height: 4),
                                  Text(
                                    peso != null ? '$peso kg' : 'Não informado',
                                    style: AppTextStyles.bodySm(
                                        color: AppTokens.neutral900,
                                        weight: AppTokens.weightSemibold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoLabel('Altura'),
                                  const SizedBox(height: 4),
                                  Text(
                                    altura != null
                                        ? '$altura cm'
                                        : 'Não informado',
                                    style: AppTextStyles.bodySm(
                                        color: AppTokens.neutral900,
                                        weight: AppTokens.weightSemibold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (queixa?.isNotEmpty == true) ...[
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _infoLabel('Sintomas'),
                          const SizedBox(height: 4),
                          Text(queixa!,
                              style: AppTextStyles.bodySm(
                                  color: AppTokens.neutral900)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _accordionCard(
                    title: 'Resumo médico',
                    expanded: _resumoExpandido,
                    onTap: () =>
                        setState(() => _resumoExpandido = !_resumoExpandido),
                    child: _resumoMedicoContent(),
                  ),
                  const SizedBox(height: 16),
                  _accordionCard(
                    title: 'Uso de canabinoides',
                    expanded: _canabinoidesExpandido,
                    onTap: () => setState(
                        () => _canabinoidesExpandido = !_canabinoidesExpandido),
                    child: _canabinoidesContent(),
                  ),
                  if (_consultasAnteriores.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Consultas anteriores',
                        style: AppTextStyles.headingSm(
                            color: AppTokens.neutral900)),
                    const SizedBox(height: 12),
                    ..._consultasAnteriores.map(_consultaAnteriorCard),
                  ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _accordionCard({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMd(
                      color: AppTokens.neutral800,
                      weight: AppTokens.weightSemibold,
                    )),
                Icon(
                  expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTokens.neutral800,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }

  Widget _anamneseSection(String titulo, String pergunta, bool? tem,
      String? detalhes) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: AppTextStyles.bodySm(
                  color: AppTokens.green900, weight: AppTokens.weightSemibold)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('$pergunta ',
                  style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
              Text(
                tem == true ? 'Sim' : (tem == false ? 'Não' : 'Não informado'),
                style: AppTextStyles.bodySm(
                    color: AppTokens.neutral900,
                    weight: AppTokens.weightSemibold),
              ),
            ],
          ),
          if (tem == true && detalhes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: 'Detalhes: ',
                      style: AppTextStyles.bodySm(
                          color: AppTokens.neutral800,
                          weight: AppTokens.weightSemibold)),
                  TextSpan(
                      text: detalhes,
                      style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _resumoMedicoContent() {
    if (_anamnese == null) {
      return Text('Paciente ainda não preencheu o histórico de saúde.',
          style: AppTextStyles.bodySm(color: AppTokens.neutral600));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _anamneseSection('Alergias', 'Possui alergias:',
            _anamnese?['tem_alergias'] as bool?,
            _anamnese?['alergias_detalhes'] as String?),
        _anamneseSection('Comorbidades', 'Possui comorbidades:',
            _anamnese?['tem_comorbidades'] as bool?,
            _anamnese?['comorbidades_detalhes'] as String?),
        _anamneseSection('Tratamentos Adicionais',
            'Está fazendo outros tratamentos:',
            _anamnese?['tem_tratamentos_anteriores'] as bool?,
            _anamnese?['tratamentos_anteriores_detalhes'] as String?),
        _anamneseSection('Medicamentos', 'Faz uso de algum medicamento:',
            _anamnese?['tem_medicacoes_atuais'] as bool?,
            _anamnese?['medicacoes_atuais_detalhes'] as String?),
      ],
    );
  }

  Widget _canabinoidesContent() {
    final produtos = (_anamnese?['produtos_cannabis_utilizados'] as String?)
            ?.trim() ??
        '';
    final reacoes = _anamnese?['tem_reacoes_adversas'] as bool?;
    final reacoesDetalhes = _anamnese?['reacoes_adversas_detalhes'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Produtos já utilizados:',
            style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
        const SizedBox(height: 4),
        Text(
          produtos.isNotEmpty ? produtos : 'Nunca utilizou',
          style: AppTextStyles.bodySm(
              color: AppTokens.neutral900, weight: AppTokens.weightSemibold),
        ),
        const SizedBox(height: 12),
        _anamneseSection('Reações adversas', 'Já teve reação adversa:',
            reacoes, reacoesDetalhes),
      ],
    );
  }

  Widget _consultaAnteriorCard(Map<String, dynamic> c) {
    final dt = DateTime.tryParse(c['data_consulta']?.toString() ?? '');
    final queixa = (c['queixa_principal'] as String?)?.trim();
    final documentoUrl = c['documento_url'] as String?;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dt != null ? _fmtDate(dt) : '--',
              style: AppTextStyles.bodySm(
                  color: AppTokens.neutral600,
                  weight: AppTokens.weightSemibold)),
          const SizedBox(height: 4),
          _infoRow('Principal queixa:',
              queixa?.isNotEmpty == true ? queixa! : 'Não informada'),
          if (documentoUrl != null && documentoUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final uri = Uri.tryParse(documentoUrl);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTokens.green800),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined,
                        color: AppTokens.green800, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('receita_médica.pdf',
                          style: AppTextStyles.bodyXs(
                              color: AppTokens.green800,
                              weight: AppTokens.weightSemibold)),
                    ),
                    const Icon(Icons.download_outlined,
                        color: AppTokens.green800, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
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
