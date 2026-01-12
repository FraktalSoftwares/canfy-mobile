import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewConsultationStep4Page extends StatefulWidget {
  const NewConsultationStep4Page({super.key});

  @override
  State<NewConsultationStep4Page> createState() =>
      _NewConsultationStep4PageState();
}

class _NewConsultationStep4PageState extends State<NewConsultationStep4Page> {
  String? _selectedPaymentMethod;
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Widget _buildPaymentOption({
    required String method,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F8EF) : const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00BB5A) : const Color(0xFFE7E7F1),
          ),
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
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
            ),
            Radio<String>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: const Color(0xFF00BB5A),
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
            angle: 1.5708, // 90 graus
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Transform.rotate(
                angle: -1.5708, // -90 graus para compensar
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient/consultations');
            }
          },
        ),
        title: const Text(
          'Nova consulta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.push('/patient/account');
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundImage:
                    AssetImage('assets/images/avatar_pictures.png'),
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
            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BB5A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BB5A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BB5A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BB5A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Etapa 4 - Pagamento',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F8EF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Valor: R\$ 200,00',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00BB5A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E7F1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo da consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Dia e horário', '08/09/2025 • 10:00'),
                  _buildDetailRow('Valor da consulta', 'R\$200,00'),
                  const SizedBox(height: 8),
                  const Text(
                    'Queixas principais',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: ['Insônia', 'Estresse']
                        .map((symptom) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE6F8EF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                symptom,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00BB5A),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Coupon field
            TextField(
              controller: _couponController,
              decoration: InputDecoration(
                labelText: 'Cupom de desconto (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF7048C3)),
                ),
                filled: true,
                fillColor: const Color(0xFFF7F7F5),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Método de pagamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Atualize seu método de pagamento de forma rápida e segura.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7C7C79),
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              method: 'credit_card',
              label: 'Cartão de crédito',
              icon: Icons.credit_card,
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'credit_card';
                });
              },
            ),
            _buildPaymentOption(
              method: 'debit_card',
              label: 'Cartão de débito',
              icon: Icons.credit_card,
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'debit_card';
                });
              },
            ),
            _buildPaymentOption(
              method: 'pix',
              label: 'Pix',
              icon: Icons.qr_code,
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'pix';
                });
              },
            ),
            _buildPaymentOption(
              method: 'boleto',
              label: 'Boleto',
              icon: Icons.receipt,
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'boleto';
                });
              },
            ),
            const SizedBox(height: 16),
            // Cancellation policy
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7E7F1)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Política de Cancelamento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Cancelamento até 12h antes: reembolso integral',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cancelamento após 12h antes: sem reembolso',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reagendamento permitido até 2h antes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedPaymentMethod != null
                    ? () {
                        // Process payment logic
                        context.go('/patient/consultations');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BB5A),
                  disabledBackgroundColor: const Color(0xFFE7E7F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirmar pagamento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
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
              color: Color(0xFF212121),
            ),
          ),
        ],
      ),
    );
  }
}
