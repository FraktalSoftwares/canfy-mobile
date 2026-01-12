/// Configuração do Supabase
///
/// IMPORTANTE: Este projeto usa o MCP do Supabase (supabase-canfy)
/// para todas as operações de backend. Sempre use o MCP ao invés de
/// chamadas diretas quando possível.
class SupabaseConfig {
  /// URL do projeto Supabase
  /// Obtida via MCP: supabase-canfy
  static const String supabaseUrl = 'https://agqqxxfrnpuriwrmwdrq.supabase.co';

  /// Chave anônima do Supabase
  ///
  /// ⚠️ CONFIGURE ESTA CHAVE ANTES DE USAR O APP!
  ///
  /// Para obter a chave:
  /// 1. Acesse: https://supabase.com/dashboard/project/agqqxxfrnpuriwrmwdrq/settings/api
  /// 2. Copie a chave "anon public" (não use service_role)
  /// 3. Cole abaixo substituindo 'YOUR_ANON_KEY_HERE'
  ///
  /// A chave é longa e começa com algo como: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFncXF4eGZybnB1cml3cm13ZHJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMDAzNjAsImV4cCI6MjA3NjY3NjM2MH0.uox5JvNblqcQlSD6o-Rv4ZWYiVopVbyE-tnHSVjuVw0';

  /// Inicializa a configuração do Supabase
  /// Retorna true se a configuração está válida
  static bool get isConfigured {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseAnonKey != 'YOUR_ANON_KEY_HERE';
  }
}
