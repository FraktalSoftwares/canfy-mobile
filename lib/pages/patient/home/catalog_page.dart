import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'catalog_filters_modal.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';

class PatientCatalogPage extends StatefulWidget {
  const PatientCatalogPage({super.key});

  @override
  State<PatientCatalogPage> createState() => _PatientCatalogPageState();
}

class _PatientCatalogPageState extends State<PatientCatalogPage> {
  // Mock data - será substituído por dados reais do backend
  final List<Map<String, dynamic>> _products = [
    {
      'id': '1',
      'name': 'Óleo\nCanabidiol',
      'indications': ['Ansiedade', 'Dor crônica'],
      'isSelected': true,
    },
    {
      'id': '2',
      'name': 'Óleo\nCanabidiol',
      'indications': ['Ansiedade', 'Dor crônica'],
      'isSelected': false,
    },
    {
      'id': '3',
      'name': 'Óleo\nCanabidiol',
      'indications': ['Ansiedade', 'Dor crônica'],
      'isSelected': false,
    },
    {
      'id': '4',
      'name': 'Óleo\nCanabidiol',
      'indications': ['Ansiedade', 'Dor crônica'],
      'isSelected': false,
    },
    {
      'id': '5',
      'name': 'Óleo\nCanabidiol',
      'indications': ['Ansiedade', 'Dor crônica'],
      'isSelected': false,
    },
    {
      'id': '6',
      'name': 'Óleo\nCanabidiol',
      'indications': ['Ansiedade', 'Dor crônica'],
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PatientAppBar(
        title: 'Catálogo',
        fallbackRoute: '/patient/home',
        actions: [
          IconButton(
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF9067F1),
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.56,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 0, // Home tab is active
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final isSelected = product['isSelected'] as bool;

    return GestureDetector(
      onTap: () {
        context.push('/patient/catalog/product-details/${product['id']}');
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC3A6F9) : const Color(0xFFF1EDFC),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Product image placeholder
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFD7FA80),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.local_pharmacy,
                  size: 48, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            // Product name
            Text(
              product['name'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF212121),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Indicado para
            const Text(
              'Indicado para:',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            // Indications tags
            ...(product['indications'] as List<String>).map((indication) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFD7FA80)
                      : const Color(0xFFD7FA80),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  indication,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF212121),
                  ),
                ),
              );
            }),
            const Spacer(),
            // Ver mais
            Text(
              'ver mais',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF7048C3)
                    : const Color(0xFF7048C3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
