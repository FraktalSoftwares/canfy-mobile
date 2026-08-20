import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de integração DocuSign via Supabase Edge Functions.
///
/// A criação do envelope e a assinatura ocorrem no backend (Edge Function
/// `docusign-signing-url`) para manter as credenciais JWT seguras. Configure
/// DOCUSIGN_INTEGRATION_KEY, DOCUSIGN_USER_ID, DOCUSIGN_ACCOUNT_ID e
/// DOCUSIGN_PRIVATE_KEY nos secrets do projeto.
class DocusignService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Cria um envelope de assinatura da procuração e retorna a URL de assinatura.
  ///
  /// [procuracao] são os dados preenchidos pelo paciente (nome, cpf, endereço...),
  /// usados pelo backend para gerar o PDF da procuração.
  Future<Map<String, dynamic>> getSigningUrl({
    String? returnUrl,
    Map<String, String>? procuracao,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'docusign-signing-url',
        body: {
          if (returnUrl != null && returnUrl.isNotEmpty)
            'returnUrl': returnUrl,
          if (procuracao != null && procuracao.isNotEmpty)
            'procuracao': procuracao,
        },
      );

      if (res.status != 200) {
        final err = res.data is Map ? (res.data as Map)['error'] : res.data;
        final hint = res.data is Map ? (res.data as Map)['hint'] : null;
        return {
          'success': false,
          'data': null,
          'message': err?.toString() ?? 'Erro ao gerar link de assinatura',
          'notConfigured': res.status == 503,
          'error': hint ?? res.data,
        };
      }

      final data = res.data is Map ? res.data as Map<String, dynamic> : null;
      final url = data?['url'] as String?;
      if (url == null) {
        return {
          'success': false,
          'data': null,
          'message': 'Resposta inválida da Edge Function',
          'error': data,
        };
      }

      return {
        'success': true,
        'data': {
          'url': url,
          'envelopeId': data?['envelopeId'] as String?,
        },
        'message': 'Link de assinatura gerado',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao gerar link de assinatura: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  /// Consulta o status atual de um envelope.
  ///
  /// Lê direto de `docusign_envelopes` (RLS libera apenas as linhas do próprio
  /// usuário). O status é atualizado pelo webhook `docusign-webhook`; enquanto o
  /// DocuSign não notificar, permanece `sent`.
  Future<Map<String, dynamic>> getEnvelopeStatus(String envelopeId) async {
    try {
      final row = await _client
          .from('docusign_envelopes')
          .select('status, completed_at')
          .eq('envelope_id', envelopeId)
          .maybeSingle();

      if (row == null) {
        return {
          'success': false,
          'data': null,
          'message': 'Envelope não encontrado',
        };
      }

      final status = row['status'] as String?;
      return {
        'success': true,
        'data': {
          'status': status,
          'completed': status == 'completed',
          'completedAt': row['completed_at'] as String?,
        },
        'message': 'Status consultado',
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao consultar assinatura: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }
}
