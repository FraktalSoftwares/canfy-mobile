import '../api/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para operações relacionadas a pacientes
class PatientService {
  final ApiService _apiService = ApiService();

  /// Obter dados do paciente atual (profile + dados do paciente)
  Future<Map<String, dynamic>> getCurrentPatient() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
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
        };
      }

      return {
        'success': false,
        'message': 'Perfil não encontrado',
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar dados do paciente: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar pedidos recentes do paciente
  Future<Map<String, dynamic>> getRecentOrders({int limit = 5}) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      // Primeiro, buscar o ID do paciente
      final pacienteResult = await _apiService.getFiltered(
        'pacientes',
        filters: {'user_id': user.id},
        limit: 1,
      );

      if (!pacienteResult['success'] || pacienteResult['data'] == null) {
        return {
          'success': false,
          'message': 'Paciente não encontrado',
          'data': null,
        };
      }

      final pacientes = pacienteResult['data'] as List;
      if (pacientes.isEmpty) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pacienteId = pacientes[0]['id'] as String;

      // Buscar pedidos do paciente
      final pedidosResult = await _apiService.getFiltered(
        'pedidos',
        filters: {'paciente_id': pacienteId},
        limit: limit,
        orderBy: 'data_pedido',
        ascending: false,
      );

      if (!pedidosResult['success'] || pedidosResult['data'] == null) {
        return {
          'success': true,
          'data': [],
        };
      }

      final pedidos = pedidosResult['data'] as List;

      // Para cada pedido, buscar os itens e o primeiro produto
      final pedidosCompletos = <Map<String, dynamic>>[];
      
      for (var pedido in pedidos) {
        final pedidoId = pedido['id'] as String;
        
        // Buscar itens do pedido
        final itensResult = await _apiService.getFiltered(
          'pedido_itens',
          filters: {'pedido_id': pedidoId},
          limit: 1,
        );

        String? productName;
        if (itensResult['success'] && itensResult['data'] != null) {
          final itens = itensResult['data'] as List;
          if (itens.isNotEmpty) {
            final produtoId = itens[0]['produto_id'] as String;
            
            // Buscar dados do produto
            final produtoResult = await _apiService.getFiltered(
              'produtos',
              filters: {'id': produtoId},
              limit: 1,
            );

            if (produtoResult['success'] && produtoResult['data'] != null) {
              final produtos = produtoResult['data'] as List;
              if (produtos.isNotEmpty) {
                productName = produtos[0]['nome_comercial'] as String?;
              }
            }
          }
        }

        pedidosCompletos.add({
          'id': pedidoId,
          'numero_pedido': pedido['numero_pedido'],
          'status': pedido['status'],
          'valor_total': pedido['valor_total'],
          'data_pedido': pedido['data_pedido'],
          'productName': productName ?? 'Produto',
        });
      }

      return {
        'success': true,
        'data': pedidosCompletos,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar pedidos: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }

  /// Buscar consultas do paciente (quando a tabela existir)
  /// Por enquanto, retorna lista vazia
  Future<Map<String, dynamic>> getUpcomingConsultations({int limit = 5}) async {
    try {
      // TODO: Implementar quando houver tabela de consultas
      return {
        'success': true,
        'data': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar consultas: ${e.toString()}',
        'data': null,
        'error': e.toString(),
      };
    }
  }
}
