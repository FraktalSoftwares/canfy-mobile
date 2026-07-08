import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/text_styles.dart';
import '../../services/api/medico_service.dart';
import '../../utils/product_image_utils.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class PrescriptionProductsPage extends StatefulWidget {
  const PrescriptionProductsPage({super.key});

  @override
  State<PrescriptionProductsPage> createState() =>
      _PrescriptionProductsPageState();
}

class _PrescriptionProductsPageState extends State<PrescriptionProductsPage> {
  final MedicoService _medicoService = MedicoService();
  final Set<String> _selected = {};
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  String? get _consultaId {
    final e = GoRouterState.of(context).extra;
    if (e is String) return e;
    if (e is Map) return (e['id'] ?? e['consultaId']) as String?;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _medicoService.getProdutosCatalogo(limit: 50);
    if (!mounted) return;
    if (result['success'] != true || result['data'] == null) {
      setState(() {
        _loading = false;
        _error = 'Erro ao carregar produtos.';
      });
      return;
    }
    final products = <Map<String, dynamic>>[];
    for (final raw in (result['data'] as List)) {
      if (raw is! Map<String, dynamic>) continue;
      final p = raw;
      final indications = p['indicacoes'] ?? p['indications'] ?? p['indicacao'];
      List<String> indList = [];
      if (indications is List) {
        indList = indications.map((e) => e.toString()).toList();
      } else if (indications is String && indications.isNotEmpty) {
        indList = [indications];
      }
      products.add({
        'id': p['id'] as String,
        'name': p['nome_comercial'] as String? ?? p['nome'] as String? ?? 'Produto',
        'type': p['tipo'] as String? ?? p['forma'] as String? ?? '—',
        'indications': indList,
        'imageUrl': ProductImageUtils.resolveProductImageUrl(
            ProductImageUtils.getProductImageValue(p)),
      });
    }
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  void _continue() {
    final selected = _products
        .where((p) => _selected.contains(p['id']))
        .map((p) => {'id': p['id'], 'name': p['name']})
        .toList();
    context.go('/appointment/prescription-details', extra: {
      'consultaId': _consultaId,
      'produtos': selected,
    });
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
          'Prescrição dos produtos',
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
              ? Center(
                  child: Text(_error!,
                      style: AppTextStyles.bodyMd(color: AppTokens.neutral600)))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('Produtos',
                                style: AppTextStyles.headingMd(
                                    color: AppTokens.neutral900)),
                            const SizedBox(height: 8),
                            Text(
                              'Selecione os produtos a prescrever.',
                              style: AppTextStyles.bodySm(
                                  color: AppTokens.neutral600),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.62,
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) =>
                                  _buildProductCard(_products[index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTokens.neutral000,
        boxShadow: AppTokens.dropShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Produtos selecionados: ${_selected.length}',
            style: AppTextStyles.bodyMd(
              color: AppTokens.neutral900,
              weight: AppTokens.weightSemibold,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Continuar',
            onPressed: _selected.isEmpty ? null : _continue,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final id = product['id'] as String;
    final isSelected = _selected.contains(id);
    final imageUrl = product['imageUrl'] as String?;
    final indications = (product['indications'] as List).cast<String>();

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      }),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTokens.green100 : AppTokens.neutral050,
          border: Border.all(
            color: isSelected ? AppTokens.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radius16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTokens.accentPurpleMedium,
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_pharmacy,
                            size: 40,
                            color: AppTokens.neutral900))
                    : const Icon(Icons.local_pharmacy,
                        size: 40, color: AppTokens.neutral900),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product['name'] as String,
              style: AppTextStyles.bodyMd(
                color: AppTokens.neutral900,
                weight: AppTokens.weightSemibold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: indications
                  .map((ind) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTokens.green100,
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusPill),
                        ),
                        child: Text(ind,
                            style: AppTextStyles.bodyXs(
                                color: AppTokens.green900)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
