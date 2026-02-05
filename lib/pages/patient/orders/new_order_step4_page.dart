import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../widgets/patient/new_order_step_progress.dart';
import '../../../widgets/patient/new_order_step_header.dart';
import '../../../models/order/new_order_form_data.dart';
import '../../../utils/currency_formatter.dart';

class NewOrderStep4Page extends StatelessWidget {
  final NewOrderFormData? formData;

  const NewOrderStep4Page({super.key, this.formData});

  /// Formata texto de entrega no estilo Figma: "Chega entre 10 e 12 de julho".
  static String _formatDeliveryText(String? deadline) {
    if (deadline == null || deadline.isEmpty) {
      return 'Prazo a confirmar após confirmação do pedido';
    }
    // Se já estiver no formato "até X dias úteis", manter; senão tentar exibir como intervalo.
    if (deadline.toLowerCase().contains('entre')) return deadline;
    if (deadline.toLowerCase().contains('chega')) return deadline;
    return deadline;
  }

  Widget _buildDocumentCard(String fileName, String? url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF33CC80)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined,
                color: Color(0xFF00994B), size: 22),
            onPressed: url != null
                ? () {
                    // Abrir URL no navegador ou in-app
                  }
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00994B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined,
                color: Color(0xFF00994B), size: 22),
            onPressed: url != null
                ? () {
                    // Download do documento
                  }
                : null,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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

    final documentItems = <MapEntry<String, String?>>[];
    if (f.rgFileName != null && f.rgFileName!.isNotEmpty) {
      documentItems.add(MapEntry(f.rgFileName!, f.rgDocumentUrl));
    }
    if (f.addressProofFileName != null && f.addressProofFileName!.isNotEmpty) {
      documentItems.add(MapEntry(f.addressProofFileName!, f.addressProofUrl));
    }
    if (f.anvisaFileName != null && f.anvisaFileName!.isNotEmpty) {
      documentItems.add(MapEntry(f.anvisaFileName!, f.anvisaDocumentUrl));
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
            const NewOrderStepProgress(currentStep: 4),
            const SizedBox(height: 40),
            NewOrderStepHeader(
              stepLabel: 'Etapa 4 - Revisão do pedido',
              valueText: 'Valor: ${CurrencyFormatter.formatBRL(total)}',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            const Text(
                              'Tipo de produto: Óleo',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Dosagem: 20mg/ml',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3F3F3D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Concentração: 20mg/ml de THC',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF3F3F3D),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                    _formatDeliveryText(f.deliveryDeadline),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Documentos enviados',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_up),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (documentItems.isEmpty)
                    const Text(
                      'Nenhum documento anexado',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7C7C79),
                      ),
                    )
                  else
                    ...documentItems
                        .map((e) => _buildDocumentCard(e.key, e.value)),
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
