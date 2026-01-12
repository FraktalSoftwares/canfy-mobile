import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço base para chamadas de API usando Supabase
/// 
/// IMPORTANTE: Este projeto usa o MCP do Supabase (supabase-canfy)
/// para operações de backend. Sempre prefira usar o MCP quando possível.
/// 
/// Este serviço usa o cliente Supabase Flutter para operações que precisam
/// ser feitas diretamente no app (como queries em tempo real, subscriptions, etc).
class ApiService {
  /// Cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Métodos HTTP usando Supabase REST API
  
  /// GET request
  /// 
  /// Exemplo:
  /// ```dart
  /// final data = await ApiService.get('users');
  /// ```
  Future<Map<String, dynamic>> get(String table) async {
    try {
      final response = await client
          .from(table)
          .select()
          .limit(1000);
      
      return {
        'success': true,
        'data': response,
        'message': 'Dados obtidos com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao obter dados: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// GET request com filtros
  /// 
  /// Exemplo:
  /// ```dart
  /// final data = await ApiService.getFiltered(
  ///   'users',
  ///   filters: {'status': 'active'},
  /// );
  /// ```
  Future<Map<String, dynamic>> getFiltered(
    String table, {
    Map<String, dynamic>? filters,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = client.from(table).select();
      
      if (filters != null) {
        filters.forEach((key, value) {
          query = (query as dynamic).eq(key, value);
        });
      }
      
      if (orderBy != null) {
        query = (query as dynamic).order(orderBy, ascending: ascending);
      }
      
      if (limit != null) {
        query = (query as dynamic).limit(limit);
      }
      
      final response = await query;
      
      return {
        'success': true,
        'data': response,
        'message': 'Dados obtidos com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao obter dados: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// POST request - Inserir dados
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await ApiService.post(
  ///   'users',
  ///   {'name': 'João', 'email': 'joao@example.com'},
  /// );
  /// ```
  Future<Map<String, dynamic>> post(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(table)
          .insert(data);
      
      return {
        'success': true,
        'data': response,
        'message': 'Dados inseridos com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao inserir dados: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// PUT request - Atualizar dados
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await ApiService.put(
  ///   'users',
  ///   {'id': '123'},
  ///   {'name': 'João Silva'},
  /// );
  /// ```
  Future<Map<String, dynamic>> put(
    String table,
    Map<String, dynamic> filters,
    Map<String, dynamic> data,
  ) async {
    try {
      var query = client.from(table).update(data);
      
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      final response = await query;
      
      return {
        'success': true,
        'data': response,
        'message': 'Dados atualizados com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao atualizar dados: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// DELETE request
  /// 
  /// Exemplo:
  /// ```dart
  /// await ApiService.delete('users', {'id': '123'});
  /// ```
  Future<Map<String, dynamic>> delete(
    String table,
    Map<String, dynamic> filters,
  ) async {
    try {
      var query = client.from(table).delete();
      
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
      
      final response = await query;
      
      return {
        'success': true,
        'data': response,
        'message': 'Dados removidos com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao remover dados: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Autenticação - Sign Up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      
      return {
        'success': true,
        'data': {
          'user': response.user?.toJson() ?? {},
          'session': response.session?.toJson() ?? {},
        },
        'message': 'Usuário criado com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao criar usuário: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Autenticação - Sign In
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'data': {
          'user': response.user?.toJson() ?? {},
          'session': response.session?.toJson() ?? {},
        },
        'message': 'Login realizado com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao fazer login: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Autenticação - Sign Out
  Future<Map<String, dynamic>> signOut() async {
    try {
      await client.auth.signOut();
      
      return {
        'success': true,
        'data': null,
        'message': 'Logout realizado com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao fazer logout: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Obter usuário atual
  User? get currentUser => client.auth.currentUser;

  /// Verificar se está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Reset de senha - Enviar email de recuperação
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await ApiService.resetPasswordForEmail('user@example.com');
  /// ```
  Future<Map<String, dynamic>> resetPasswordForEmail(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'canfy://reset-password', // Deep link para o app
      );
      
      return {
        'success': true,
        'data': null,
        'message': 'Email de recuperação enviado com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao enviar email de recuperação: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Atualizar senha do usuário autenticado
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await ApiService.updatePassword('novaSenha123');
  /// ```
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return {
        'success': true,
        'data': null,
        'message': 'Senha atualizada com sucesso',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao atualizar senha: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Verificar e processar token de reset de senha da URL
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await ApiService.verifyResetToken(url);
  /// ```
  Future<Map<String, dynamic>> verifyResetToken(String url) async {
    try {
      // O Supabase processa automaticamente o token da URL
      // Este método pode ser usado para verificar se há um token válido
      final uri = Uri.parse(url);
      final accessToken = uri.queryParameters['access_token'];
      final type = uri.queryParameters['type'];
      
      if (accessToken != null && type == 'recovery') {
        // Token de recuperação encontrado na URL
        return {
          'success': true,
          'data': {'access_token': accessToken},
          'message': 'Token de recuperação válido',
        };
      }
      
      return {
        'success': false,
        'data': null,
        'message': 'Token de recuperação não encontrado na URL',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao verificar token: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Deletar conta do usuário do auth.users usando Edge Function
  /// 
  /// Exemplo:
  /// ```dart
  /// final result = await ApiService.deleteUserAccount();
  /// ```
  Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      // Obter o token de acesso atual
      final session = client.auth.currentSession;
      if (session == null) {
        return {
          'success': false,
          'data': null,
          'message': 'Usuário não autenticado',
        };
      }
      
      // Chamar a Edge Function
      final response = await client.functions.invoke(
        'delete-user-account',
        body: {},
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>?;
        return {
          'success': true,
          'data': data,
          'message': data?['message'] ?? 'Conta deletada com sucesso',
        };
      } else {
        final error = response.data as Map<String, dynamic>?;
        return {
          'success': false,
          'data': null,
          'message': error?['error'] ?? 'Erro ao deletar conta do usuário',
          'error': error?.toString() ?? response.status.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao deletar conta do usuário: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }
}
