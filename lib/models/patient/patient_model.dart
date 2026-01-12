/// Modelo de paciente
/// 
/// Combina dados de profiles (dados gerais) e pacientes (dados específicos)
class PatientModel {
  // Dados do profile
  final String id; // user_id (mesmo que profiles.id)
  final String nomeCompleto;
  final String? telefone;
  final String? fotoPerfilUrl;
  final String tipoUsuario; // 'paciente', 'medico', 'admin'
  final bool ativo;
  
  // Dados específicos da tabela pacientes
  final String? cpf;
  final DateTime? dataNascimento;
  final String? enderecoCompleto;
  final int totalConsultas;
  final int totalPedidos;
  final DateTime? ultimoAcesso;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientModel({
    required this.id,
    required this.nomeCompleto,
    this.telefone,
    this.fotoPerfilUrl,
    required this.tipoUsuario,
    this.ativo = true,
    this.cpf,
    this.dataNascimento,
    this.enderecoCompleto,
    this.totalConsultas = 0,
    this.totalPedidos = 0,
    this.ultimoAcesso,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria PatientModel a partir de dados do profile e pacientes
  factory PatientModel.fromProfileAndPaciente({
    required Map<String, dynamic> profile,
    Map<String, dynamic>? paciente,
  }) {
    return PatientModel(
      id: profile['id'] as String,
      nomeCompleto: profile['nome_completo'] as String,
      telefone: profile['telefone'] as String?,
      fotoPerfilUrl: profile['foto_perfil_url'] as String?,
      tipoUsuario: profile['tipo_usuario'] as String,
      ativo: profile['ativo'] as bool? ?? true,
      cpf: paciente?['cpf'] as String?,
      dataNascimento: paciente?['data_nascimento'] != null
          ? DateTime.parse(paciente!['data_nascimento'] as String)
          : null,
      enderecoCompleto: paciente?['endereco_completo'] as String?,
      totalConsultas: paciente?['total_consultas'] as int? ?? 0,
      totalPedidos: paciente?['total_pedidos'] as int? ?? 0,
      ultimoAcesso: paciente?['ultimo_acesso'] != null
          ? DateTime.parse(paciente!['ultimo_acesso'] as String)
          : null,
      createdAt: DateTime.parse(profile['created_at'] as String),
      updatedAt: DateTime.parse(profile['updated_at'] as String),
    );
  }

  /// Cria PatientModel apenas com dados do profile (quando não há registro em pacientes ainda)
  factory PatientModel.fromProfile(Map<String, dynamic> profile) {
    return PatientModel(
      id: profile['id'] as String,
      nomeCompleto: profile['nome_completo'] as String,
      telefone: profile['telefone'] as String?,
      fotoPerfilUrl: profile['foto_perfil_url'] as String?,
      tipoUsuario: profile['tipo_usuario'] as String,
      ativo: profile['ativo'] as bool? ?? true,
      createdAt: DateTime.parse(profile['created_at'] as String),
      updatedAt: DateTime.parse(profile['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'telefone': telefone,
      'foto_perfil_url': fotoPerfilUrl,
      'tipo_usuario': tipoUsuario,
      'ativo': ativo,
      'cpf': cpf,
      'data_nascimento': dataNascimento?.toIso8601String().split('T')[0],
      'endereco_completo': enderecoCompleto,
      'total_consultas': totalConsultas,
      'total_pedidos': totalPedidos,
      'ultimo_acesso': ultimoAcesso?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
