import 'dart:convert';
import 'package:http/http.dart' as http;

/// Serviço para buscar dados de endereço via CEP
/// Usa a API ViaCEP (gratuita e sem autenticação)
class CepService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  /// Busca endereço pelo CEP
  /// Retorna um Map com: cep, logradouro, complemento, bairro, localidade, uf, erro
  Future<Map<String, dynamic>> getAddressByCep(String cep) async {
    try {
      // Remove caracteres não numéricos
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (cleanCep.length != 8) {
        return {
          'success': false,
          'message': 'CEP deve ter 8 dígitos',
        };
      }

      final url = Uri.parse('$_baseUrl/$cleanCep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // ViaCEP retorna erro quando CEP não é encontrado
        if (data.containsKey('erro') && data['erro'] == true) {
          return {
            'success': false,
            'message': 'CEP não encontrado',
          };
        }

        return {
          'success': true,
          'data': {
            'cep': data['cep'] as String? ?? '',
            'logradouro': data['logradouro'] as String? ?? '',
            'complemento': data['complemento'] as String? ?? '',
            'bairro': data['bairro'] as String? ?? '',
            'localidade': data['localidade'] as String? ?? '',
            'uf': data['uf'] as String? ?? '',
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar CEP. Tente novamente.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao buscar CEP: ${e.toString()}',
      };
    }
  }
}
