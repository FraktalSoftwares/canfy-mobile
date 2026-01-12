import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'share_product_modal.dart';
import '../../widgets/common/safe_image_asset.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  Widget _buildRelatedProductCard() {
    return Container(
      width: 144,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            child: SafeImageAsset(
              imagePath: 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
              fit: BoxFit.contain,
              placeholderIcon: Icons.local_pharmacy,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
              children: [
                TextSpan(text: 'Canabidiol\n'),
                TextSpan(
                  text: 'Óleo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Imagem do produto
          SliverAppBar(
            expandedHeight: 324,
            pinned: true,
            backgroundColor: const Color(0xFFC3A6F9),
            leading: IconButton(
              icon: Transform.rotate(
                angle: 1.5708,
                child: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/catalog');
                }
              },
            ),
            actions: [
              IconButton(
                icon: Transform.rotate(
                  angle: 1.5708,
                  child: Transform.rotate(
                    angle: 4.7124,
                    child: const Icon(Icons.share, color: Colors.black),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ShareProductModal(),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE6F8EF),
                  shape: const CircleBorder(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: const Color(0xFFC3A6F9),
                  ),
                  Image.asset(
                    'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
                    width: 161,
                    height: 348,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Óleo Canabidiol 20mg/ml',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Transform.rotate(
                          angle: 1.5708,
                          child: Transform.rotate(
                            angle: 4.7124,
                            child: const Icon(Icons.share, color: Colors.black),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const ShareProductModal(),
                          );
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F8EF),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Aviso
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7E3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6DC5E),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 12,
                            color: Color(0xFF9E831B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Este produto só pode ser comercializado\ne utilizado com receita médica.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E831B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Detalhes
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE6E6E3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Composição e concentração',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7C7C79),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '20:1 CBD:THC',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3F3F3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFE6E6E3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Formas de uso',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7C7C79),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Óleo, cápsula, flor',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3F3F3D),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Indicações clínicas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7C7C79),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Dor crônica, ansiedade e insônia',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Marca/Fornecedor',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7C7C79),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'CBDMD',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Produtos relacionados
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
                        onPressed: () {
                          context.push('/catalog');
                        },
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRelatedProductCard(),
                        const SizedBox(width: 16),
                        _buildRelatedProductCard(),
                        const SizedBox(width: 16),
                        _buildRelatedProductCard(),
                        const SizedBox(width: 16),
                        _buildRelatedProductCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}






