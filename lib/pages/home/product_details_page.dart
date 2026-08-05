import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'share_product_modal.dart';
import '../../services/api/medico_service.dart';
import '../../utils/product_image_utils.dart';
import '../../widgets/common/circle_icon_button.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final MedicoService _medicoService = MedicoService();
  Map<String, dynamic>? _produto;
  List<String> _indicacoes = [];
  String? _marcaNome;
  List<Map<String, dynamic>> _relacionados = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final produto = await _medicoService.getProdutoById(widget.productId);
    final indic = await _medicoService.getProdutoIndicacoes(widget.productId);
    String? marcaNome;
    final marcaId = produto?['associacao_marca_id'] as String?;
    if (marcaId != null && marcaId.isNotEmpty) {
      marcaNome = await _medicoService.getAssociacaoMarcaNome(marcaId);
    }
    final relacionados = await _medicoService.getRelatedProdutos(
      widget.productId,
      formaFarmaceutica: produto?['forma_farmaceutica'] as String?,
    );
    if (!mounted) return;
    setState(() {
      _produto = produto;
      _indicacoes = indic;
      _marcaNome = marcaNome;
      _relacionados = relacionados;
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
    final parts = [
      if (ativo?.isNotEmpty == true) ativo,
      if (conc.isNotEmpty) conc,
    ];
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final forma = (_produto?['forma_farmaceutica']?.toString() ?? '').trim();
    final fabricante = (_produto?['fabricante'] as String?)?.trim();
    final marca = _marcaNome?.trim().isNotEmpty == true
        ? _marcaNome
        : (fabricante?.isNotEmpty == true ? fabricante : null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 324,
            pinned: true,
            backgroundColor: const Color(0xFFC3A6F9),
            leading: Center(
              child: CircleIconButton(
                icon: Icons.chevron_left,
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/catalog');
                  }
                },
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleIconButton(
                  icon: Icons.share,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ShareProductModal(),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFC3A6F9),
                child: Center(
                  child: _imageUrl != null && _imageUrl!.isNotEmpty
                      ? Image.network(_imageUrl!,
                          width: 161,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_pharmacy,
                              size: 100,
                              color: Colors.white))
                      : const Icon(Icons.local_pharmacy,
                          size: 100, color: Colors.white),
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
                  Text(
                    _nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow('Composição e concentração', _composicao),
                        if (forma.isNotEmpty) ...[
                          const Divider(height: 32),
                          _detailRow('Formas de uso', forma),
                        ],
                        if (_indicacoes.isNotEmpty) ...[
                          const Divider(height: 32),
                          _detailRow(
                              'Indicações clínicas', _indicacoes.join(', ')),
                        ],
                        if (marca?.isNotEmpty == true) ...[
                          const Divider(height: 32),
                          _detailRow('Marca/Fornecedor', marca!),
                        ],
                      ],
                    ),
                  ),
                  if (_relacionados.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Produtos relacionados',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/catalog'),
                          child: const Text(
                            'Ver tudo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7048C3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 176,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _relacionados.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final produto = _relacionados[index];
                          return _buildRelatedProductCard(produto);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF7C7C79))),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F3F3D),
            )),
      ],
    );
  }

  Widget _buildRelatedProductCard(Map<String, dynamic> produto) {
    final nome = (produto['nome_comercial'] as String?)?.trim().isNotEmpty ==
            true
        ? produto['nome_comercial'] as String
        : 'Produto';
    final imageUrl = ProductImageUtils.resolveProductImageUrl(
        produto['imagem_url'] ?? ProductImageUtils.getProductImageValue(produto));
    return GestureDetector(
      onTap: () => context.pushReplacement(
          '/catalog/product-details/${produto['id']}'),
      child: Container(
        width: 144,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(24),
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
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_pharmacy,
                          color: Colors.white))
                  : const Icon(Icons.local_pharmacy, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              nome,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
