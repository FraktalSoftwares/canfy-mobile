import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  const PrescriptionDetailsPage({super.key});

  @override
  State<PrescriptionDetailsPage> createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  final MedicoService _medicoService = MedicoService();

  String? _consultaId;
  List<Map<String, dynamic>> _produtos = [];
  final List<TextEditingController> _posologia = [];
  final List<TextEditingController> _duracao = [];
  final List<int> _quantidades = [];
  final TextEditingController _observacoes = TextEditingController();
  DateTime _validade = DateTime.now().add(const Duration(days: 180));
  bool _emitindo = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      _consultaId = extra['consultaId'] as String?;
      _produtos = ((extra['produtos'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
    }
    for (var _ in _produtos) {
      _posologia.add(TextEditingController());
      _duracao.add(TextEditingController());
      _quantidades.add(1);
    }
  }

  @override
  void dispose() {
    for (final c in _posologia) {
      c.dispose();
    }
    for (final c in _duracao) {
      c.dispose();
    }
    _observacoes.dispose();
    super.dispose();
  }

  Future<void> _selecionarValidade() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _validade,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _validade = picked);
  }

  Future<void> _emitir() async {
    // Validação simples: cada produto precisa de posologia.
    for (var i = 0; i < _produtos.length; i++) {
      if (_posologia[i].text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Informe a posologia de ${_produtos[i]['name']}.')),
        );
        return;
      }
    }

    final itens = <Map<String, dynamic>>[];
    for (var i = 0; i < _produtos.length; i++) {
      itens.add({
        'produto_id': _produtos[i]['id'],
        'posologia': _posologia[i].text.trim(),
        'quantidade_prescrita': _quantidades[i],
        'duracao_tratamento': _duracao[i].text.trim(),
      });
    }

    setState(() => _emitindo = true);
    final res = await _medicoService.emitirReceita(
      validade: _fmtIso(_validade),
      itens: itens,
      consultaId: _consultaId,
      observacoes: _observacoes.text.trim().isEmpty
          ? null
          : _observacoes.text.trim(),
    );
    if (!mounted) return;
    setState(() => _emitindo = false);

    if (res['success'] == true) {
      context.go('/appointment/finish', extra: _consultaId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível emitir a receita.')),
      );
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
              context.go('/appointment');
            }
          },
        ),
        title: Text(
          'Detalhes da prescrição',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildValidadeCard(),
                  const SizedBox(height: 24),
                  ..._produtos.asMap().entries.map(
                      (e) => _buildProdutoCard(e.key, e.value)),
                  Text('Observações gerais',
                      style: AppTextStyles.bodyMd(
                        color: AppTokens.neutral900,
                        weight: AppTokens.weightSemibold,
                      )),
                  const SizedBox(height: 8),
                  _textArea(_observacoes, 'Observações da receita (opcional)'),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTokens.neutral000,
              boxShadow: AppTokens.dropShadow,
            ),
            child: AppButton(
              text: 'Emitir receita',
              isLoading: _emitindo,
              onPressed: _produtos.isEmpty ? null : _emitir,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidadeCard() {
    return GestureDetector(
      onTap: _selecionarValidade,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTokens.neutral050,
          borderRadius: BorderRadius.circular(AppTokens.radius16),
        ),
        child: Row(
          children: [
            const Icon(Icons.event, color: AppTokens.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Validade da receita',
                      style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
                  const SizedBox(height: 4),
                  Text(_fmtDate(_validade),
                      style: AppTextStyles.bodyMd(
                        color: AppTokens.neutral900,
                        weight: AppTokens.weightSemibold,
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTokens.neutral500),
          ],
        ),
      ),
    );
  }

  Widget _buildProdutoCard(int index, Map<String, dynamic> produto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (produto['name'] as String?) ?? 'Produto ${index + 1}',
            style: AppTextStyles.bodyMd(
              color: AppTokens.neutral900,
              weight: AppTokens.weightSemibold,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Posologia'),
          _textArea(_posologia[index],
              'Ex.: 10ml pela manhã e 10ml à noite, após as refeições'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Duração do tratamento'),
                    _textField(_duracao[index], 'Ex.: 30 dias'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Quantidade'),
                  _quantityStepper(index),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityStepper(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.neutral000,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: AppTokens.neutral300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            color: AppTokens.primary,
            onPressed: _quantidades[index] > 1
                ? () => setState(() => _quantidades[index]--)
                : null,
          ),
          Text('${_quantidades[index]}',
              style: AppTextStyles.bodyMd(
                color: AppTokens.neutral900,
                weight: AppTokens.weightSemibold,
              )),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            color: AppTokens.primary,
            onPressed: () => setState(() => _quantidades[index]++),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: AppTextStyles.bodySm(
              color: AppTokens.neutral800,
              weight: AppTokens.weightSemibold,
            )),
      );

  Widget _textField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      style: AppTextStyles.bodySm(color: AppTokens.neutral900),
      decoration: _dec(hint),
    );
  }

  Widget _textArea(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      maxLines: 3,
      style: AppTextStyles.bodySm(color: AppTokens.neutral900),
      decoration: _dec(hint),
    );
  }

  InputDecoration _dec(String hint) {
    OutlineInputBorder b(Color color, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput * 3),
          borderSide: BorderSide(color: color, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySm(color: AppTokens.neutral500),
      filled: true,
      fillColor: AppTokens.neutral000,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: b(AppTokens.neutral300),
      enabledBorder: b(AppTokens.neutral300),
      focusedBorder: b(AppTokens.primary, 2),
    );
  }

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  String _fmtIso(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}
