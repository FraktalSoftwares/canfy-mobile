// PAC-04 — Login do paciente → /patient/home
//
// Caso completo em canfy-web/testes-e2e/02-paciente-mobile.md
//
// Pré-condição: existir uma conta de paciente de teste válida no Supabase
// (ver canfy-web/testes-e2e/00-preparacao.md). Credenciais lidas de
// --dart-define para não hardcodar segredos no teste:
//   flutter test integration_test/pac_04_login_test.dart -d chrome \
//     --dart-define=TEST_PATIENT_EMAIL=... \
//     --dart-define=TEST_PATIENT_PASSWORD=...
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'package:canfy_mobile/main.dart' as app;

const _email = String.fromEnvironment('TEST_PATIENT_EMAIL');
const _password = String.fromEnvironment('TEST_PATIENT_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PAC-04: paciente faz login e chega em /patient/home',
      (tester) async {
    expect(_email, isNotEmpty,
        reason: 'Defina --dart-define=TEST_PATIENT_EMAIL');
    expect(_password, isNotEmpty,
        reason: 'Defina --dart-define=TEST_PATIENT_PASSWORD');

    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Splash decide o destino; sem sessão, cai em /user-selection.
    // Navega direto para /login via GoRouter do app já montado.
    final ctx = tester.element(find.byType(MaterialApp));
    GoRouter.of(ctx).go('/login');
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final emailField = find.byKey(const ValueKey('pac_login_email'));
    final senhaField = find.byKey(const ValueKey('pac_login_senha'));
    final submitBtn = find.byKey(const ValueKey('pac_login_submit'));

    expect(emailField, findsOneWidget);
    expect(senhaField, findsOneWidget);
    expect(submitBtn, findsOneWidget);

    await tester.enterText(
      find.descendant(of: emailField, matching: find.byType(TextField)),
      _email,
    );
    await tester.enterText(
      find.descendant(of: senhaField, matching: find.byType(TextField)),
      _password,
    );
    await tester.pumpAndSettle();

    await tester.tap(submitBtn);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(GoRouter.of(ctx).routerDelegate.currentConfiguration.uri.path,
        '/patient/home',
        reason: 'Login válido deve redirecionar para /patient/home');
  });
}
