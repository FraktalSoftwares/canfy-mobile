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






