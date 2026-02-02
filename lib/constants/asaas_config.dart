/// Configuração do Asaas (gateway de pagamento).
///
/// Documentação: https://docs.asaas.com/
/// Sandbox: https://sandbox.asaas.com/
class AsaasConfig {
  /// URL base da API Asaas (sem barra final).
  /// Sandbox: https://api-sandbox.asaas.com/v3
  /// Produção: https://api.asaas.com/v3
  static const String baseUrl = 'https://api-sandbox.asaas.com/v3';

  /// Chave de API do Asaas.
  ///
  /// ⚠️ NÃO COMMITAR A CHAVE REAL!
  /// Obtenha em: Sandbox → Minha conta → Integrações → API Key
  /// Use variável de ambiente (ex.: ASAAS_API_KEY) em produção.
  static const String apiKey = String.fromEnvironment(
    'ASAAS_API_KEY',
    defaultValue:
        '', // Preencher para testes locais ou usar --dart-define=ASAAS_API_KEY=sua_chave
  );

  /// Indica se a integração está configurada para uso.
  static bool get isConfigured => baseUrl.isNotEmpty && apiKey.isNotEmpty;
}
