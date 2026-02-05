import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/common/bottom_navigation_bar_patient.dart';
import '../../../widgets/patient/patient_app_bar.dart';
import '../../../widgets/patient/new_order_step_progress.dart';
import '../../../widgets/patient/new_order_step_header.dart';
import '../../../models/order/new_order_form_data.dart';
import '../../../services/api/patient_service.dart';
import '../../../services/api/asaas_service.dart';
import '../../../utils/currency_formatter.dart';
import '../../../utils/input_masks.dart';

/// Etapa 5 - Pagamento (design Figma: endereço, valor total, cupom, crédito/débito/Pix).
/// Sem boleto. Integração Asaas.
class NewOrderStep5Page extends StatefulWidget {
  final NewOrderFormData? formData;

  const NewOrderStep5Page({super.key, this.formData});

  @override
  State<NewOrderStep5Page> createState() => _NewOrderStep5PageState();
}

class _NewOrderStep5PageState extends State<NewOrderStep5Page> {
  final PatientService _patientService = PatientService();
  final AsaasService _asaasService = AsaasService();

  bool _loadingPatient = true;
  String? _deliveryAddress;
  String? _pacienteId;
  String? _asaasCustomerId;
  String? _errorPatient;

  // Método: credit_card | debit_card | pix
  String _paymentMethod = 'credit_card';

  // Endereço de cobrança (Figma Etapa 5)
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _cepController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _bairroController = TextEditingController();
  final _complementoController = TextEditingController();

  // Cupom (opcional)
  final _couponController = TextEditingController();

  // Dados do cartão (crédito/débito)
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _validityController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cpfController = TextEditingController();
  int _installments = 1;

  bool _submitting = false;
  String? _submitError;

  // Após criar pedido + pagamento PIX: exibir tela PIX
  bool _showPixScreen = false;
  String? _createdOrderId;
  String? _pixCopyPaste;
  String? _invoiceUrl;
  String? _productNameForSuccess;
  String? _totalFormattedForSuccess;
  String? _deliveryEstimateForSuccess;

  @override
  void initState() {
    super.initState();
    if (widget.formData == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/patient/orders/new/step1');
      });
      return;
    }
    _loadPatient();
  }

  @override
  void dispose() {
    _logradouroController.dispose();
    _numeroController.dispose();
    _cepController.dispose();
    _estadoController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    _complementoController.dispose();
    _couponController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _validityController.dispose();
    _cvvController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    setState(() {
      _loadingPatient = true;
      _errorPatient = null;
    });
    try {
      final result = await _patientService.getCurrentPatient();
      if (!mounted) return;
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        final profile = data['profile'] as Map<String, dynamic>?;
        final paciente = data['paciente'] as Map<String, dynamic>?;
        if (paciente != null) {
          _pacienteId = paciente['id'] as String?;
          _deliveryAddress = (paciente['endereco_completo'] as String?)?.trim();
          if (_deliveryAddress == null || _deliveryAddress!.isEmpty) {
            _deliveryAddress =
                'Endereço não cadastrado. Edite em Conta > Dados básicos.';
          }
        } else {
          _deliveryAddress = 'Paciente não encontrado.';
        }
        if (profile != null) {
          _asaasCustomerId = profile['asaas_customer_id'] as String?;
        }
      } else {
        _errorPatient = result['message'] ?? 'Erro ao carregar dados';
      }
    } catch (e) {
      _errorPatient = 'Erro: ${e.toString()}';
    }
    if (mounted) setState(() => _loadingPatient = false);
  }

  Future<void> _ensureAsaasCustomer() async {
    if (_asaasCustomerId != null && _asaasCustomerId!.isNotEmpty) return;
    final result = await _patientService.getCurrentPatient();
    if (!mounted || result['success'] != true || result['data'] == null) return;
    final data = result['data'] as Map<String, dynamic>;
    final profile = data['profile'] as Map<String, dynamic>?;
    final paciente = data['paciente'] as Map<String, dynamic>?;
    final nome = profile?['nome_completo'] as String? ?? 'Cliente';
    final email = Supabase.instance.client.auth.currentUser?.email;
    final telefone = profile?['telefone'] as String?;
    final cpf = paciente?['cpf'] as String?;
    final sync = await _asaasService.syncCustomer(
      name: nome,
      email: email,
      mobilePhone: telefone,
      cpfCnpj: cpf,
    );
    if (mounted && sync['success'] == true && sync['data'] != null) {
      _asaasCustomerId = (sync['data'] as Map)['asaas_customer_id'] as String?;
      setState(() {});
    }
  }

  Future<void> _confirmPayment() async {
    final f = widget.formData!;
    if (_pacienteId == null) {
      setState(() => _submitError = 'Paciente não identificado.');
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      await _ensureAsaasCustomer();
      if (!mounted) return;
      if (_asaasCustomerId == null || _asaasCustomerId!.isEmpty) {
        setState(() {
          _submitting = false;
          _submitError =
              'Não foi possível vincular pagamento. Tente novamente.';
        });
        return;
      }

      // 1) Criar pedido
      final orderResult = await _patientService.createOrder(
        receitaId: f.prescriptionId,
        pacienteId: _pacienteId!,
        quantity: f.quantity,
        valorTotal: f.totalWithShipping,
        canalAquisicao: f.canalAquisicao,
        formaPagamento: _paymentMethod,
        produtoId: f.produtoId,
        precoUnitario: f.precoUnitario > 0 ? f.precoUnitario : f.valorTotal,
        rgDocumentUrl: f.rgDocumentUrl,
        addressProofUrl: f.addressProofUrl,
        anvisaDocumentUrl: f.anvisaDocumentUrl,
      );

      if (!mounted) return;
      if (orderResult['success'] != true || orderResult['data'] == null) {
        setState(() {
          _submitting = false;
          _submitError =
              orderResult['message'] ?? 'Não foi possível criar o pedido.';
        });
        return;
      }

      final orderData = orderResult['data'] as Map<String, dynamic>;
      final orderId = orderData['id'] as String?;
      if (orderId == null) {
        setState(() {
          _submitting = false;
          _submitError = 'Pedido criado mas ID não retornado.';
        });
        return;
      }

      _productNameForSuccess = f.productName;
      _totalFormattedForSuccess =
          CurrencyFormatter.formatBRL(f.totalWithShipping);
      _deliveryEstimateForSuccess = f.deliveryDeadline ?? 'A confirmar';

      // 2) Criar cobrança Asaas (PIX, crédito ou débito)
      final billingType = _paymentMethod == 'pix'
          ? 'pix'
          : _paymentMethod == 'debit_card'
              ? 'debit_card'
              : 'credit_card';

      final paymentResult = await _asaasService.createPayment(
        asaasCustomerId: _asaasCustomerId,
        value: f.totalWithShipping,
        billingType: billingType,
        description: 'Pedido $orderId',
        referenceType: 'order',
        referenceId: orderId,
      );

      if (!mounted) return;

      if (paymentResult['success'] != true || paymentResult['data'] == null) {
        setState(() {
          _submitting = false;
          _submitError = paymentResult['message'] ?? 'Erro ao gerar pagamento.';
        });
        return;
      }

      final payData = paymentResult['data'] as Map<String, dynamic>;
      final invoiceUrl = payData['invoiceUrl'] as String?;
      final pixCopyPaste = payData['pixCopyPaste'] as String?;
      final status = payData['status'] as String?;

      if (_paymentMethod == 'pix') {
        setState(() {
          _submitting = false;
          _showPixScreen = true;
          _createdOrderId = orderId;
          _pixCopyPaste = pixCopyPaste;
          _invoiceUrl = invoiceUrl;
        });
        return;
      }

      // Cartão: se houver link, abrir; depois ir para detalhes ou sucesso
      if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
        final uri = Uri.parse(invoiceUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      if (status != null &&
          (status.toUpperCase() == 'CONFIRMED' ||
              status.toUpperCase() == 'RECEIVED')) {
        if (mounted) {
          context.go('/patient/orders/new/success', extra: {
            'orderId': orderId,
            'productName': _productNameForSuccess,
            'totalFormatted': _totalFormattedForSuccess,
            'deliveryEstimate': _deliveryEstimateForSuccess,
          });
        }
      } else {
        if (mounted) context.go('/patient/orders/$orderId');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitError = 'Erro: ${e.toString()}';
        });
      }
    }
  }

  Widget _buildBillingAddressForm() {
    const inputDecoration = InputDecoration(
      filled: true,
      fillColor: Color(0xFFF7F7F5),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFE6E6E3)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Color(0xFF7C7C79), fontSize: 14),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _logradouroController,
                decoration:
                    inputDecoration.copyWith(hintText: 'Ex: Rua rego freitas'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _numeroController,
                decoration: inputDecoration.copyWith(hintText: 'Ex: 452'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _cepController,
                decoration: inputDecoration.copyWith(hintText: 'Ex: 01240-001'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _estadoController,
                decoration: inputDecoration.copyWith(hintText: 'Ex: SP'),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cidadeController,
          decoration: inputDecoration.copyWith(hintText: 'Ex: São Paulo'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bairroController,
          decoration: inputDecoration.copyWith(hintText: 'Ex: Vila Madalena'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _complementoController,
          decoration: inputDecoration.copyWith(hintText: 'Ex: Apto 2006'),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF00994B) : const Color(0xFFE7E7F1),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF00994B), size: 22),
            ),
            const SizedBox(width: 12),
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
              value: value,
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              activeColor: const Color(0xFF00994B),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.formData == null) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF00994B))),
      );
    }

    final f = widget.formData!;

    if (_showPixScreen && _createdOrderId != null) {
      return _buildPixScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PatientAppBar(
        title: 'Endereço',
        fallbackRoute: '/patient/orders/new/step4',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const NewOrderStepProgress(currentStep: 5),
            const SizedBox(height: 40),
            NewOrderStepHeader(
              stepLabel: 'Etapa 5 - Preencha seu endereço',
              valueText:
                  'Valor: ${CurrencyFormatter.formatBRL(f.totalWithShipping)}',
            ),
            const SizedBox(height: 24),

            // Card Valor total (Figma: primeiro card)
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
                    'Valor total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _valueRow('Valor do produto',
                      CurrencyFormatter.formatBRL(f.productValue)),
                  const SizedBox(height: 4),
                  _valueRow('Valor do frete',
                      CurrencyFormatter.formatBRL(f.shippingCost)),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFFE6E6E3)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatBRL(f.totalWithShipping),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3F3F3D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Endereço de cobrança (Figma)
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
                    'Endereço de cobrança',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Endereço de cobrança',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7C7C79),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBillingAddressForm(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Endereço de entrega (leitura) + link editar
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
                    'Endereço de entrega',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingPatient)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                                color: Color(0xFF00994B))))
                  else if (_errorPatient != null)
                    Text(_errorPatient!,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF7C7C79)))
                  else
                    Text(
                      _deliveryAddress ?? 'Endereço não cadastrado.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3F3F3D),
                      ),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.push('/patient/account/basic-data'),
                    child: const Text(
                      'Editar endereço',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00994B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cupom
            const Text(
              'Cupom de desconto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const Text(
              '(opcional)',
              style: TextStyle(fontSize: 12, color: Color(0xFF7C7C79)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _couponController,
              decoration: InputDecoration(
                hintText: 'Código do cupom',
                hintStyle: const TextStyle(color: Color(0xFF00994B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00994B)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF33CC80)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // Método de pagamento
            const Text(
              'Método de pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Atualize seu método de pagamento de forma rápida e segura.',
              style: TextStyle(fontSize: 14, color: Color(0xFF7C7C79)),
            ),
            const SizedBox(height: 16),

            _buildPaymentOption(
              value: 'credit_card',
              label: 'Cartão de crédito',
              icon: Icons.credit_card,
            ),
            _buildPaymentOption(
              value: 'debit_card',
              label: 'Cartão de débito',
              icon: Icons.credit_card,
            ),
            _buildPaymentOption(
              value: 'pix',
              label: 'Pix',
              icon: Icons.qr_code_2,
            ),

            // Formulário expandido: cartão (crédito ou débito)
            if (_paymentMethod == 'credit_card' ||
                _paymentMethod == 'debit_card') ...[
              const SizedBox(height: 20),
              _buildCardForm(),
            ],

            if (_submitError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFC62828), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _submitError!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    (_submitting || _loadingPatient || _pacienteId == null)
                        ? null
                        : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00994B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _paymentMethod == 'pix'
                            ? 'Gerar código Pix'
                            : 'Confirmar pagamento',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _valueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7C7C79),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7C7C79),
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00994B), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card, color: Color(0xFF00994B), size: 24),
              const SizedBox(width: 8),
              Text(
                _paymentMethod == 'credit_card'
                    ? 'Informações do cartão de crédito'
                    : 'Informações do cartão de débito',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Color(0xFF00994B)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Nome do cartão',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 6),
          TextField(
            controller: _cardNameController,
            decoration: _inputDecoration('Nome como no cartão'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          const Text('Número do cartão',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 6),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [InputMasks.cardNumber],
            decoration: _inputDecoration('0000 0000 0000 0000'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Validade',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3F3F3D))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _validityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [InputMasks.cardValidity],
                      decoration: _inputDecoration('MM/AA'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CVV',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3F3F3D))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [InputMasks.cvv],
                      decoration: _inputDecoration('123'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('CPF do titular',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3F3F3D))),
          const SizedBox(height: 6),
          TextField(
            controller: _cpfController,
            keyboardType: TextInputType.number,
            inputFormatters: [InputMasks.cpf],
            decoration: _inputDecoration('000.000.000-00'),
          ),
          if (_paymentMethod == 'credit_card') ...[
            const SizedBox(height: 16),
            const Text('Número de parcelas',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3F3F3D))),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _installments,
              decoration: _inputDecoration(null),
              items: List.generate(12, (i) => i + 1)
                  .map((i) => DropdownMenuItem<int>(
                        value: i,
                        child: Text(
                          i == 1
                              ? '1x de ${CurrencyFormatter.formatBRL(widget.formData!.totalWithShipping)} (parcela única)'
                              : '${i}x de ${CurrencyFormatter.formatBRL(widget.formData!.totalWithShipping / i)}',
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _installments = v ?? 1),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'Política de Cancelamento',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C7C79),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Cancelamento até 12h antes: reembolso integral\n'
            '• Cancelamento após 12h: sem reembolso\n'
            '• Reagendamento permitido até 2h antes',
            style: TextStyle(fontSize: 12, color: Color(0xFF7C7C79)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE7E7F1)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildPixScreen() {
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
          'Pix',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escaneie ou copie este código para pagar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Acesse o app do seu banco\n'
              '2. Escolha pagar com Pix\n'
              '3. Cole o seguinte código:',
              style: TextStyle(fontSize: 14, color: Color(0xFF7C7C79)),
            ),
            const SizedBox(height: 24),
            if (_invoiceUrl != null && _invoiceUrl!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(_invoiceUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir página de pagamento Pix'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00994B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_pixCopyPaste != null && _pixCopyPaste!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F8EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00994B)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _pixCopyPaste!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF00994B)),
                      onPressed: () {
                        // Clipboard.setData(ClipboardData(text: _pixCopyPaste));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Código copiado'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.go(
                    '/patient/orders/new/success',
                    extra: {
                      'orderId': _createdOrderId,
                      'productName': _productNameForSuccess,
                      'totalFormatted': _totalFormattedForSuccess,
                      'deliveryEstimate': _deliveryEstimateForSuccess,
                    },
                  );
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
      bottomNavigationBar: const PatientBottomNavigationBar(currentIndex: 1),
    );
  }
}
