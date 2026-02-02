import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';
import '../../../services/api/patient_service.dart';
import '../../../services/api/asaas_service.dart';
import '../../../models/consultation/consultation_model.dart';
import '../../../utils/input_masks.dart';
import '../../../widgets/consultation/consultation_widgets.dart';

class NewConsultationStep4Page extends StatefulWidget {
  final NewConsultationFormData? formData;

  const NewConsultationStep4Page({super.key, this.formData});

  @override
  State<NewConsultationStep4Page> createState() =>
      _NewConsultationStep4PageState();
}

class _NewConsultationStep4PageState extends State<NewConsultationStep4Page> {
  final PatientService _patientService = PatientService();
  final AsaasService _asaasService = AsaasService();
  String? _selectedPaymentMethod;
  final TextEditingController _couponController = TextEditingController();
  // Cartão
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardValidityController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardCpfController = TextEditingController();

  String? _patientAvatar;
  bool _isLoadingAvatar = true;
  bool _isProcessing = false;
  int _installments = 1; // 1x a 12x para crédito

  // PIX
  String? _pixCopyPasteKey;
  String? _pixInvoiceUrl;
  bool _pixGenerating = false;
  int _pixResendCountdown = 0;

  NewConsultationFormData get _formData =>
      widget.formData ?? NewConsultationFormData();

  @override
  void initState() {
    super.initState();
    _loadPatientAvatar();
    _startPixResendTimer();
  }

  void _startPixResendTimer() {
    if (_pixResendCountdown <= 0) return;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _pixResendCountdown--;
        if (_pixResendCountdown <= 0) return;
      });
      return _pixResendCountdown > 0;
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardValidityController.dispose();
    _cardCvvController.dispose();
    _cardCpfController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientAvatar() async {
    try {
      final result = await _patientService.getCurrentPatient();
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>?;
        final profile = data?['profile'] as Map<String, dynamic>?;
        if (profile != null) {
          setState(() {
            _patientAvatar = profile['foto_perfil_url'] as String?;
            _isLoadingAvatar = false;
          });
        } else {
          setState(() => _isLoadingAvatar = false);
        }
      } else {
        setState(() => _isLoadingAvatar = false);
      }
    } catch (e) {
      setState(() => _isLoadingAvatar = false);
    }
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
      if (method != 'pix') {
        _pixCopyPasteKey = null;
        _pixInvoiceUrl = null;
      }
    });
  }

  /// Retorna mensagem de erro do primeiro campo inválido, ou null se tudo ok.
  String? _getCardFormValidationError() {
    if (_cardNameController.text.trim().length < 3) {
      return 'Nome do cartão deve ter pelo menos 3 caracteres.';
    }
    if (InputMasks.removeNonNumeric(_cardNumberController.text).length < 15) {
      return 'Informe o número completo do cartão (15 ou 16 dígitos).';
    }
    if (_cardValidityController.text.length != 5) {
      return 'Informe a validade no formato MM/AA.';
    }
    if (_cardCvvController.text.length < 3) {
      return 'Informe o CVV (3 ou 4 dígitos).';
    }
    if (!InputMasks.isValidCPF(_cardCpfController.text)) {
      final digits = InputMasks.removeNonNumeric(_cardCpfController.text);
      if (digits.length != 11) {
        return 'CPF deve ter 11 dígitos.';
      }
      return 'CPF inválido. Verifique os dígitos (para testes use 123.456.789-09).';
    }
    return null;
  }

  /// Monta data/hora da consulta em ISO para o backend (selectedDate + selectedTime).
  String? _buildDataConsultaIso() {
    final date = _formData.selectedDate;
    final timeStr = _formData.selectedTime;
    if (date == null || timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(RegExp(r'[:\s]'));
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 10 : 10;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final dt = DateTime(date.year, date.month, date.day, hour, minute);
    return dt.toUtc().toIso8601String();
  }

  /// Cria a consulta no backend e retorna o id, ou null em caso de erro.
  Future<String?> _createConsultationAndGetId(Map<String, dynamic> paciente,
      String? dataConsultaIso, String queixaPrincipal) async {
    final pacienteId = paciente['id'] as String?;
    if (pacienteId == null) return null;
    final iso = dataConsultaIso ??
        DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String();
    final result = await _patientService.createConsultation(
      pacienteId: pacienteId,
      dataConsultaIso: iso,
      queixaPrincipal:
          queixaPrincipal.isEmpty ? 'Consulta agendada' : queixaPrincipal,
    );
    if (result['success'] != true || result['data'] == null) return null;
    final data = result['data'] as Map<String, dynamic>?;
    return data?['id'] as String?;
  }

  /// Obtém o asaas_customer_id do profile ou cria/sincroniza o cliente no Asaas.
  /// Retorna o id ou null em caso de erro.
  Future<String?> _getOrCreateAsaasCustomerId(
    Map<String, dynamic> profile,
    Map<String, dynamic>? paciente,
  ) async {
    final asaasCustomerId = profile['asaas_customer_id'] as String?;
    if (asaasCustomerId != null && asaasCustomerId.isNotEmpty) {
      return asaasCustomerId;
    }
    final name = profile['nome_completo'] as String? ?? 'Cliente';
    final email = profile['email'] as String?;
    final mobilePhone =
        (profile['telefone'] as String?)?.replaceAll(RegExp(r'\D'), '');
    final cpfCnpj = paciente?['cpf'] as String?;
    final syncResult = await _asaasService.syncCustomer(
      name: name,
      cpfCnpj: cpfCnpj,
      email: email,
      mobilePhone: mobilePhone,
    );
    if (syncResult['success'] != true) return null;
    final data = syncResult['data'] as Map<String, dynamic>?;
    return data?['asaas_customer_id'] as String?;
  }

  Future<void> _confirmCardPayment() async {
    if (_selectedPaymentMethod == null) return;
    final validationError = _getCardFormValidationError();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    setState(() => _isProcessing = true);

    try {
      final patientResult = await _patientService.getCurrentPatient();
      if (patientResult['success'] != true || patientResult['data'] == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar dados do paciente')),
          );
        }
        return;
      }

      final data = patientResult['data'] as Map<String, dynamic>;
      final profile = data['profile'] as Map<String, dynamic>?;
      final paciente = data['paciente'] as Map<String, dynamic>?;
      if (profile == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil não encontrado')),
          );
        }
        return;
      }

      final asaasCustomerId =
          await _getOrCreateAsaasCustomerId(profile, paciente);
      if (asaasCustomerId == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Erro ao obter dados de pagamento. Tente novamente.')),
          );
        }
        return;
      }

      if (paciente == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente não encontrado')),
          );
        }
        return;
      }

      final dataConsultaIso = _buildDataConsultaIso();
      final queixaPrincipal =
          (_formData.description ?? _formData.symptoms.join(', ')).trim();
      final consultationId = await _createConsultationAndGetId(
          paciente, dataConsultaIso, queixaPrincipal);
      if (consultationId == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erro ao criar a consulta. Tente novamente.')),
          );
        }
        return;
      }

      final dueDate = DateTime.now().add(const Duration(days: 3));
      final dueDateStr =
          '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';

      final paymentResult = await _asaasService.createPayment(
        asaasCustomerId: asaasCustomerId,
        value: _formData.consultationValue,
        billingType: _selectedPaymentMethod!,
        dueDate: dueDateStr,
        description: 'Consulta médica - Canfy',
        referenceType: 'consultation',
        referenceId: consultationId,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (paymentResult['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(paymentResult['message'] as String? ??
                  'Erro ao criar cobrança')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagamento confirmado com sucesso')),
      );
      context.go('/patient/consultations');
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _generatePixCode() async {
    if (_selectedPaymentMethod != 'pix') return;
    setState(() => _pixGenerating = true);

    try {
      final patientResult = await _patientService.getCurrentPatient();
      if (patientResult['success'] != true || patientResult['data'] == null) {
        if (mounted) {
          setState(() => _pixGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar dados do paciente')),
          );
        }
        return;
      }

      final data = patientResult['data'] as Map<String, dynamic>;
      final profile = data['profile'] as Map<String, dynamic>?;
      final paciente = data['paciente'] as Map<String, dynamic>?;
      if (profile == null) {
        if (mounted) {
          setState(() => _pixGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil não encontrado')),
          );
        }
        return;
      }

      final asaasCustomerId =
          await _getOrCreateAsaasCustomerId(profile, paciente);
      if (asaasCustomerId == null) {
        if (mounted) {
          setState(() => _pixGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Erro ao obter dados de pagamento. Tente novamente.')),
          );
        }
        return;
      }

      if (paciente == null) {
        if (mounted) {
          setState(() => _pixGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente não encontrado')),
          );
        }
        return;
      }

      final dataConsultaIso = _buildDataConsultaIso();
      final queixaPrincipal =
          (_formData.description ?? _formData.symptoms.join(', ')).trim();
      final consultationId = await _createConsultationAndGetId(
          paciente, dataConsultaIso, queixaPrincipal);
      if (consultationId == null) {
        if (mounted) {
          setState(() => _pixGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Erro ao criar a consulta. Tente novamente.')),
          );
        }
        return;
      }

      final dueDate = DateTime.now().add(const Duration(days: 3));
      final dueDateStr =
          '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';

      final paymentResult = await _asaasService.createPayment(
        asaasCustomerId: asaasCustomerId,
        value: _formData.consultationValue,
        billingType: 'pix',
        dueDate: dueDateStr,
        description: 'Consulta médica - Canfy',
        referenceType: 'consultation',
        referenceId: consultationId,
      );

      if (!mounted) return;
      setState(() => _pixGenerating = false);

      if (paymentResult['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  paymentResult['message'] as String? ?? 'Erro ao gerar Pix')),
        );
        return;
      }

      final paymentData = paymentResult['data'] as Map<String, dynamic>?;
      final invoiceUrl = paymentData?['invoiceUrl'] as String?;
      final payload = paymentData?['payload'] as String?;
      final invoiceKey = paymentData?['invoiceKey'] as String?;

      setState(() {
        _pixInvoiceUrl = invoiceUrl;
        _pixCopyPasteKey = payload ?? invoiceKey ?? invoiceUrl ?? '';
        _pixResendCountdown = 60;
      });
      _startPixResendTimer();
    } catch (e) {
      if (mounted) {
        setState(() => _pixGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }

  void _copyPixKey() {
    if (_pixCopyPasteKey == null || _pixCopyPasteKey!.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _pixCopyPasteKey!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código Pix copiado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCardSelected = _selectedPaymentMethod == 'credit_card' ||
        _selectedPaymentMethod == 'debit_card';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ConsultationAppBar(
        avatarWidget: ConsultationAvatar(
          avatarUrl: _patientAvatar,
          isLoading: _isLoadingAvatar,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ConsultationStepIndicator(currentStep: 4),
            const SizedBox(height: 20),
            ConsultationStepHeader(
              stepNumber: 4,
              stepTitle: 'Pagamento',
              valueText: 'Valor: ${_formData.formattedValue}',
            ),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildCouponField(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            if (_selectedPaymentMethod == 'credit_card') _buildCreditCardForm(),
            if (_selectedPaymentMethod == 'debit_card') _buildDebitCardForm(),
            if (_selectedPaymentMethod == 'pix') _buildPixForm(),
            if (isCardSelected) ...[
              const SizedBox(height: 24),
              _buildCancellationPolicy(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return ConsultationSectionCard(
      title: 'Resumo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConsultationDetailRow(
            label: 'Dia e horário',
            value: _formData.formattedDateTime,
          ),
          ConsultationDetailRow(
            label: 'Valor da consulta',
            value: _formData.formattedValue,
          ),
          const Text(
            'Queixas principais',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _formData.symptoms
                .map((symptom) => ConsultationSymptomTag(
                      symptom: symptom,
                      isReadOnly: true,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponField() {
    return ConsultationTextField(
      label: 'Cupom de desconto (opcional)',
      controller: _couponController,
      hintText: 'Digite o código do cupom',
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de pagamento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Atualize seu método de pagamento de forma rápida e segura.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 16),
        _PaymentOptionTile(
          method: 'credit_card',
          label: 'Cartão de crédito',
          icon: Icons.credit_card_rounded,
          isSelected: _selectedPaymentMethod == 'credit_card',
          onTap: () => _selectPaymentMethod('credit_card'),
        ),
        _PaymentOptionTile(
          method: 'debit_card',
          label: 'Cartão de débito',
          icon: Icons.credit_card_outlined,
          isSelected: _selectedPaymentMethod == 'debit_card',
          onTap: () => _selectPaymentMethod('debit_card'),
        ),
        _PaymentOptionTile(
          method: 'pix',
          label: 'Pix',
          icon: Icons.qr_code_rounded,
          isSelected: _selectedPaymentMethod == 'pix',
          onTap: () => _selectPaymentMethod('pix'),
        ),
      ],
    );
  }

  Widget _buildCreditCardForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: ConsultationSectionCard(
        title: 'Informações do cartão de crédito',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de pagamento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral200),
                color: Colors.white,
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: AppColors.canfyGreen),
                  SizedBox(width: 12),
                  Text(
                    'Cartão de crédito',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInstallmentsDropdown(),
            const SizedBox(height: 16),
            const Text(
              'Dados do cartão',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ConsultationTextField(
              label: 'Nome do cartão',
              controller: _cardNameController,
              hintText: 'Como está no cartão',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ConsultationTextField(
              label: 'Número do cartão',
              controller: _cardNumberController,
              hintText: '0000 0000 0000 0000',
              keyboardType: TextInputType.number,
              inputFormatters: [InputMasks.cardNumber],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ConsultationTextField(
                    label: 'Validade',
                    controller: _cardValidityController,
                    hintText: 'MM/AA',
                    keyboardType: TextInputType.number,
                    inputFormatters: [InputMasks.cardValidity],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConsultationTextField(
                    label: 'CVV',
                    controller: _cardCvvController,
                    hintText: '***',
                    keyboardType: TextInputType.number,
                    inputFormatters: [InputMasks.cvv],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConsultationTextField(
              label: 'CPF',
              controller: _cardCpfController,
              hintText: '000.000.000-00',
              keyboardType: TextInputType.number,
              inputFormatters: [InputMasks.cpf],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            ConsultationPrimaryButton(
              text: 'Confirmar pagamento',
              onPressed: _isProcessing ? null : _confirmCardPayment,
              isLoading: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallmentsDropdown() {
    final value = _formData.consultationValue;
    final options = <int, String>{};
    for (int i = 1; i <= 12; i++) {
      final parcelValue = value / i;
      options[i] = i == 1
          ? '1x de ${_formatCurrency(value)} (parcela única)'
          : '${i}x de ${_formatCurrency(parcelValue)}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Número de parcelas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral200),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _installments.clamp(1, 12),
              isExpanded: true,
              items: options.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          e.value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.neutral900,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _installments = v ?? 1),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double v) {
    return 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _buildDebitCardForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: ConsultationSectionCard(
        title: 'Informações do cartão de débito',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados do cartão',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 12),
            ConsultationTextField(
              label: 'Nome do cartão',
              controller: _cardNameController,
              hintText: 'Como está no cartão',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ConsultationTextField(
              label: 'Número do cartão',
              controller: _cardNumberController,
              hintText: '0000 0000 0000 0000',
              keyboardType: TextInputType.number,
              inputFormatters: [InputMasks.cardNumber],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ConsultationTextField(
                    label: 'Validade',
                    controller: _cardValidityController,
                    hintText: 'MM/AA',
                    keyboardType: TextInputType.number,
                    inputFormatters: [InputMasks.cardValidity],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConsultationTextField(
                    label: 'CVV',
                    controller: _cardCvvController,
                    hintText: '***',
                    keyboardType: TextInputType.number,
                    inputFormatters: [InputMasks.cvv],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConsultationTextField(
              label: 'CPF',
              controller: _cardCpfController,
              hintText: '000.000.000-00',
              keyboardType: TextInputType.number,
              inputFormatters: [InputMasks.cpf],
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            ConsultationPrimaryButton(
              text: 'Confirmar pagamento',
              onPressed: _isProcessing ? null : _confirmCardPayment,
              isLoading: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: ConsultationSectionCard(
        title: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escaneie ou copie este código para pagar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 16),
            _buildPixStep(1, 'Acesse o app do seu banco'),
            const SizedBox(height: 8),
            _buildPixStep(2, 'Escolha pagar com Pix'),
            const SizedBox(height: 8),
            _buildPixStep(3, 'Cole o seguinte código:'),
            const SizedBox(height: 20),
            if (_pixCopyPasteKey == null || _pixCopyPasteKey!.isEmpty)
              Center(
                child: ConsultationPrimaryButton(
                  text: 'Gerar código Pix',
                  onPressed: _pixGenerating ? null : _generatePixCode,
                  isLoading: _pixGenerating,
                ),
              )
            else ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.neutral200),
                  ),
                  child: QrImageView(
                    data: _pixCopyPasteKey!,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.canfyGreen.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _pixCopyPasteKey!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral800,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: _copyPixKey,
                      icon: const Icon(Icons.copy_rounded),
                      color: AppColors.canfyGreen,
                    ),
                  ],
                ),
              ),
              if (_pixInvoiceUrl != null && _pixInvoiceUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(_pixInvoiceUrl!);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_browser, size: 18),
                      label: const Text('Abrir em navegador'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.canfyGreen,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _pixResendCountdown > 0
                      ? null
                      : () {
                          setState(() {
                            _pixCopyPasteKey = null;
                            _pixInvoiceUrl = null;
                            _pixResendCountdown = 60;
                          });
                          _generatePixCode();
                          _startPixResendTimer();
                        },
                  child: Text(
                    _pixResendCountdown > 0
                        ? 'Reenviar email (${_pixResendCountdown}s)'
                        : 'Reenviar email',
                    style: TextStyle(
                      fontSize: 14,
                      color: _pixResendCountdown > 0
                          ? AppColors.neutral600
                          : AppColors.canfyGreen,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPixStep(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.canfyGreen,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.neutral800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancellationPolicy() {
    return ConsultationSectionCard(
      title: 'Política de Cancelamento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicyItem(
            icon: Icons.check_circle_outline,
            text: 'Cancelamento até 12h antes: reembolso integral',
            isPositive: true,
          ),
          const SizedBox(height: 12),
          _buildPolicyItem(
            icon: Icons.warning_amber_rounded,
            text: 'Cancelamento após 12h antes: sem reembolso',
            isPositive: false,
          ),
          const SizedBox(height: 12),
          _buildPolicyItem(
            icon: Icons.schedule_rounded,
            text: 'Reagendamento permitido até 2h antes',
            isPositive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String text,
    required bool isPositive,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isPositive ? AppColors.canfyGreen : AppColors.neutral600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.neutral600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String method;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.method,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neutral100 : AppColors.neutral050,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.canfyGreen : AppColors.neutral200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0x1A00994B) : AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.canfyGreen : AppColors.neutral800,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.neutral900,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.canfyGreen : AppColors.neutral300,
                  width: 2,
                ),
                color: isSelected ? AppColors.canfyGreen : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
