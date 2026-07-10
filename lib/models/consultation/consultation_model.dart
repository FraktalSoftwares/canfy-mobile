/// Modelo de consulta
class ConsultationModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialty;
  final String? doctorAvatar;
  final String patientId;
  final DateTime scheduledDate;
  final String? reason;
  final ConsultationStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ConsultationModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialty,
    this.doctorAvatar,
    required this.patientId,
    required this.scheduledDate,
    this.reason,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      doctorAvatar: json['doctorAvatar'] as String?,
      patientId: json['patientId'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      reason: json['reason'] as String?,
      status: ConsultationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ConsultationStatus.scheduled,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorAvatar': doctorAvatar,
      'patientId': patientId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'reason': reason,
      'status': status.toString(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

enum ConsultationStatus {
  scheduled,
  inProgress,
  finished,
  cancelled,
}

/// Modelo de endereço para cobrança
class BillingAddress {
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final String? complement;

  BillingAddress({
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    this.complement,
  });

  factory BillingAddress.fromJson(Map<String, dynamic> json) {
    return BillingAddress(
      street: json['street'] as String? ?? '',
      number: json['number'] as String? ?? '',
      neighborhood: json['neighborhood'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      complement: json['complement'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'complement': complement,
    };
  }

  BillingAddress copyWith({
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    String? complement,
  }) {
    return BillingAddress(
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      complement: complement ?? this.complement,
    );
  }

  bool get isValid =>
      street.isNotEmpty &&
      number.isNotEmpty &&
      neighborhood.isNotEmpty &&
      city.isNotEmpty &&
      state.isNotEmpty &&
      zipCode.isNotEmpty;
}

/// Modelo para armazenar dados do formulário de nova consulta entre as etapas
class NewConsultationFormData {
  // Step 1 - Motivo da consulta
  final List<String> symptoms;
  final String? description;
  final double? peso;
  final double? altura;

  // Step 2 - Data e horário
  final DateTime? selectedDate;
  final String? selectedTime;

  // Step 3 - Endereço
  final BillingAddress? billingAddress;

  // Step 4 - Pagamento
  final String? paymentMethod;
  final String? couponCode;

  // Valor da consulta (fixo por enquanto)
  final double consultationValue;

  // Histórico de saúde (entre step 1 e step 2)
  final List<String> examesRecentes;
  final List<String> produtosUtilizados;
  final String? reacoesAdversas;
  final bool? prefereProdutosNacionais;

  NewConsultationFormData({
    this.symptoms = const [],
    this.description,
    this.peso,
    this.altura,
    this.selectedDate,
    this.selectedTime,
    this.billingAddress,
    this.paymentMethod,
    this.couponCode,
    this.consultationValue = 200.0,
    this.examesRecentes = const [],
    this.produtosUtilizados = const [],
    this.reacoesAdversas,
    this.prefereProdutosNacionais,
  });

  /// Cria uma cópia com os campos atualizados
  NewConsultationFormData copyWith({
    List<String>? symptoms,
    String? description,
    double? peso,
    double? altura,
    DateTime? selectedDate,
    String? selectedTime,
    BillingAddress? billingAddress,
    String? paymentMethod,
    String? couponCode,
    double? consultationValue,
    List<String>? examesRecentes,
    List<String>? produtosUtilizados,
    String? reacoesAdversas,
    bool? prefereProdutosNacionais,
  }) {
    return NewConsultationFormData(
      symptoms: symptoms ?? this.symptoms,
      description: description ?? this.description,
      peso: peso ?? this.peso,
      altura: altura ?? this.altura,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      billingAddress: billingAddress ?? this.billingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      couponCode: couponCode ?? this.couponCode,
      consultationValue: consultationValue ?? this.consultationValue,
      examesRecentes: examesRecentes ?? this.examesRecentes,
      produtosUtilizados: produtosUtilizados ?? this.produtosUtilizados,
      reacoesAdversas: reacoesAdversas ?? this.reacoesAdversas,
      prefereProdutosNacionais:
          prefereProdutosNacionais ?? this.prefereProdutosNacionais,
    );
  }

  /// Formata a data e horário para exibição
  String get formattedDateTime {
    if (selectedDate == null || selectedTime == null) return '--';
    final day = selectedDate!.day.toString().padLeft(2, '0');
    final month = selectedDate!.month.toString().padLeft(2, '0');
    final year = selectedDate!.year;
    return '$day/$month/$year • $selectedTime';
  }

  /// Formata o valor para exibição
  String get formattedValue {
    return 'R\$ ${consultationValue.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se o step 1 está completo
  bool get isStep1Complete => symptoms.isNotEmpty;

  /// Verifica se o step 2 está completo
  bool get isStep2Complete => selectedDate != null && selectedTime != null;

  /// Verifica se o step 3 está completo
  bool get isStep3Complete => billingAddress != null && billingAddress!.isValid;

  /// Verifica se o step 4 está completo
  bool get isStep4Complete => paymentMethod != null;

  Map<String, dynamic> toJson() {
    return {
      'symptoms': symptoms,
      'description': description,
      'peso': peso,
      'altura': altura,
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedTime': selectedTime,
      'billingAddress': billingAddress?.toJson(),
      'paymentMethod': paymentMethod,
      'couponCode': couponCode,
      'consultationValue': consultationValue,
      'examesRecentes': examesRecentes,
      'produtosUtilizados': produtosUtilizados,
      'reacoesAdversas': reacoesAdversas,
      'prefereProdutosNacionais': prefereProdutosNacionais,
    };
  }

  factory NewConsultationFormData.fromJson(Map<String, dynamic> json) {
    return NewConsultationFormData(
      symptoms: (json['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String?,
      peso: (json['peso'] as num?)?.toDouble(),
      altura: (json['altura'] as num?)?.toDouble(),
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'] as String)
          : null,
      selectedTime: json['selectedTime'] as String?,
      billingAddress: json['billingAddress'] != null
          ? BillingAddress.fromJson(
              json['billingAddress'] as Map<String, dynamic>)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      couponCode: json['couponCode'] as String?,
      consultationValue:
          (json['consultationValue'] as num?)?.toDouble() ?? 200.0,
      examesRecentes:
          (json['examesRecentes'] as List<dynamic>?)?.cast<String>() ?? [],
      produtosUtilizados:
          (json['produtosUtilizados'] as List<dynamic>?)?.cast<String>() ??
              [],
      reacoesAdversas: json['reacoesAdversas'] as String?,
      prefereProdutosNacionais: json['prefereProdutosNacionais'] as bool?,
    );
  }
}
