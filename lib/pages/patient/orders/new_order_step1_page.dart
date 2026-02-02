import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../services/api/patient_service.dart';
import '../../../models/order/new_order_form_data.dart';

class NewOrderStep1Page extends StatefulWidget {
  const NewOrderStep1Page({super.key});

  @override
  State<NewOrderStep1Page> createState() => _NewOrderStep1PageState();
}

class _NewOrderStep1PageState extends State<NewOrderStep1Page> {
  String? selectedPrescriptionId;
  final PatientService _patientService = PatientService();
  List<Map<String, dynamic>> prescriptions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _patientService.getPrescriptions(onlyActive: true);

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          prescriptions = List<Map<String, dynamic>>.from(result['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          prescriptions = [];
          isLoading = false;
          errorMessage = result['message'] ?? 'Erro ao carregar receitas';
        });
      }
    } catch (e) {
      setState(() {
        prescriptions = [];
        isLoading = false;
        errorMessage = 'Erro ao carregar receitas: ${e.toString()}';
      });
    }
  }

  String _getValorText() {
    if (selectedPrescriptionId == null) {
      return 'Valor: ${_formatCurrency(0.0)}';
    }

    final selectedPrescription = prescriptions.firstWhere(
      (p) => p['id'] == selectedPrescriptionId,
      orElse: () => {},
    );

    if (selectedPrescription.isEmpty) {
      return 'Valor: ${_formatCurrency(0.0)}';
    }

    final valorTotal = selectedPrescription['valorTotal'] as double? ?? 0.0;
    return 'Valor: ${_formatCurrency(valorTotal)}';
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF00BB5A),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 52,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 53,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFD6D6D3),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    final isSelected = selectedPrescriptionId == prescription['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPrescriptionId = prescription['id'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00994B) : const Color(0xFFE7E7F1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emissão: ${prescription['issueDate']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C7C79),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00994B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prescription['product'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prescrito pelo ${prescription['doctor']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.rotate(
                  angle: 4.7124, // 270 graus
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F8EF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Transform.rotate(
                      angle: -4.7124, // -270 graus para compensar
                      child:
                          const Icon(Icons.chevron_right, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Validade ${prescription['validity']}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7C7C79),
              ),
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
      appBar: const PatientAppBar(
        title: 'Novo pedido',
        fallbackRoute: '/patient/orders',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildProgressIndicator(),
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Novo pedido',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ],
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
                    'Etapa 1 - Selecione a receita',
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
                    _getValorText(),
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
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(
                    color: Color(0xFF00994B),
                  ),
                ),
              )
            else if (errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrescriptions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00994B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'Tentar novamente',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (prescriptions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Color(0xFF7C7C79),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma receita ativa encontrada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Você precisa de uma receita ativa para criar um novo pedido.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C79),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...prescriptions
                  .map((prescription) => _buildPrescriptionCard(prescription)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (selectedPrescriptionId != null && !isLoading)
                    ? () {
                        final p = prescriptions.firstWhere(
                          (e) => e['id'] == selectedPrescriptionId,
                          orElse: () => <String, dynamic>{},
                        );
                        if (p.isNotEmpty) {
                          final formData = NewOrderFormData(
                            prescriptionId: p['id'] as String,
                            productName: p['product'] as String? ?? 'Produto',
                            doctorName: p['doctor'] as String? ?? 'Médico',
                            valorTotal:
                                (p['valorTotal'] as num?)?.toDouble() ?? 0.0,
                            issueDate: p['issueDate'] as String?,
                            validity: p['validity'] as String?,
                            precoUnitario:
                                (p['valorTotal'] as num?)?.toDouble() ?? 0.0,
                          );
                          context.push(
                            '/patient/orders/new/step2',
                            extra: formData,
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00994B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
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
        currentIndex: 1, // Pedidos tab is active
      ),
    );
  }
}
