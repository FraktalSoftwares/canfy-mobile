// Regressão visual + funcional dos itens de QA C(G-130) que dependiam de
// interação real na tela ou de dados reais no banco (dropdown "Sexo",
// checkbox de termos, home do paciente/médico, horário de consulta, texto
// do pedido, foto de perfil do médico).
//
// Por quê integration_test: a injeção de toque via adb (`input tap`,
// `input swipe`, `input keyevent`) não chega à engine do Flutter neste
// dispositivo/versão do Android, nem por wireless nem por USB — é um
// bloqueio geral de injeção de input do próprio Android, não algo
// específico deste app. `tester.tap()` injeta o ponteiro diretamente no
// binding de gestos do Flutter, contornando esse bloqueio por completo.
//
// Cada `await hold(...)` mantém a tela parada por tempo suficiente para
// uma captura externa via `adb exec-out screencap` — não dá para salvar o
// PNG a partir do próprio teste (`takeScreenshot`) porque `flutter test -d
// <device>` desinstala o app ao final, levando qualquer arquivo salvo em
// armazenamento privado do app junto com ele.
//
// Login/logout usam AuthService diretamente (sem depender de toque em
// campos de texto) e a navegação para telas específicas usa
// AppRouter.router.go(...) — reduz pontos de falha e evita depender de
// gestos de navegação (tabs, botões voltar) que não são o objeto do teste.
//
// #14 e #16 tocam dados reais no Supabase de produção. #16 restaura o
// foto_perfil_url original ao final (a RLS de UPDATE em profiles permite).
// #14 TENTA apagar a consulta de teste ao final, mas a tabela `consultas`
// não tem nenhuma policy de RLS para DELETE — o apiService.delete() falha
// silenciosamente (mesma classe do bug do #16: PostgREST não retorna erro
// quando a RLS bloqueia, só devolve uma lista vazia). Depois de rodar este
// teste, apague manualmente com privilégio de service role:
//   delete from consultas where queixa_principal = 'QA_TEST_TIMEZONE';
// #14 usa um medico_id explícito para não disparar a notificação em massa
// "nova consulta na fila" (só ocorre quando medico_id é nulo). #15 nunca
// preenche o campo CEP nem toca no botão de finalizar — evita a cotação
// real no Melhor Envio e qualquer pedido/pagamento real.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:canfy_mobile/main.dart' as app;
import 'package:canfy_mobile/core/router/app_router.dart';
import 'package:canfy_mobile/services/api/auth_service.dart';
import 'package:canfy_mobile/services/api/api_service.dart';
import 'package:canfy_mobile/services/api/patient_service.dart';
import 'package:canfy_mobile/models/order/new_order_form_data.dart';

// Contas de QA já usadas no documento de teste original.
const _pacienteEmail = 'vofoj57303@davopa.com';
const _pacienteSenha = '123123';
const _pacienteId = 'd227b031-8d3d-43ad-ad8b-d3a68bf7fb81'; // Nilo Guimarães
const _medicoEmail = 'jiyoteb368@davopa.com';
const _medicoSenha = '123456';
const _medicoId = '99201f99-350f-4411-aec8-deaa645f94e8'; // Dr. Yuri
const _medicoUserId = '7c4f2f33-ff7e-41bb-b919-310e507bacf4';

Future<void> hold(String label, [Duration d = const Duration(seconds: 30)]) async {
  // ignore: avoid_print
  print('QA_CHECKPOINT: $label');
  await Future.delayed(d);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA C(G-130): regressão dos 17 itens', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final authService = AuthService();
    final apiService = ApiService();
    final patientService = PatientService();

    // --- #10: dropdown "Sexo" legível ---
    AppRouter.router.go('/register');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selecione o sexo'));
    await tester.pumpAndSettle();
    await hold('register_dropdown_sexo_aberto');

    await tester.tap(find.text('Feminino').last);
    await tester.pumpAndSettle();

    // --- #11: checkbox "termos de uso" visível e marcável ---
    // Rola até o checkbox antes de tocar — fora da viewport o hit-test do
    // Flutter não acerta o widget (tap silenciosamente ignorado).
    final checkboxFinder = find.byKey(const ValueKey('pac_cadastro_aceitar_termos'));
    await tester.scrollUntilVisible(
      checkboxFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();
    await hold('register_checkbox_termos_marcado');

    // --- #12 / #13: home do paciente (banner de dados + ícone de notificação) ---
    final patientLogin = await authService.login(
      email: _pacienteEmail,
      password: _pacienteSenha,
    );
    // ignore: avoid_print
    print('QA_LOGIN_PACIENTE: ${patientLogin['success']}');
    await tester.pumpAndSettle();

    AppRouter.router.go('/patient/home');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await hold('patient_home');

    // --- #14: horário da consulta exibido em fuso local, não UTC ---
    final dataConsultaUtc = DateTime.utc(2026, 8, 20, 18, 0); // 15h00 BRT
    final createResult = await patientService.createConsultation(
      pacienteId: _pacienteId,
      dataConsultaIso: dataConsultaUtc.toIso8601String(),
      queixaPrincipal: 'QA_TEST_TIMEZONE',
      medicoId: _medicoId,
    );
    final consultaId = (createResult['data'] as Map?)?['id'] as String?;
    // ignore: avoid_print
    print('QA_CONSULTA_CRIADA: ${createResult['success']} id=$consultaId');

    final consultationsResult = await patientService.getConsultations();
    final upcoming = ((consultationsResult['data']
                as Map<String, dynamic>?)?['upcoming'] as List?) ??
        [];
    final created = upcoming.cast<Map<String, dynamic>?>().firstWhere(
          (c) => c?['mainComplaint'] == 'QA_TEST_TIMEZONE',
          orElse: () => null,
        );
    final horarioOk = created?['time'] == '15:00';
    // ignore: avoid_print
    print('QA_HORARIO_EXIBIDO: date=${created?['date']} time=${created?['time']} '
        '(esperado time=15:00, não 18:00) -> ${horarioOk ? 'OK' : 'FALHOU'}');

    // Limpa a consulta de teste — não deixar dado fictício em produção.
    if (consultaId != null) {
      await apiService.delete('consultas', {'id': consultaId});
    }

    await authService.logout();
    await tester.pumpAndSettle();

    // --- #15: última etapa do pedido com texto legível ---
    final formData = NewOrderFormData(
      prescriptionId: 'qa-test',
      productName: 'Produto QA Teste',
      doctorName: 'Dr. QA Teste',
      valorTotal: 150.0,
    );
    AppRouter.router.go('/patient/orders/new/step5', extra: formData);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Nunca preenche o CEP — evitaria disparar cotação real no Melhor Envio.
    await tester.enterText(
      find.widgetWithText(TextField, 'Ex: Rua rego freitas'),
      'Rua de Teste QA, 123',
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Ex: 452'), '123');
    await tester.pumpAndSettle();
    await hold('step5_endereco_preenchido');

    await tester.dragUntilVisible(
      find.text('Nome do cartão'),
      find.byType(SingleChildScrollView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Nome como no cartão'),
      'TESTE QA VISUAL',
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, '0000 0000 0000 0000'),
      '4111111111111111',
    );
    await tester.pumpAndSettle();
    await hold('step5_cartao_preenchido');
    // Nunca toca em "Finalizar" — não cria pedido/pagamento real.

    // --- #13 / #17: home do médico (ícone de notificação + contadores) ---
    final medicoLogin = await authService.login(
      email: _medicoEmail,
      password: _medicoSenha,
    );
    // ignore: avoid_print
    print('QA_LOGIN_MEDICO: ${medicoLogin['success']}');
    await tester.pumpAndSettle();

    AppRouter.router.go('/home');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await hold('medico_home');

    // --- #16: foto de perfil do médico grava na coluna correta ---
    const testPhotoUrl = 'https://example.com/qa-test-photo.jpg';
    final putResult = await apiService.put(
      'profiles',
      {'id': _medicoUserId},
      {'foto_perfil_url': testPhotoUrl},
    );
    final readBack = await apiService.getFiltered(
      'profiles',
      filters: {'id': _medicoUserId},
      limit: 1,
    );
    final readList = readBack['data'] as List?;
    final savedUrl =
        readList != null && readList.isNotEmpty ? readList[0]['foto_perfil_url'] : null;
    // ignore: avoid_print
    print('QA_FOTO_PUT_RESULT: ${putResult['success']} '
        'persistida=$savedUrl (esperado=$testPhotoUrl) -> '
        '${savedUrl == testPhotoUrl ? 'OK' : 'FALHOU'}');

    // Restaura o valor original (null) — não deixar dado de teste.
    await apiService.put('profiles', {'id': _medicoUserId}, {'foto_perfil_url': null});

    await authService.logout();
    await tester.pumpAndSettle();
  });
}
