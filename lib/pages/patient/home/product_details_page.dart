import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'share_product_modal.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';

class PatientProductDetailsPage extends StatefulWidget {
  final String productId;
  
  const PatientProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  State<PatientProductDetailsPage> createState() => _PatientProductDetailsPageState();
}

class _PatientProductDetailsPageState extends State<PatientProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 324,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDFC).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
              ),
              onPressed: () {
                context.pop();
              },
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1EDFC).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share, color: Color(0xFF212121)),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ShareProductModal(),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey[200]!,
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7FA80),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(Icons.local_pharmacy, size: 100, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product title and share button
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
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDFC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.share, color: Color(0xFF212121)),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const ShareProductModal(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Warning card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7E3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6DC5E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.info_outline, size: 16, color: Color(0xFF9E831B)),
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
                  const SizedBox(height: 24),
                  // Product details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Composição e concentração',
                          '20:1 CBD:THC',
                        ),
                        const Divider(height: 32),
                        _buildDetailRow(
                          'Formas de uso',
                          'Óleo, cápsula, flor',
                        ),
                        const Divider(height: 32),
                        _buildDetailRow(
                          'Indicações clínicas',
                          'Dor crônica, ansiedade e insônia',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Usage instructions
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Orientações de uso gerais',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFA987F5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EDFC),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.visibility, color: Color(0xFF9067F1), size: 20),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'Orientações.pdf',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9067F1),
                                  ),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EDFC),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.download, color: Color(0xFF9067F1), size: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Related products
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Produtos relacionados',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                          fontFamily: 'Truculenta',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/patient/catalog');
                        },
                        child: const Text(
                          'Ver tudo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9067F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 178,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 144,
                          margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: index == 0 
                                ? const Color(0xFFC3A6F9) 
                                : const Color(0xFFF1EDFC),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7FA80),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Icon(Icons.local_pharmacy, size: 48, color: Colors.black54),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Óleo\nCanabidiol',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF212121),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Request product button
                  ElevatedButton(
                    onPressed: () {
                      // Request product
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9067F1),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 49),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Solicitar produto',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 0, // Home tab is active
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7C7C79),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3F3F3D),
          ),
        ),
      ],
    );
  }
}






