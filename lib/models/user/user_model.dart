/// Modelo de usuário
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final UserType type;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.type,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      type: UserType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => UserType.patient,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'type': type.toString(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

enum UserType {
  patient,
  doctor,
  prescriber,
}





