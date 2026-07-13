import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de notificações in-app (inbox + contagem de não lidas).
class NotificacoesService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getNotificacoes({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('notificacoes')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return {
        'success': true,
        'data': (response as List).cast<Map<String, dynamic>>(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar notificações: ${e.toString()}',
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase
          .from('notificacoes')
          .select('id')
          .eq('lida', false);
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    try {
      await _supabase.from('notificacoes').update({
        'lida': true,
        'lida_em': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', id);
      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao marcar como lida: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    try {
      await _supabase.from('notificacoes').update({
        'lida': true,
        'lida_em': DateTime.now().toUtc().toIso8601String(),
      }).eq('lida', false);
      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao marcar todas como lidas: ${e.toString()}',
      };
    }
  }
}
