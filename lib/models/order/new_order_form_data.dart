/// Dados do formulário de novo pedido, passados entre as etapas.
class NewOrderFormData {
  /// ID da receita selecionada (step 1)
  final String prescriptionId;

  /// Nome do produto (exibição)
  final String productName;

  /// Nome do médico prescritor
  final String doctorName;

  /// Valor total da receita (base)
  final double valorTotal;

  /// Data de emissão (exibição)
  final String? issueDate;

  /// Validade (exibição)
  final String? validity;

  /// Quantidade escolhida pelo usuário (step 2)
  final int quantity;

  /// Canal de aquisição (ex.: "Associação ABC")
  final String canalAquisicao;

  /// Valor unitário usado no pedido (para cálculo)
  final double precoUnitario;

  /// URL do documento RG/CNH (step 3)
  final String? rgDocumentUrl;

  /// Nome do arquivo RG (exibição)
  final String? rgFileName;

  /// URL do comprovante de residência (step 3)
  final String? addressProofUrl;

  /// Nome do arquivo comprovante (exibição)
  final String? addressProofFileName;

  /// URL da autorização Anvisa (step 3)
  final String? anvisaDocumentUrl;

  /// Nome do arquivo Anvisa (exibição)
  final String? anvisaFileName;

  /// Endereço de entrega (step 5)
  final String? deliveryAddress;

  /// Forma de pagamento (ex.: 'credit_card', 'pix')
  final String? paymentMethod;

  /// Valor do frete (opcional)
  final double shippingCost;

  /// Comentários do prescritor (exibição step 2)
  final String? prescriberComments;

  /// Prazo de entrega (exibição)
  final String? deliveryDeadline;

  /// ID do produto (para createOrder - preenchido por getPrescriptionDetails)
  final String? produtoId;

  NewOrderFormData({
    required this.prescriptionId,
    required this.productName,
    required this.doctorName,
    required this.valorTotal,
    this.issueDate,
    this.validity,
    this.quantity = 1,
    this.canalAquisicao = 'Associação',
    this.precoUnitario = 0.0,
    this.rgDocumentUrl,
    this.rgFileName,
    this.addressProofUrl,
    this.addressProofFileName,
    this.anvisaDocumentUrl,
    this.anvisaFileName,
    this.deliveryAddress,
    this.paymentMethod,
    this.shippingCost = 0.0,
    this.prescriberComments,
    this.deliveryDeadline,
    this.produtoId,
  });

  /// Valor do produto (quantidade * preço unitário)
  double get productValue =>
      (precoUnitario > 0 ? precoUnitario : valorTotal) * quantity;

  /// Total com frete
  double get totalWithShipping => productValue + shippingCost;

  NewOrderFormData copyWith({
    String? prescriptionId,
    String? productName,
    String? doctorName,
    double? valorTotal,
    String? issueDate,
    String? validity,
    int? quantity,
    String? canalAquisicao,
    double? precoUnitario,
    String? rgDocumentUrl,
    String? rgFileName,
    String? addressProofUrl,
    String? addressProofFileName,
    String? anvisaDocumentUrl,
    String? anvisaFileName,
    String? deliveryAddress,
    String? paymentMethod,
    double? shippingCost,
    String? prescriberComments,
    String? deliveryDeadline,
    String? produtoId,
  }) {
    return NewOrderFormData(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      productName: productName ?? this.productName,
      doctorName: doctorName ?? this.doctorName,
      valorTotal: valorTotal ?? this.valorTotal,
      issueDate: issueDate ?? this.issueDate,
      validity: validity ?? this.validity,
      quantity: quantity ?? this.quantity,
      canalAquisicao: canalAquisicao ?? this.canalAquisicao,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      rgDocumentUrl: rgDocumentUrl ?? this.rgDocumentUrl,
      rgFileName: rgFileName ?? this.rgFileName,
      addressProofUrl: addressProofUrl ?? this.addressProofUrl,
      addressProofFileName: addressProofFileName ?? this.addressProofFileName,
      anvisaDocumentUrl: anvisaDocumentUrl ?? this.anvisaDocumentUrl,
      anvisaFileName: anvisaFileName ?? this.anvisaFileName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingCost: shippingCost ?? this.shippingCost,
      prescriberComments: prescriberComments ?? this.prescriberComments,
      deliveryDeadline: deliveryDeadline ?? this.deliveryDeadline,
      produtoId: produtoId ?? this.produtoId,
    );
  }
}
