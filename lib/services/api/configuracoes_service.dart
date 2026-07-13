import 'api_service.dart';

class ConfiguracoesService {
  Future<Map<String, dynamic>> getValorConsultaPadrao() async {
    try {
      final result = await ApiService.client
          .rpc('get_valor_consulta_padrao') as num?;
      if (result == null) {
        return {
          'success': false,
          'message': 'Valor da consulta não configurado',
          'data': null,
        };
      }
      return {
        'success': true,
        'message': 'Valor obtido com sucesso',
        'data': result.toDouble(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao obter valor da consulta: ${e.toString()}',
        'data': null,
      };
    }
  }
}
