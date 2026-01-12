import '../api/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de autenticação e gerenciamento de usuários
/// 
/// IMPORTANTE: Este serviço usa o ApiService que por sua vez usa Supabase.
/// Para operações de schema (criação de tabelas), sempre use o MCP do Supabase.
/// 
/// Estrutura do banco:
/// - profiles: dados gerais do usuário (nome_completo, telefone, tipo_usuario)
/// - pacientes: dados específicos do paciente (cpf, data_nascimento, endereco_completo)
class AuthService {
  final ApiService _apiService = ApiService();

  /// Monta endereço completo a partir dos campos separados
  String _buildFullAddress({
    String? cep,
    String? address,
    String? addressNumber,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
  }) {
    final parts = <String>[];
    
    if (address != null && address.isNotEmpty) {
      parts.add(address);
      if (addressNumber != null && addressNumber.isNotEmpty) {
        parts.add('nº $addressNumber');
      }
    }
    
    if (neighborhood != null && neighborhood.isNotEmpty) {
      parts.add(neighborhood);
    }
    
    if (city != null && city.isNotEmpty) {
      parts.add(city);
    }
    
    if (state != null && state.isNotEmpty) {
      parts.add(state);
    }
    
    if (cep != null && cep.isNotEmpty) {
      parts.add('CEP: $cep');
    }
    
    if (complement != null && complement.isNotEmpty) {
      parts.add('($complement)');
    }
    
    return parts.join(', ');
  }

  /// Cadastrar novo paciente
  /// 
  /// Cria o usuário no Supabase Auth, depois cria o profile e o registro em pacientes
  Future<Map<String, dynamic>> registerPatient({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String cpf,
    required DateTime birthDate,
    String? gender,
    String? cep,
    String? address,
    String? addressNumber,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    bool authorizeDataSharing = false,
  }) async {
    try {
      // 1. Criar usuário no Supabase Auth
      // O trigger on_auth_user_created já cria o profile e paciente automaticamente
      // IMPORTANTE: O metadata deve ter os campos que o trigger espera
      final authResult = await _apiService.signUp(
        email: email,
        password: password,
        metadata: {
          'nome_completo': name, // O trigger handle_new_user usa este campo
          if (phone != null && phone.isNotEmpty) 'telefone': phone, // O trigger usa este campo
          'tipo_usuario': 'paciente', // O trigger usa este campo para determinar o tipo
        },
      );

      if (!authResult['success']) {
        return authResult;
      }

      final userData = authResult['data'] as Map<String, dynamic>;
      final user = userData['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      if (userId == null) {
        return {
          'success': false,
          'message': 'Erro ao obter ID do usuário criado',
          'data': null,
        };
      }

      // 2. Aguardar um pouco para o trigger processar (trigger é assíncrono)
      await Future.delayed(const Duration(milliseconds: 1000));

      // 3. Verificar se o profile foi criado pelo trigger e atualizar se necessário
      final existingProfile = await _apiService.getFiltered(
        'profiles',
        filters: {'id': userId},
        limit: 1,
      );

      Map<String, dynamic> profileResult;
      
      if (existingProfile['success'] == true && existingProfile['data'] != null) {
        // Profile existe, atualizar com dados completos
        final profileUpdateData = {
          'nome_completo': name,
          if (phone != null && phone.isNotEmpty) 'telefone': phone,
          'ativo': true,
        };

        profileResult = await _apiService.put(
          'profiles',
          {'id': userId},
          profileUpdateData,
        );

        if (!profileResult['success']) {
          // Continuar mesmo se falhar a atualização (dados básicos já estão no trigger)
          print('Aviso: Erro ao atualizar perfil: ${profileResult['message']}');
        }
      } else {
        // Profile não foi criado pelo trigger, criar manualmente
        final profileData = {
          'id': userId,
          'nome_completo': name,
          if (phone != null && phone.isNotEmpty) 'telefone': phone,
          'tipo_usuario': 'paciente',
          'ativo': true,
        };

        profileResult = await _apiService.post('profiles', profileData);
        if (!profileResult['success']) {
          return {
            'success': false,
            'message': 'Erro ao criar perfil: ${profileResult['message']}',
            'data': null,
            'error': profileResult['error'],
          };
        }
      }

      // 4. Montar endereço completo
      final enderecoCompleto = _buildFullAddress(
        cep: cep,
        address: address,
        addressNumber: addressNumber,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: state,
      );

      // 4. Verificar se o paciente foi criado pelo trigger e atualizar
      final existingPaciente = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': userId},
        limit: 1,
      );

      final pacienteUpdateData = {
        'cpf': cpf,
        'data_nascimento': birthDate.toIso8601String().split('T')[0],
        if (enderecoCompleto.isNotEmpty) 'endereco_completo': enderecoCompleto,
      };

      final pacienteResult = existingPaciente['success'] == true && 
                            existingPaciente['data'] != null &&
                            (existingPaciente['data'] as List).isNotEmpty
          ? await _apiService.put(
              'pacientes',
              {'user_id': userId},
              pacienteUpdateData,
            )
          : await _apiService.post(
              'pacientes',
              {
                'user_id': userId,
                ...pacienteUpdateData,
              },
            );

      if (!pacienteResult['success']) {
        return {
          'success': false,
          'message': 'Erro ao salvar dados do paciente: ${pacienteResult['message']}',
          'data': null,
          'error': pacienteResult['error'],
        };
      }

      return {
        'success': true,
        'message': 'Paciente cadastrado com sucesso',
        'data': {
          'user': user,
          'profile': profileResult['data'],
          'paciente': pacienteResult['data'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao cadastrar paciente: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Login do paciente
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _apiService.signIn(
        email: email,
        password: password,
      );

      if (!result['success']) {
        return result;
      }

      // Buscar dados do paciente (profile + pacientes)
      final userData = result['data'] as Map<String, dynamic>;
      final user = userData['user'] as Map<String, dynamic>?;
      final userId = user?['id'] as String?;

      if (userId != null) {
        // Buscar profile
        final profileResult = await _apiService.getFiltered(
          'profiles',
          filters: {'id': userId},
          limit: 1,
        );

        // Buscar dados específicos do paciente
        final pacienteResult = await _apiService.getFiltered(
          'pacientes',
          filters: {'user_id': userId},
          limit: 1,
        );

        final profiles = profileResult['success'] && profileResult['data'] != null
            ? profileResult['data'] as List
            : [];
        final pacientes = pacienteResult['success'] && pacienteResult['data'] != null
            ? pacienteResult['data'] as List
            : [];

        print('AuthService - Profile result: ${profileResult['success']}');
        print('AuthService - Profiles encontrados: ${profiles.length}');
        if (profiles.isNotEmpty) {
          print('AuthService - Profile data: ${profiles[0]}');
        }

        if (profiles.isNotEmpty) {
          final profileData = profiles[0] as Map<String, dynamic>;
          print('AuthService - Profile encontrado: $profileData');
          print('AuthService - Tipo usuário no profile: ${profileData['tipo_usuario']}');
          return {
            'success': true,
            'message': 'Login realizado com sucesso',
            'data': {
              'user': user,
              'session': userData['session'],
              'profile': profileData, // Retornar como Map diretamente
              'paciente': pacientes.isNotEmpty ? pacientes[0] : null,
            },
          };
        } else {
          print('AuthService - Nenhum profile encontrado para o usuário $userId');
          // Mesmo sem profile, retornar sucesso para permitir login
          // O app pode buscar o profile depois
          return {
            'success': true,
            'message': 'Login realizado com sucesso',
            'data': {
              'user': user,
              'session': userData['session'],
              'profile': null,
              'paciente': null,
            },
          };
        }
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao fazer login: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Logout
  Future<Map<String, dynamic>> logout() async {
    return await _apiService.signOut();
  }

  /// Obter dados completos do paciente atual (profile + pacientes)
  Future<Map<String, dynamic>> getCurrentPatient() async {
    try {
      final user = _apiService.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Buscar profile
      final profileResult = await _apiService.getFiltered(
        'profiles',
        filters: {'id': user.id},
        limit: 1,
      );

      // Buscar dados específicos do paciente
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      final profiles = profileResult['success'] && profileResult['data'] != null
          ? profileResult['data'] as List
          : [];
      final pacientes = pacienteResult['success'] && pacienteResult['data'] != null
          ? pacienteResult['data'] as List
          : [];

      if (profiles.isNotEmpty) {
        return {
          'success': true,
          'data': {
            'profile': profiles[0],
            'paciente': pacientes.isNotEmpty ? pacientes[0] : null,
          },
          'message': 'Dados do paciente obtidos com sucesso',
        };
      }

      return {
        'success': false,
        'message': 'Paciente não encontrado',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao obter dados do paciente: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Verificar se está autenticado
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// Obter usuário atual
  User? get currentUser => _apiService.currentUser;
}
