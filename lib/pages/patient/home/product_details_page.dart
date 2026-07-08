import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'share_product_modal.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/api/patient_service.dart';
import '../../../utils/product_image_utils.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';

class PatientProductDetailsPage extends StatefulWidget {
  final String productId;

  const PatientProductDetailsPage({super.key, required this.productId});

  @override
  State<PatientProductDetailsPage> createState() =>
      _PatientProductDetailsPageState();
}

class _PatientProductDetailsPageState extends State<PatientProductDetailsPage> {
  final PatientService _patientService = PatientService();
  Map<String, dynamic>? _produto;
  List<String> _indicacoes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final produto = await _patientService.getProdutoById(widget.productId);
    final indic = await _patientService.getProdutoIndicacoes(widget.productId);
    if (!mounted) return;
    setState(() {
      _produto = produto;
      _indicacoes = indic;
      _loading = false;
    });
  }

  String get _nome =>
      (_produto?['nome_comercial'] as String?)?.trim().isNotEmpty == true
          ? _produto!['nome_comercial'] as String
          : 'Produto';

  String? get _imageUrl => ProductImageUtils.resolveProductImageUrl(
      _produto?['imagem_url'] ?? ProductImageUtils.getProductImageValue(_produto ?? {}));

  String get _composicao {
    final ativo = (_produto?['principio_ativo'] as String?)?.trim();
    final cbd = (_produto?['concentracao_cbd'] as String?)?.trim();
    final thc = (_produto?['concentracao_thc'] as String?)?.trim();
    final conc = [
      if (cbd?.isNotEmpty == true) 'CBD $cbd',
      if (thc?.isNotEmpty == true) 'THC $thc',
    ].join(' / ');
    return [
      if (ativo?.isNotEmpty == true) ativo,
      if (conc.isNotEmpty) conc,
    ].join(' · ').trim().isEmpty
        ? '—'
        : [
            if (ativo?.isNotEmpty == true) ativo,
            if (conc.isNotEmpty) conc,
          ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTokens.neutral000,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 324,
            pinned: true,
            backgroundColor: AppTokens.neutral000,
            leading: _circleButton(Icons.arrow_back, () => context.pop()),
            actions: [_circleButton(Icons.share, _openShare)],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTokens.accentPurpleLight,
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTokens.accentLime,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _imageUrl != null && _imageUrl!.isNotEmpty
                        ? Image.network(_imageUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.local_pharmacy,
                                size: 100,
                                color: Colors.black54))
                        : const Icon(Icons.local_pharmacy,
                            size: 100, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_nome,
                      style: AppTextStyles.headingSm(color: AppTokens.neutral900)),
                  const SizedBox(height: 24),
                  _warningCard(),
                  const SizedBox(height: 24),
                  _detailsCard(),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Solicitar produto',
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.push('/patient/orders/new'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTokens.accentPurpleLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: AppTokens.neutral900, size: 20),
      ),
      onPressed: onTap,
    );
  }

  void _openShare() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ShareProductModal(),
    );
  }

  Widget _warningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTokens.yellow100,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppTokens.yellow900),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este produto só pode ser comercializado e utilizado com receita médica.',
              style: AppTextStyles.bodyXs(color: AppTokens.yellow900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard() {
    final forma = (_produto?['forma_farmaceutica']?.toString() ?? '').trim();
    final volume = (_produto?['volume_quantidade'] as String?)?.trim();
    final fabricante = (_produto?['fabricante'] as String?)?.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.neutral050,
        borderRadius: BorderRadius.circular(AppTokens.radius16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Composição e concentração', _composicao),
          if (forma.isNotEmpty) ...[
            const Divider(height: 32),
            _detailRow('Forma farmacêutica', forma),
          ],
          if (volume?.isNotEmpty == true) ...[
            const Divider(height: 32),
            _detailRow('Volume / quantidade', volume!),
          ],
          if (fabricante?.isNotEmpty == true) ...[
            const Divider(height: 32),
            _detailRow('Fabricante', fabricante!),
          ],
          if (_indicacoes.isNotEmpty) ...[
            const Divider(height: 32),
            _detailRow('Indicações clínicas', _indicacoes.join(', ')),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm(color: AppTokens.neutral600)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.bodyMd(
              color: AppTokens.neutral800,
              weight: AppTokens.weightSemibold,
            )),
      ],
    );
  }
}
