import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de integração Asaas via Supabase Edge Functions.
///
/// As chamadas ao Asaas são feitas pelo backend (Edge Functions) para
/// manter a API key segura. Configure ASAAS_API_KEY nos secrets do projeto.
class AsaasService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Sincroniza o usuário atual com um cliente no Asaas.
  /// Se já existir vínculo em [asaas_customers], retorna o id existente.
  /// Caso contrário, cria o cliente no Asaas e grava em [asaas_customers].
  ///
  /// [name] obrigatório. [cpfCnpj], [email], [mobilePhone] opcionais.
  Future<Map<String, dynamic>> syncCustomer({
    required String name,
    String? cpfCnpj,
    String? email,
    String? mobilePhone,
  }) async {
    try {
      final res = await _client.functions.invoke(
        'asaas-sync-customer',
        body: {
          'name': name,
          if (cpfCnpj != null && cpfCnpj.isNotEmpty) 'cpfCnpj': cpfCnpj,
          if (email != null && email.isNotEmpty) 'email': email,
          if (mobilePhone != null && mobilePhone.isNotEmpty)
            'mobilePhone': mobilePhone,
        },
      );

      if (res.status != 200) {
        final err = res.data is Map ? (res.data as Map)['error'] : res.data;
        return {
          'success': false,
          'data': null,
          'message': err?.toString() ?? 'Erro ao sincronizar cliente Asaas',
          'error': res.data,
        };
      }

      final data = res.data is Map ? res.data as Map<String, dynamic> : null;
      final asaasCustomerId = data?['asaas_customer_id'] as String?;

      if (asaasCustomerId == null) {
        return {
          'success': false,
          'data': null,
          'message': 'Resposta inválida da Edge Function',
          'error': data,
        };
      }

      return {
        'success': true,
        'data': {'asaas_customer_id': asaasCustomerId},
        'message': 'Cliente sincronizado',
      };
    } catch (e, st) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao sincronizar cliente: ${e.toString()}',
        'error': e.toString(),
        'stackTrace': st.toString(),
      };
    }
  }

  /// Cria uma cobrança no Asaas (boleto, PIX, cartão etc.).
  ///
  /// [value] obrigatório. [billingType] no app: credit_card, debit_card, pix, boleto.
  /// Se [asaas_customer_id] não for passado, a Edge Function usa o cliente já
  /// vinculado ao usuário em [asaas_customers].
  Future<Map<String, dynamic>> createPayment({
    String? asaasCustomerId,
    required double value,
    required String billingType,
    String? dueDate,
    String? description,
    String? referenceType,
    String? referenceId,
  }) async {
    try {
      final body = <String, dynamic>{
        'value': value,
        'billingType': billingType,
        if (dueDate != null && dueDate.isNotEmpty) 'dueDate': dueDate,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (referenceType != null && referenceType.isNotEmpty)
          'reference_type': referenceType,
        if (referenceId != null && referenceId.isNotEmpty)
          'reference_id': referenceId,
      };
      if (asaasCustomerId != null && asaasCustomerId.isNotEmpty) {
        body['asaas_customer_id'] = asaasCustomerId;
      }

      final res = await _client.functions.invoke(
        'asaas-create-payment',
        body: body,
      );

      if (res.status != 200) {
        final err = res.data is Map ? (res.data as Map)['error'] : res.data;
        return {
          'success': false,
          'data': null,
          'message': err?.toString() ?? 'Erro ao criar cobrança',
          'error': res.data,
        };
      }

      final data = res.data is Map ? res.data as Map<String, dynamic> : null;
      return {
        'success': true,
        'data': data,
        'message': 'Cobrança criada',
      };
    } catch (e, st) {
      return {
        'success': false,
        'data': null,
        'message': 'Erro ao criar cobrança: ${e.toString()}',
        'error': e.toString(),
        'stackTrace': st.toString(),
      };
    }
  }
}
