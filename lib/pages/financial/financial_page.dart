import 'package:flutter/material.dart';
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
  double _totalRecebido = 0;
  double _totalPendente = 0;
  List<Map<String, dynamic>> _repasses = [];

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
    final resumo = await _medicoService.resumoFinanceiro();
    final lista = await _medicoService.listarRepasses(limit: 100);
    if (!mounted) return;

    if (resumo['success'] == true && resumo['data'] is List &&
        (resumo['data'] as List).isNotEmpty) {
      final row = (resumo['data'] as List).first as Map<String, dynamic>;
      _totalRecebido = _toDouble(row['total_recebido']);
      _totalPendente = _toDouble(row['total_pendente']);
    }
    if (lista['success'] == true && lista['data'] is List) {
      _repasses = (lista['data'] as List).cast<Map<String, dynamic>>();
    }
    setState(() {
      _loading = false;
      if (resumo['success'] != true && lista['success'] != true) {
        _error = 'Não foi possível carregar o financeiro.';
      }
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
                          children: [
                            Expanded(
                              child: _summaryCard(
                                  'Total a receber', _totalPendente),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _summaryCard(
                                  'Total recebido', _totalRecebido),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text('Repasses',
                            style: AppTextStyles.headingMd(
                                color: AppTokens.neutral900)),
                        const SizedBox(height: 16),
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
                          ..._repasses.map(_buildRepasseCard),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 2),
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
