import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/order/new_order_form_data.dart';

/// Rascunho do pedido guardado enquanto o paciente assina a procuração no
/// navegador externo.
///
/// Sem isso, se o Android encerrar o app durante a assinatura, o pedido em
/// montagem (que só existe em memória) se perderia e o paciente teria que
/// recomeçar.
class ProcuracaoDraftStorage {
  static const String _chave = 'procuracao_draft';

  /// Guarda o pedido em montagem e o envelope que está sendo assinado.
  static Future<void> salvar({
    NewOrderFormData? formData,
    required String envelopeId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode({
        'envelopeId': envelopeId,
        'formData': formData?.toJson(),
      }),
    );
  }

  /// Lê o rascunho guardado. Devolve `null` se não houver nada pendente ou se
  /// o conteúdo estiver corrompido (versão antiga do app, por exemplo).
  static Future<({String envelopeId, NewOrderFormData? formData})?> ler() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return null;
    try {
      final json = jsonDecode(bruto) as Map<String, dynamic>;
      final envelopeId = json['envelopeId'] as String?;
      if (envelopeId == null) return null;
      final formJson = json['formData'] as Map<String, dynamic>?;
      return (
        envelopeId: envelopeId,
        formData: formJson == null ? null : NewOrderFormData.fromJson(formJson),
      );
    } catch (_) {
      await limpar();
      return null;
    }
  }

  static Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
