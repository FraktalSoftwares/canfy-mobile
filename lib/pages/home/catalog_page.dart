import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'catalog_filters_modal.dart';
import '../../widgets/common/safe_image_asset.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
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
              child: SafeImageAsset(
                imagePath: 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
                fit: BoxFit.contain,
                placeholderIcon: Icons.local_pharmacy,
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
                  children: (product['indications'] as List<String>)
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
    final products = [
      {
        'name': 'Canabidiol',
        'type': 'Óleo',
        'indications': ['Ansiedade', 'Dor crônica'],
      },
      {
        'name': 'Canabidiol',
        'type': 'Creme',
        'indications': ['Ansiedade', 'Dor crônica'],
      },
      {
        'name': 'Canabidiol',
        'type': 'Gummies',
        'indications': ['Ansiedade', 'Dor crônica'],
      },
      {
        'name': 'Canabidiol',
        'type': 'Óleo',
        'indications': ['Ansiedade', 'Dor crônica'],
      },
      {
        'name': 'Canabidiol',
        'type': 'Óleo',
        'indications': ['Ansiedade', 'Dor crônica'],
      },
      {
        'name': 'Canabidiol',
        'type': 'Óleo',
        'indications': ['Ansiedade', 'Dor crônica'],
      },
    ];

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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.black),
            ),
          ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: products.map((product) => _buildProductCard(context, product)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

