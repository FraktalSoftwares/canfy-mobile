import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../models/order/new_order_form_data.dart';
import '../../../utils/currency_formatter.dart';

class NewOrderStep4Page extends StatelessWidget {
  final NewOrderFormData? formData;

  const NewOrderStep4Page({super.key, this.formData});

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(
        5,
        (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            width: 53,
            height: 6,
            decoration: BoxDecoration(
              color: i < 4 ? const Color(0xFF00BB5A) : const Color(0xFFD6D6D3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(String fileName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF33CC80)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F8EF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.insert_drive_file,
                color: Color(0xFF00994B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00994B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (formData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/patient/orders/new/step1');
      });
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF00994B))),
      );
    }

    final f = formData!;
    final productValue = f.productValue;
    final shipping = f.shippingCost;
    final total = f.totalWithShipping;

    final documentNames = <String>[];
    if (f.rgFileName != null && f.rgFileName!.isNotEmpty) {
      documentNames.add(f.rgFileName!);
    }
    if (f.addressProofFileName != null && f.addressProofFileName!.isNotEmpty) {
      documentNames.add(f.addressProofFileName!);
    }
    if (f.anvisaFileName != null && f.anvisaFileName!.isNotEmpty) {
      documentNames.add(f.anvisaFileName!);
    }
    if (documentNames.isEmpty) {
      documentNames.add('Nenhum documento anexado');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Revisão do pedido',
        fallbackRoute: '/patient/orders/new/step3',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildProgressIndicator(),
            const SizedBox(height: 40),
            const Text(
              'Novo pedido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Etapa 4 - Revisão do pedido',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F8EF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Valor: ${CurrencyFormatter.formatBRL(total)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007A3B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo do pedido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFE6E6E3)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F8EF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.medication_liquid,
                          size: 32,
                          color: Color(0xFF007A3B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.productName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF007A3B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantidade: ${f.quantity} unidade(s)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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
                  const Text(
                    'Canal de aquisição',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE6E6E3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Associação: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      Text(
                        f.canalAquisicao,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Valor: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatBRL(productValue),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007A3B),
                        ),
                      ),
                    ],
                  ),
                ],
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
                  const Text(
                    'Entrega',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.deliveryDeadline ??
                        'Prazo a confirmar após confirmação do pedido',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                ],
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
                  const Text(
                    'Valor total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Valor do produto',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatBRL(productValue),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                    ],
                  ),
                  if (shipping > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor do frete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatBRL(shipping),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  const Divider(color: Color(0xFFE6E6E3)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatBRL(total),
                        style: const TextStyle(
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
            const SizedBox(height: 16),
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
                    'Documentos enviados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F3F3D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...documentNames.map(_buildDocumentCard),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/patient/orders/new/step5', extra: f);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00994B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Próximo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
