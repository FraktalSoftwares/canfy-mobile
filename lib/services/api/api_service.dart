/// Serviço base para chamadas de API
/// TODO: Implementar quando o backend estiver disponível
class ApiService {
  // Base URL da API
  static const String baseUrl = 'https://api.canfy.com/v1';

  // Headers padrão
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Métodos HTTP
  Future<Map<String, dynamic>> get(String endpoint) async {
    // TODO: Implementar GET request
    throw UnimplementedError('GET request not implemented yet');
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // TODO: Implementar POST request
    throw UnimplementedError('POST request not implemented yet');
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    // TODO: Implementar PUT request
    throw UnimplementedError('PUT request not implemented yet');
  }

  Future<void> delete(String endpoint) async {
    // TODO: Implementar DELETE request
    throw UnimplementedError('DELETE request not implemented yet');
  }
}





