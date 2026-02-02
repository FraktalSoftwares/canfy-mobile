import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de chat para comunicação entre médico e paciente.
/// Usa Supabase Realtime para atualização em tempo real.
class ChatService {
  final _supabase = Supabase.instance.client;

  /// Stream de mensagens novas para uma consulta (realtime)
  Stream<List<Map<String, dynamic>>> messagesStream(String consultaId) {
    return _supabase
        .from('chat_mensagens')
        .stream(primaryKey: ['id'])
        .eq('consulta_id', consultaId)
        .order('created_at', ascending: true)
        .map((data) => data.map((e) => Map<String, dynamic>.from(e)).toList());
  }

  /// Buscar todas as mensagens de uma consulta
  Future<Map<String, dynamic>> getMessages(String consultaId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
          'data': null,
        };
      }

      final response = await _supabase
          .from('chat_mensagens')
          .select()
          .eq('consulta_id', consultaId)
          .order('created_at', ascending: true);

      final messages = (response as List).map((msg) {
        return {
          'id': msg['id'],
          'consultaId': msg['consulta_id'],
          'senderType': msg['remetente_tipo'],
          'senderId': msg['remetente_id'],
          'text': msg['mensagem'],
          'read': msg['lida'] == true,
          'createdAt': msg['created_at'],
          'time': _formatTime(msg['created_at']),
        };
      }).toList();

      return {
        'success': true,
        'data': messages,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar mensagens: ${e.toString()}',
        'data': null,
      };
    }
  }

  /// Enviar uma mensagem
  Future<Map<String, dynamic>> sendMessage({
    required String consultaId,
    required String mensagem,
    required String remetenteTipo, // 'paciente' ou 'medico'
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
        };
      }

      final response = await _supabase
          .from('chat_mensagens')
          .insert({
            'consulta_id': consultaId,
            'remetente_tipo': remetenteTipo,
            'remetente_id': user.id,
            'mensagem': mensagem,
            'lida': false,
          })
          .select()
          .single();

      return {
        'success': true,
        'data': {
          'id': response['id'],
          'consultaId': response['consulta_id'],
          'senderType': response['remetente_tipo'],
          'senderId': response['remetente_id'],
          'text': response['mensagem'],
          'read': response['lida'] == true,
          'createdAt': response['created_at'],
          'time': _formatTime(response['created_at']),
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao enviar mensagem: ${e.toString()}',
      };
    }
  }

  /// Marcar mensagens como lidas
  Future<Map<String, dynamic>> markAsRead(String consultaId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'Usuário não autenticado',
        };
      }

      // Marcar como lidas todas as mensagens que NÃO foram enviadas pelo usuário atual
      await _supabase
          .from('chat_mensagens')
          .update({'lida': true})
          .eq('consulta_id', consultaId)
          .neq('remetente_id', user.id)
          .eq('lida', false);

      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao marcar como lidas: ${e.toString()}',
      };
    }
  }

  /// Formatar hora a partir de timestamp
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '--:--';
    try {
      DateTime dt;
      if (timestamp is String) {
        dt = DateTime.parse(timestamp).toLocal();
      } else if (timestamp is DateTime) {
        dt = timestamp.toLocal();
      } else {
        return '--:--';
      }
      return '${dt.hour.toString().padLeft(2, '0')}h${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  /// Verificar se o usuário é participante de uma consulta
  Future<Map<String, dynamic>> checkParticipant(String consultaId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'isParticipant': false,
          'role': null,
        };
      }

      // Verificar se é paciente
      final pacienteCheck = await _supabase
          .from('consultas')
          .select('id, pacientes!inner(user_id)')
          .eq('id', consultaId)
          .eq('pacientes.user_id', user.id)
          .maybeSingle();

      if (pacienteCheck != null) {
        return {
          'success': true,
          'isParticipant': true,
          'role': 'paciente',
        };
      }

      // Verificar se é médico
      final medicoCheck = await _supabase
          .from('consultas')
          .select('id, medicos!inner(user_id)')
          .eq('id', consultaId)
          .eq('medicos.user_id', user.id)
          .maybeSingle();

      if (medicoCheck != null) {
        return {
          'success': true,
          'isParticipant': true,
          'role': 'medico',
        };
      }

      return {
        'success': true,
        'isParticipant': false,
        'role': null,
      };
    } catch (e) {
      return {
        'success': false,
        'isParticipant': false,
        'role': null,
        'error': e.toString(),
      };
    }
  }
}
