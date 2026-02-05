import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../widgets/patient/new_order_step_progress.dart';
import '../../../widgets/patient/new_order_step_header.dart';
import '../../../models/order/new_order_form_data.dart';
import '../../../services/api/patient_service.dart';
import '../../../utils/currency_formatter.dart';

class NewOrderStep2Page extends StatefulWidget {
  final NewOrderFormData? formData;

  const NewOrderStep2Page({super.key, this.formData});

  @override
  State<NewOrderStep2Page> createState() => _NewOrderStep2PageState();
}

class _NewOrderStep2PageState extends State<NewOrderStep2Page> {
  final PatientService _patientService = PatientService();
  bool _loadingDetails = true;
  double? _precoUnitario;
  String? _produtoId;
  final String _prescriberComments =
      'Uso contínuo, conforme orientação médica.';
  final String _deliveryDeadline = 'até 15 dias úteis e 30 dias úteis';

  NewOrderFormData get formData => widget.formData!;

  @override
  void initState() {
    super.initState();
    if (widget.formData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/patient/orders/new/step1');
      });
      return;
    }
    _loadPrescriptionDetails();
  }

  Future<void> _loadPrescriptionDetails() async {
    if (widget.formData == null) return;
    setState(() => _loadingDetails = true);
    try {
      final result = await _patientService.getPrescriptionDetails(
        formData.prescriptionId,
      );
      if (mounted && result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _precoUnitario = (data['preco_unitario'] as num?)?.toDouble() ??
              formData.valorTotal;
          _produtoId = data['produto_id'] as String?;
          _loadingDetails = false;
        });
      } else {
        setState(() {
          _precoUnitario = formData.valorTotal;
          _loadingDetails = false;
        });
      }
    } catch (_) {
      setState(() {
        _precoUnitario = formData.valorTotal;
        _loadingDetails = false;
      });
    }
  }

  int get quantity => _quantity;
  int _quantity = 1;

  double get _productValue {
    final unitPrice = _precoUnitario ?? formData.valorTotal;
    return unitPrice * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formData == null) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF00994B))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Canal de aquisição',
        fallbackRoute: '/patient/orders/new/step1',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const NewOrderStepProgress(currentStep: 2),
            const SizedBox(height: 40),
            NewOrderStepHeader(
              stepLabel: 'Etapa 2 - Escolha o canal de aquisição',
              valueText: 'Valor: ${CurrencyFormatter.formatBRL(_productValue)}',
            ),
            const SizedBox(height: 24),
            if (_loadingDetails)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: Color(0xFF00994B)),
                ),
              )
            else ...[
              // Card Produto (Figma: imagem + detalhes à esquerda, quantidade à direita)
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
                      'Produto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
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
                                formData.productName,
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
                              const Text.rich(
                                TextSpan(
                                  text: 'Dosagem: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF3F3F3D),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '20mg/ml',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text.rich(
                                TextSpan(
                                  text: 'Concentração: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF3F3F3D),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '20mg/ml de THC',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  color: Color(0xFF007A3B)),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                side:
                                    const BorderSide(color: Color(0xFF007A3B)),
                                shape: const CircleBorder(),
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFF007A3B)),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF007A3B),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Color(0xFF007A3B)),
                              onPressed: () => setState(() => _quantity++),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                side:
                                    const BorderSide(color: Color(0xFF007A3B)),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ],
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
                    const Row(
                      children: [
                        Text(
                          'Associação: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                        Text(
                          'ABC',
                          style: TextStyle(
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
                          CurrencyFormatter.formatBRL(_productValue),
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
                    const Divider(color: Color(0xFFE6E6E3)),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Text(
                          'Prazo: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                        Text(
                          'até 15 dias úteis e 30 dias úteis',
                          style: TextStyle(
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
                          'Requisitos: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7C7C79),
                          ),
                        ),
                        Text(
                          formData.validity != null
                              ? 'Receita válida até ${formData.validity}'
                              : 'Receita válida',
                          style: const TextStyle(
                            fontSize: 14,
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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comentários do prescritor',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formData.prescriberComments ?? _prescriberComments,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3F3F3D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Não interromper sem avisar o prescritor.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3F3F3D),
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
                  onPressed: () {
                    final updated = formData.copyWith(
                      quantity: _quantity,
                      precoUnitario: _precoUnitario ?? formData.valorTotal,
                      produtoId: _produtoId,
                      prescriberComments: _prescriberComments,
                      deliveryDeadline: _deliveryDeadline,
                      canalAquisicao: 'Associação ABC',
                    );
                    context.push('/patient/orders/new/step3', extra: updated);
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
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(
        currentIndex: 1,
      ),
    );
  }
}
