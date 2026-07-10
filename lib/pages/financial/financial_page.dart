import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class FinancialPage extends StatefulWidget {
  const FinancialPage({super.key});

  @override
  State<FinancialPage> createState() => _FinancialPageState();
}

class _FinancialPageState extends State<FinancialPage> {
  final MedicoService _medicoService = MedicoService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _repasses = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const _mesesNomes = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho',
    'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final lista = await _medicoService.listarRepasses(limit: 100);
    if (!mounted) return;

    if (lista['success'] == true && lista['data'] is List) {
      _repasses = (lista['data'] as List).cast<Map<String, dynamic>>();
    }
    setState(() {
      _loading = false;
      if (lista['success'] != true) {
        _error = 'Não foi possível carregar o financeiro.';
      }
    });
  }

  double get _totalPendenteDoMes => _repassesDoMes
      .where((r) => r['status'] != 'pago')
      .fold(0.0, (sum, r) => sum + _toDouble(r['valor']));

  List<Map<String, dynamic>> get _repassesDoMes {
    return _repasses.where((r) {
      final dt = DateTime.tryParse(r['data_repasse']?.toString() ?? '');
      return dt != null &&
          dt.year == _selectedMonth.year &&
          dt.month == _selectedMonth.month;
    }).toList();
  }

  Map<String, dynamic>? get _ultimoRepasse {
    final pagos = _repasses.where((r) => r['status'] == 'pago').toList()
      ..sort((a, b) => (b['data_repasse'] ?? '')
          .toString()
          .compareTo((a['data_repasse'] ?? '').toString()));
    return pagos.isNotEmpty ? pagos.first : null;
  }

  Map<String, dynamic>? get _proximoRepasse {
    final pendentes = _repasses.where((r) => r['status'] != 'pago').toList()
      ..sort((a, b) => (a['data_repasse'] ?? '')
          .toString()
          .compareTo((b['data_repasse'] ?? '').toString()));
    return pendentes.isNotEmpty ? pendentes.first : null;
  }

  void _mudarMes(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    });
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: AppBar(
        backgroundColor: AppTokens.neutral000,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Financeiro',
          style: AppTextStyles.bodySm(
            color: AppTokens.neutral900,
            weight: AppTokens.weightSemibold,
          ),
        ),
        centerTitle: true,
        actions: const [DoctorAppBarAvatar()],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Financeiro',
                            style: AppTextStyles.headingMd(
                                color: AppTokens.neutral900)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _monthNavButton(Icons.chevron_left, () => _mudarMes(-1)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppTokens.green100,
                                  borderRadius:
                                      BorderRadius.circular(AppTokens.radiusPill),
                                ),
                                child: Text(
                                  _mesesNomes[_selectedMonth.month - 1],
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMd(
                                    color: AppTokens.green900,
                                    weight: AppTokens.weightSemibold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _monthNavButton(Icons.chevron_right, () => _mudarMes(1)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _summaryCard('Total a receber', _totalPendenteDoMes),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _repasseMiniCard(
                                    'Último repasse', _ultimoRepasse)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _repasseMiniCard(
                                    'Próximo repasse', _proximoRepasse)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Repasses',
                                style: AppTextStyles.headingMd(
                                    color: AppTokens.neutral900)),
                            TextButton(
                              onPressed: () => context.push('/financial/history'),
                              child: Text('Ver tudo',
                                  style: AppTextStyles.bodySm(
                                    color: AppTokens.accentPurple,
                                    weight: AppTokens.weightSemibold,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_repasses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text('Nenhum repasse encontrado.',
                                  style: AppTextStyles.bodyMd(
                                      color: AppTokens.neutral600)),
                            ),
                          )
                        else
                          ..._repasses.take(3).map(_buildRepasseCard),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _monthNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTokens.green100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTokens.green900),
      ),
    );
  }

  Widget _repasseMiniCard(String label, Map<String, dynamic>? repasse) {
    final dt = repasse != null
        ? DateTime.tryParse(repasse['data_repasse']?.toString() ?? '')
        : null;
    final valor = repasse != null ? _toDouble(repasse['valor']) : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dt != null ? _fmtDate(dt) : '--',
              style: AppTextStyles.bodyXs(color: AppTokens.neutral600)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
          const SizedBox(height: 4),
          Text(valor != null ? _money(valor) : '--',
              style: AppTextStyles.bodyMd(
                color: AppTokens.neutral900,
                weight: AppTokens.weightSemibold,
              )),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd(color: AppTokens.neutral600)),
            const SizedBox(height: 16),
            TextButton(onPressed: _load, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, double valor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
          const SizedBox(height: 12),
          Text(_money(valor),
              style: AppTextStyles.headingSm(color: AppTokens.neutral800)),
        ],
      ),
    );
  }

  Widget _buildRepasseCard(Map<String, dynamic> r) {
    final status = r['status'] as String? ?? 'pendente';
    final valor = _toDouble(r['valor']);
    final data = r['data_repasse']?.toString();
    final dt = data != null ? DateTime.tryParse(data) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
        border: Border.all(color: AppTokens.blue100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusTag(status),
          const SizedBox(height: 16),
          Text(
            dt != null ? 'Repasse • ${_fmtDate(dt)}' : 'Repasse',
            style: AppTextStyles.bodySm(color: AppTokens.neutral600),
          ),
          const SizedBox(height: 4),
          Text(_money(valor),
              style: AppTextStyles.bodyMd(
                color: AppTokens.neutral900,
                weight: AppTokens.weightBold,
              )),
          if ((r['observacao'] as String?)?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(r['observacao'] as String,
                style: AppTextStyles.bodyXs(color: AppTokens.neutral600)),
          ],
        ],
      ),
    );
  }

  Widget _statusTag(String status) {
    late Color bg;
    late Color fg;
    late String text;
    switch (status) {
      case 'pago':
        bg = AppTokens.green100;
        fg = AppTokens.green900;
        text = 'Recebido';
        break;
      case 'atrasado':
        bg = AppTokens.yellow300;
        fg = AppTokens.tagYellowOnLight;
        text = 'Atrasado';
        break;
      default:
        bg = AppTokens.blue100;
        fg = AppTokens.blue900;
        text = 'A receber';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(text,
          style: AppTextStyles.bodyXs(color: fg, weight: AppTokens.weightSemibold)),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${two(d.year % 100)}';
  }

  String _money(double v) {
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return 'R\$ $buf,${parts[1]}';
  }
}
