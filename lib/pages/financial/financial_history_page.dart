import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'financial_filters_modal.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class FinancialHistoryPage extends StatefulWidget {
  const FinancialHistoryPage({super.key});

  @override
  State<FinancialHistoryPage> createState() => _FinancialHistoryPageState();
}

class _FinancialHistoryPageState extends State<FinancialHistoryPage> {
  final MedicoService _medicoService = MedicoService();
  bool _loading = true;
  String? _error;
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
    final res = await _medicoService.listarRepasses(limit: 200);
    if (!mounted) return;
    if (res['success'] == true && res['data'] is List) {
      _repasses = (res['data'] as List).cast<Map<String, dynamic>>();
      setState(() => _loading = false);
    } else {
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o histórico.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/financial');
            }
          },
        ),
        title: Text('Financeiro',
            style: AppTextStyles.bodySm(
              color: AppTokens.neutral900,
              weight: AppTokens.weightSemibold,
            )),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Histórico de repasses',
                                  style: AppTextStyles.headingMd(
                                      color: AppTokens.neutral900)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune,
                                  color: AppTokens.neutral000),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const FinancialFiltersModal(),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppTokens.primary,
                                shape: const CircleBorder(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_repasses.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text('Nenhum repasse encontrado.',
                                  style: AppTextStyles.bodyMd(
                                      color: AppTokens.neutral600)),
                            ),
                          )
                        else
                          ..._repasses.map(_buildCard),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.headset_mic, size: 16),
                            label: const Text(
                                'Entrar em contato com o suporte'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTokens.primary,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radiusPill),
                              ),
                              side: const BorderSide(color: AppTokens.primary),
                            ),
                          ),
                        ),
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

  Widget _buildCard(Map<String, dynamic> r) {
    final status = r['status'] as String? ?? 'pendente';
    final valor = _toDouble(r['valor']);
    final dt = DateTime.tryParse(r['data_repasse']?.toString() ?? '');

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
          Text(dt != null ? 'Repasse • ${_fmtDate(dt)}' : 'Repasse',
              style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
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
          style:
              AppTextStyles.bodyXs(color: fg, weight: AppTokens.weightSemibold)),
    );
  }

  double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${two(d.year % 100)}';
  }

  String _money(double v) {
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final buf = StringBuffer();
    for (var i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write('.');
      buf.write(parts[0][i]);
    }
    return 'R\$ $buf,${parts[1]}';
  }
}
