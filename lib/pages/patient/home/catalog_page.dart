import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'catalog_filters_modal.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/api/patient_service.dart';
import '../../../utils/product_image_utils.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class PatientCatalogPage extends StatefulWidget {
  const PatientCatalogPage({super.key});

  @override
  State<PatientCatalogPage> createState() => _PatientCatalogPageState();
}

class _PatientCatalogPageState extends State<PatientCatalogPage> {
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

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
    final res = await _patientService.getProdutos(limit: 50);
    if (!mounted) return;
    if (res['success'] != true || res['data'] is! List) {
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar o catálogo.';
      });
      return;
    }
    final products = <Map<String, dynamic>>[];
    for (final raw in (res['data'] as List)) {
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
        'id': p['id'],
        'name': p['nome_comercial'] as String? ?? p['nome'] as String? ?? 'Produto',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.neutral000,
      appBar: PatientAppBar(
        title: 'Catálogo',
        fallbackRoute: '/patient/home',
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTokens.accentPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 20),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CatalogFiltersModal(),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _products.isEmpty
                  ? Center(
                      child: Text('Nenhum produto disponível.',
                          style: AppTextStyles.bodyMd(
                              color: AppTokens.neutral600)),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.56,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) =>
                            _buildProductCard(_products[index]),
                      ),
                    ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 0),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final indications = (product['indications'] as List).cast<String>();
    final imageUrl = product['imageUrl'] as String?;

    return GestureDetector(
      onTap: () {
        context.push('/patient/catalog/product-details/${product['id']}');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTokens.accentPurpleLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTokens.accentLime,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_pharmacy,
                          size: 48,
                          color: Colors.black54))
                  : const Icon(Icons.local_pharmacy,
                      size: 48, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              product['name'] as String,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd(color: AppTokens.neutral900),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            if (indications.isNotEmpty) ...[
              Text('Indicado para:',
                  style: AppTextStyles.bodySm(color: AppTokens.neutral900)
                      .copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              ...indications.map((ind) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTokens.accentLime,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: Text(ind,
                        style: AppTextStyles.bodySm(color: AppTokens.neutral900)),
                  )),
            ],
            const Spacer(),
            Text('ver mais',
                style: AppTextStyles.bodyXs(
                  color: AppTokens.accentPurple,
                  weight: AppTokens.weightBold,
                )),
          ],
        ),
      ),
    );
  }
}
