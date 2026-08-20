import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../core/router/app_router.dart';
import '../services/storage/procuracao_draft_storage.dart';

/// Sinal emitido quando o DocuSign devolve o paciente ao app.
///
/// A tela de Procuração escuta este sinal para confirmar a assinatura sozinha.
class DocusignRetorno {
  DocusignRetorno._();

  /// Incrementado a cada retorno — o `ValueNotifier` só notifica em mudança.
  static final ValueNotifier<int> sinal = ValueNotifier<int>(0);

  /// Evento informado pelo DocuSign (`signing_complete`, `cancel`, ...).
  static String? ultimoEvento;

  /// Ligado enquanto a tela de Procuração está viva na pilha. Se estiver
  /// ligado, o retorno não navega para lugar nenhum: o paciente reencontra a
  /// tela exatamente como deixou, com o pedido em memória.
  static bool telaViva = false;

  static void notificar(String? evento) {
    ultimoEvento = evento;
    sinal.value = sinal.value + 1;
  }
}

/// Escuta o deep link de retorno do DocuSign
/// (`canfymobile://canfymobile.com/docusign/retorno`).
///
/// O roteamento automático do Flutter está desligado
/// (`flutter_deeplinking_enabled=false`) de propósito: ele trata o link como
/// uma navegação nova e **substitui a pilha inteira**, destruindo a tela de
/// Procuração e o pedido em montagem. Aqui o link só avisa quem precisa saber.
class DocusignDeepLinkService {
  static const String _caminhoRetorno = '/docusign/retorno';

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _assinatura;

  static Future<void> iniciar() async {
    _assinatura ??= _appLinks.uriLinkStream.listen(_tratar);
    // App aberto do zero pelo link (foi encerrado durante a assinatura).
    final inicial = await _appLinks.getInitialLink();
    if (inicial != null) await _tratar(inicial);
  }

  static Future<void> _tratar(Uri uri) async {
    if (uri.path != _caminhoRetorno) {
      // Demais deep links seguem navegando normalmente — com o roteamento
      // automático desligado, é aqui que eles entram no router.
      if (uri.path.isNotEmpty && uri.path != '/') {
        AppRouter.router.go(
          uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path,
        );
      }
      return;
    }
    final evento = uri.queryParameters['event'];
    DocusignRetorno.notificar(evento);

    // Tela viva: ela mesma confirma a assinatura, sem navegação.
    if (DocusignRetorno.telaViva) return;

    // App foi encerrado durante a assinatura — retoma de onde parou.
    final rascunho = await ProcuracaoDraftStorage.ler();
    if (rascunho == null) return;
    AppRouter.router.go(
      '/patient/orders/new/procuracao',
      extra: rascunho.formData,
    );
  }
}
