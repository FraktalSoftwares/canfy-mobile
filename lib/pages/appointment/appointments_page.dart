import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MedicoService _medicoService = MedicoService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _all = [];
  String? _assumindoId;

  // Valor padrão da consulta na plataforma (consulta não tem valor por linha).
  static const String _valorConsulta = r'R$ 200,00';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _medicoService.listarAtendimentos(
      incluirFila: true,
      limit: 200,
    );
    if (!mounted) return;
    if (res['success'] == true && res['data'] is List) {
      _all = (res['data'] as List).cast<Map<String, dynamic>>();
      setState(() => _loading = false);
    } else {
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar os atendimentos.';
      });
    }
  }

  Future<void> _assumir(String consultaId) async {
    setState(() => _assumindoId = consultaId);
    final res = await _medicoService.assumirConsulta(consultaId);
    if (!mounted) return;
    setState(() => _assumindoId = null);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta assumida com sucesso.')),
      );
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta indisponível. Atualize a lista.')),
      );
      _load();
    }
  }

  List<Map<String, dynamic>> get _upcoming => _all
      .where((c) => c['status'] == 'agendada' || c['status'] == 'em_andamento')
      .toList();

  List<Map<String, dynamic>> get _history => _all
      .where((c) => c['status'] == 'finalizada' || c['status'] == 'cancelada')
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Atendimento',
          style: AppTextStyles.bodySm(
            color: AppTokens.neutral900,
            weight: AppTokens.weightSemibold,
          ),
        ),
        centerTitle: true,
        actions: const [DoctorAppBarAvatar()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Atendimento',
                style: AppTextStyles.headingMd(color: AppTokens.neutral900),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: AppTokens.primary,
            labelColor: AppTokens.neutral900,
            unselectedLabelColor: AppTokens.neutral500,
            labelStyle: AppTextStyles.bodySm(weight: AppTokens.weightSemibold),
            unselectedLabelStyle: AppTextStyles.bodySm(),
            tabs: const [
              Tab(text: 'Próximas consultas'),
              Tab(text: 'Histórico de consultas'),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildList(_upcoming, isHistory: false),
                          _buildList(_history, isHistory: true),
                        ],
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(color: AppTokens.neutral600),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _load, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, {required bool isHistory}) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Center(
              child: Text(
                isHistory
                    ? 'Nenhum atendimento no histórico.'
                    : 'Nenhuma consulta próxima.',
                style: AppTextStyles.bodyMd(color: AppTokens.neutral600),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...items.map((c) => _buildCard(c, isHistory: isHistory)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> c, {required bool isHistory}) {
    final dt = DateTime.tryParse(c['data_consulta']?.toString() ?? '');
    final data = dt != null ? _fmtDate(dt) : '--';
    final hora = dt != null ? _fmtTime(dt) : '--';
    final paciente = (c['paciente_nome'] as String?)?.trim();
    final naFila = c['na_fila'] == true;
    final id = c['id'] as String;
    final status = c['status'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        border: Border.all(color: AppTokens.blue100),
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$data • $hora',
                  style: AppTextStyles.bodySm(
                    color: AppTokens.neutral900,
                    weight: AppTokens.weightSemibold,
                  ),
                ),
              ),
              _statusChip(naFila ? 'fila' : status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paciente',
                        style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
                    const SizedBox(height: 4),
                    Text(
                      paciente?.isNotEmpty == true ? paciente! : 'Paciente',
                      style: AppTextStyles.bodyMd(
                        color: AppTokens.neutral900,
                        weight: AppTokens.weightSemibold,
                      ),
                    ),
                  ],
                ),
              ),
              if (!naFila)
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppTokens.primary),
                  onPressed: () {
                    if (isHistory) {
                      context.go('/appointment/details', extra: c);
                    } else {
                      context.go('/appointment/pre-consultation', extra: c);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Valor da consulta:',
                  style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
              const SizedBox(width: 4),
              Text(_valorConsulta,
                  style: AppTextStyles.bodyMd(
                    color: AppTokens.neutral900,
                    weight: AppTokens.weightSemibold,
                  )),
            ],
          ),
          if (naFila) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _assumindoId == id ? null : () => _assumir(id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  foregroundColor: AppTokens.neutral000,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                ),
                child: _assumindoId == id
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTokens.neutral000,
                        ),
                      )
                    : Text('Assumir consulta',
                        style: AppTextStyles.bodySm(
                          color: AppTokens.neutral000,
                          weight: AppTokens.weightSemibold,
                        )),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    late Color bg;
    late Color fg;
    late String label;
    switch (status) {
      case 'fila':
        bg = AppTokens.yellow300;
        fg = AppTokens.tagYellowOnLight;
        label = 'Na fila';
        break;
      case 'em_andamento':
        bg = AppTokens.blue100;
        fg = AppTokens.blue900;
        label = 'Em andamento';
        break;
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
      child: Text(
        label,
        style: AppTextStyles.bodyXs(color: fg, weight: AppTokens.weightSemibold),
      ),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${two(d.year % 100)}';
  }

  String _fmtTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.hour)}:${two(d.minute)}';
  }
}
