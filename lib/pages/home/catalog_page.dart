import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'catalog_filters_modal.dart';
import '../../services/api/medico_service.dart';
import '../../utils/product_image_utils.dart';
import '../../widgets/common/bottom_navigation_bar_doctor.dart';
import '../../widgets/common/doctor_app_bar_avatar.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final MedicoService _medicoService = MedicoService();
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final result = await _medicoService.getProdutosCatalogo(limit: 50);
      if (!mounted) return;
      if (result['success'] != true || result['data'] == null) {
        setState(() {
          _loading = false;
          _error = result['message'] as String? ?? 'Erro ao carregar catálogo';
        });
        return;
      }
      final list = result['data'] as List;
      final products = <Map<String, dynamic>>[];
      for (final raw in list) {
        if (raw is! Map<String, dynamic>) continue;
        final p = raw;
        final name =
            p['nome_comercial'] as String? ?? p['nome'] as String? ?? 'Produto';
        final tipo = p['tipo'] as String? ?? p['forma'] as String? ?? '—';
        final indications =
            p['indications'] ?? p['indicacoes'] ?? p['indicacao'];
        List<String> indList = [];
        if (indications is List) {
          indList = indications.map((e) => e.toString()).toList();
        } else if (indications is String && indications.isNotEmpty) {
          indList = [indications];
        }
        final imageValue = ProductImageUtils.getProductImageValue(p);
        final imageUrl = ProductImageUtils.resolveProductImageUrl(imageValue);
        products.add({
          'id': p['id'],
          'name': name,
          'type': tipo,
          'indications': indList,
          'price': p['preco'],
          'imageUrl': imageUrl,
        });
      }
      if (mounted) {
        setState(() {
          _products = products;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final imageUrl = product['imageUrl'] as String?;
    final indications = product['indications'] as List<dynamic>? ?? [];
    final indicationsStr = indications.map((e) => e.toString()).toList();

    return GestureDetector(
      onTap: () {
        context.push('/catalog/product-details');
      },
      child: Container(
        width: 171,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE7E7F1),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFC3A6F9),
                borderRadius: BorderRadius.circular(999),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 96,
                      height: 96,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_pharmacy,
                        size: 48,
                        color: Color(0xFF212121),
                      ),
                    )
                  : const Icon(
                      Icons.local_pharmacy,
                      size: 48,
                      color: Color(0xFF212121),
                    ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                    children: [
                      TextSpan(text: product['name'] + '\n'),
                      TextSpan(
                        text: product['type'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Indicado para:',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: indicationsStr
                      .map((indication) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF66DDA2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              indication,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      context.push('/catalog/product-details');
                    },
                    child: const Text(
                      'detalhes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 1.5708,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          'Catálogo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          const DoctorAppBarAvatar(),
          Transform.rotate(
            angle: 1.5708,
            child: IconButton(
              icon: Transform.rotate(
                angle: 4.7124,
                child: const Icon(Icons.tune, color: Colors.white),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CatalogFiltersModal(),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF00BB5A),
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: _products
                            .map((product) =>
                                _buildProductCard(context, product))
                            .toList(),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const DoctorBottomNavigationBar(currentIndex: 0),
    );
  }
}
