import 'package:supabase_flutter/supabase_flutter.dart';

/// Cotação Melhor Envio via Edge Function.
class MelhorEnvioService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Cota frete para um destino + lista de itens.
  /// Retorna {success, data: [{id, name, price, delivery_time, company}]} ou {success: false, message}.
  Future<Map<String, dynamic>> cotar({
    required String cepDestino,
    required List<Map<String, dynamic>> itens,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'melhor-envio-cotar',
        body: {
          'cep_destino': cepDestino,
          'itens': itens,
        },
      );

      if (res.status != 200) {
        final err = res.data is Map ? (res.data as Map)['error'] : res.data;
        return {
          'success': false,
          'data': null,
          'message': err?.toString() ?? 'Erro ao cotar frete',
        };
      }

      final data = res.data is Map ? res.data as Map<String, dynamic> : null;
      final servicos = data?['servicos'] as List<dynamic>?;
      if (servicos == null) {
        return {
          'success': false,
          'data': null,
          'message': 'Resposta inválida',
        };
      }

      return {
        'success': true,
        'data': servicos.cast<Map<String, dynamic>>(),
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro: ${e.toString()}',
      };
    }
  }
}
