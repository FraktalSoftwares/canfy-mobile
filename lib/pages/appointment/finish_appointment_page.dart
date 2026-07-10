import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class FinishAppointmentPage extends StatefulWidget {
  const FinishAppointmentPage({super.key});

  @override
  State<FinishAppointmentPage> createState() => _FinishAppointmentPageState();
}

class _FinishAppointmentPageState extends State<FinishAppointmentPage> {
  final MedicoService _medicoService = MedicoService();
  final TextEditingController _resumo = TextEditingController();
  final TextEditingController _motivoInsatisfacao = TextEditingController();
  bool _finalizando = false;
  bool _loadingContexto = true;
  String? _consultaId;
  bool _initialized = false;
  int _avaliacaoNota = 0;

  Map<String, dynamic>? _receita;
  Map<String, dynamic>? _prontuario;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final extra = GoRouterState.of(context).extra;
    if (extra is String) _consultaId = extra;
    if (extra is Map) _consultaId = (extra['consultaId'] ?? extra['id']) as String?;
    _loadContexto();
  }

  Future<void> _loadContexto() async {
    if (_consultaId == null) {
      setState(() => _loadingContexto = false);
      return;
    }
    final detalhe = await _medicoService.getAtendimentoDetalhe(_consultaId!);
    final prontuarioRes = await _medicoService.getProntuario(_consultaId!);
    if (!mounted) return;
    setState(() {
      _receita = (detalhe['data'] as Map<String, dynamic>?)?['receita']
          as Map<String, dynamic>?;
      _prontuario = prontuarioRes['success'] == true
          ? prontuarioRes['data'] as Map<String, dynamic>?
          : null;
      _loadingContexto = false;
    });
  }

  @override
  void dispose() {
    _resumo.dispose();
    _motivoInsatisfacao.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    if (_consultaId == null) {
      context.go('/appointment');
      return;
    }
    setState(() => _finalizando = true);
    final res = await _medicoService.finalizarAtendimento(
      _consultaId!,
      resumo: _resumo.text.trim().isEmpty ? null : _resumo.text.trim(),
      avaliacaoNota: _avaliacaoNota > 0 ? _avaliacaoNota : null,
      avaliacaoComentario: _motivoInsatisfacao.text.trim().isEmpty
          ? null
          : _motivoInsatisfacao.text.trim(),
    );
    if (!mounted) return;
    setState(() => _finalizando = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Atendimento finalizado.')),
      );
      context.go('/appointment');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível finalizar o atendimento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prontuarioStatus = _prontuario?['status'] as String?;
    final prontuarioCompleto = prontuarioStatus == 'finalizado';

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
          'Finalização do atendimento',
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
                  Text('Finalização do atendimento',
                      style:
                          AppTextStyles.headingMd(color: AppTokens.neutral900)),
                  const SizedBox(height: 24),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resumo do atendimento',
                            style: AppTextStyles.bodyMd(
                                color: AppTokens.neutral900,
                                weight: AppTokens.weightSemibold)),
                        const SizedBox(height: 4),
                        Text(
                          'Registre um resumo do que foi tratado na consulta.',
                          style: AppTextStyles.bodySm(color: AppTokens.neutral600),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _resumo,
                          maxLines: 8,
                          style: AppTextStyles.bodySm(color: AppTokens.neutral900),
                          decoration: InputDecoration(
                            hintText: 'Descreva o atendimento...',
                            hintStyle:
                                AppTextStyles.bodySm(color: AppTokens.neutral500),
                            filled: true,
                            fillColor: AppTokens.neutral000,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radius16),
                              borderSide:
                                  const BorderSide(color: AppTokens.neutral300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radius16),
                              borderSide:
                                  const BorderSide(color: AppTokens.neutral300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTokens.radius16),
                              borderSide: const BorderSide(
                                  color: AppTokens.primary, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Receita',
                            style: AppTextStyles.bodyMd(
                                color: AppTokens.neutral900,
                                weight: AppTokens.weightSemibold)),
                        const SizedBox(height: 4),
                        Text(
                          'A receita ficará disponível no menu de receitas.',
                          style: AppTextStyles.bodySm(color: AppTokens.neutral600),
                        ),
                        const SizedBox(height: 16),
                        if (_receita == null)
                          Text('Nenhuma receita emitida nesta consulta.',
                              style: AppTextStyles.bodySm(
                                  color: AppTokens.neutral600))
                        else
                          InkWell(
                            onTap: () async {
                              final url = _receita?['documento_url'] as String?;
                              if (url != null) {
                                final uri = Uri.tryParse(url);
                                if (uri != null) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border:
                                    Border.all(color: AppTokens.green800),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.download_outlined,
                                      color: AppTokens.green800, size: 20),
                                  Text('Receita médica',
                                      style: AppTextStyles.bodySm(
                                          color: AppTokens.green800,
                                          weight: AppTokens.weightSemibold)),
                                  const Icon(Icons.send_outlined,
                                      color: AppTokens.green800, size: 20),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Como você avalia nosso atendimento?',
                            style: AppTextStyles.bodyMd(
                                color: AppTokens.neutral900,
                                weight: AppTokens.weightSemibold)),
                        const SizedBox(height: 4),
                        Text(
                          '(1 = muito insatisfeito, 5 = muito satisfeito)',
                          style: AppTextStyles.bodySm(color: AppTokens.neutral600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: List.generate(5, (index) {
                            final filled = index < _avaliacaoNota;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _avaliacaoNota = index + 1),
                                child: Icon(
                                  filled ? Icons.star : Icons.star_border,
                                  color: AppTokens.green800,
                                  size: 32,
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_avaliacaoNota > 0 && _avaliacaoNota <= 3) ...[
                          const SizedBox(height: 16),
                          Text('Conte o motivo da sua insatisfação',
                              style: AppTextStyles.bodyMd(
                                  color: AppTokens.neutral900,
                                  weight: AppTokens.weightSemibold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _motivoInsatisfacao,
                            maxLines: 4,
                            style: AppTextStyles.bodySm(
                                color: AppTokens.neutral900),
                            decoration: InputDecoration(
                              hintText:
                                  'Ex.: dificuldade de conexão, tempo de espera, não resolveu meu problema...',
                              hintStyle: AppTextStyles.bodySm(
                                  color: AppTokens.neutral500),
                              filled: true,
                              fillColor: AppTokens.neutral000,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radius16),
                                borderSide: const BorderSide(
                                    color: AppTokens.neutral300),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Prontuário do paciente',
                            style: AppTextStyles.bodyMd(
                                color: AppTokens.neutral900,
                                weight: AppTokens.weightSemibold)),
                        const SizedBox(height: 4),
                        Text(
                          prontuarioCompleto
                              ? 'O prontuário foi completo e assinado.'
                              : 'O prontuário ainda não foi finalizado.',
                          style: AppTextStyles.bodySm(color: AppTokens.neutral600),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _consultaId == null
                              ? null
                              : () => context
                                  .go('/appointment/prontuario/$_consultaId'),
                          icon: const Icon(Icons.description_outlined,
                              color: AppTokens.primary),
                          label: Text(
                            'Ver prontuário',
                            style: AppTextStyles.bodySm(
                              color: AppTokens.primary,
                              weight: AppTokens.weightSemibold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppTokens.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radius16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Finalizar atendimento',
                    isLoading: _finalizando,
                    onPressed: _finalizar,
                  ),
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
}
