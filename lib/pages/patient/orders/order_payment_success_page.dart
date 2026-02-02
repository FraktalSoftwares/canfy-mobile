import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';

/// Tela exibida quando o pagamento do pedido é confirmado (design Figma: Pagamento concluído).
class OrderPaymentSuccessPage extends StatelessWidget {
  final String orderId;
  final String productName;
  final String totalFormatted;
  final String deliveryEstimate;

  const OrderPaymentSuccessPage({
    super.key,
    required this.orderId,
    required this.productName,
    required this.totalFormatted,
    required this.deliveryEstimate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          onPressed: () => context.go('/patient/orders'),
        ),
        title: const Text(
          'Pagamento concluído',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Obrigado',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Seu pagamento foi realizado com sucesso.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7C7C79),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _DetailRow(label: 'Produto', value: productName),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Preço', value: totalFormatted),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'Previsão', value: deliveryEstimate),
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BB5A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2600994B),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/patient/orders/$orderId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00994B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Ver detalhes do pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 1),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF212121),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00994B),
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
