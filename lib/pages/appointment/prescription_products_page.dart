import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrescriptionProductsPage extends StatefulWidget {
  const PrescriptionProductsPage({super.key});

  @override
  State<PrescriptionProductsPage> createState() => _PrescriptionProductsPageState();
}

class _PrescriptionProductsPageState extends State<PrescriptionProductsPage> {
  final Set<int> _selectedProducts = {};

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Canabidiol Óleo',
      'indications': ['Insônia', 'Ansiedade'],
      'image': 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
    },
    {
      'name': 'Canabidiol Creme',
      'indications': ['Dor', 'Inflamação'],
      'image': 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
    },
    {
      'name': 'Canabidiol Óleo',
      'indications': ['Insônia', 'Ansiedade'],
      'image': 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
    },
    {
      'name': 'Canabidiol Óleo',
      'indications': ['Insônia', 'Ansiedade'],
      'image': 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
    },
    {
      'name': 'Canabidiol Óleo',
      'indications': ['Insônia', 'Ansiedade'],
      'image': 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
    },
    {
      'name': 'Canabidiol Óleo',
      'indications': ['Insônia', 'Ansiedade'],
      'image': 'assets/images/8ea03714bcc629ced1e1b647110a530c2ee52667.png',
    },
  ];

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
              context.go('/appointment');
            }
          },
        ),
        title: const Text(
          'Prescrição dos produtos',
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
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Card do paciente
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paciente',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF7C7C79),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Laura Flores',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.transparent),
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Produtos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid de produtos
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final isSelected = _selectedProducts.contains(index);
                      return _buildProductCard(product, index, isSelected);
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 9,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Produtos selecionados: ${_selectedProducts.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: _selectedProducts.isEmpty
                        ? null
                        : () {
                            context.go('/appointment/prescription-details');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00994B),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedProducts.remove(index);
          } else {
            _selectedProducts.add(index);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F8EF) : const Color(0xFFF7F7F5),
          border: Border.all(
            color: isSelected ? const Color(0xFF00994B) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: 96,
              height: 96,
              child: Image.asset(
                product['image'] as String,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Indicado para:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: (product['indications'] as List<String>)
                        .map((indication) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F8EF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                indication,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00994B),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'detalhes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00994B),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





