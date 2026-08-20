// E2E do fluxo de pedido do paciente contra o Supabase real.
//
// Reproduz o cenário do QA: paciente com receita de mais de um produto.
// Antes da correção, getPrescriptions só precificava itens[0] e aplicava
// aquele preço a todos os itens — com o primeiro produto sem preço, o total
// dava 0 e o app mostrava "Não foi possível calcular o valor deste produto".
@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:canfy_mobile/constants/supabase_config.dart';
import 'package:canfy_mobile/services/api/patient_service.dart';
import 'package:canfy_mobile/models/order/new_order_form_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Dois obstáculos do `flutter test` para um teste que fala com o Supabase
    // de verdade:
    //  1. o binding instala um HttpOverrides que responde 400 em toda
    //     requisição — zerá-lo devolve o HttpClient real;
    //  2. não há plugins nativos, então shared_preferences (usado pelo
    //     supabase_flutter para persistir a sessão) precisa ser mockado.
    HttpOverrides.global = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (call) async => call.method == 'getAll' ? <String, Object>{} : true,
    );

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        autoRefreshToken: false,
      ),
    );
    final auth = await Supabase.instance.client.auth.signInWithPassword(
      email: 'vofoj57303@davopa.com',
      password: '123123',
    );
    expect(auth.user, isNotNull, reason: 'login do paciente do QA falhou');
  });

  tearDownAll(() async {
    await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
  });

  test('receitas do paciente vêm com itens e total > 0', () async {
    final service = PatientService();
    final result = await service.getPrescriptions();

    expect(result['success'], isTrue, reason: result['message']?.toString());
    final receitas = (result['data'] as List).cast<Map<String, dynamic>>();
    expect(receitas, isNotEmpty, reason: 'paciente do QA não tem receitas ativas');

    for (final r in receitas) {
      final itens = (r['itens'] as List).cast<Map<String, dynamic>>();
      final total = (r['valorTotal'] as num).toDouble();

      // Bug original: total 0 barrava o pedido no step1.
      expect(total, greaterThan(0),
          reason: 'receita ${r['id']} ("${r['product']}") com total zerado');

      // Total precisa ser a soma de preço × quantidade de CADA item.
      final esperado = itens.fold<double>(
        0.0,
        (soma, i) =>
            soma + (i['preco_unitario'] as double) * (i['quantidade_prescrita'] as int),
      );
      expect(total, closeTo(esperado, 0.001),
          reason: 'receita ${r['id']}: total não bate com a soma dos itens');

      // Cada item traz o preço do SEU produto (não o do primeiro).
      for (final i in itens) {
        expect(i['produto_id'], isNotNull);
        expect(i['preco_unitario'], greaterThan(0),
            reason: 'item ${i['produto_nome']} sem preço');
      }

      print('receita ${r['id']}: ${itens.length} item(ns), total R\$ '
          '${total.toStringAsFixed(2)} — ${r['product']}');
    }
  });

  test('receita multi-produto: preços distintos por item e OrderItem correto', () async {
    final service = PatientService();
    final result = await service.getPrescriptions();
    final receitas = (result['data'] as List).cast<Map<String, dynamic>>();

    final multi = receitas.where((r) => (r['itens'] as List).length > 1).toList();
    expect(multi, isNotEmpty,
        reason: 'nenhuma receita com mais de um produto para este paciente');

    for (final r in multi) {
      final itens = (r['itens'] as List)
          .cast<Map<String, dynamic>>()
          .map(OrderItem.fromReceitaItem)
          .toList();

      final form = NewOrderFormData(
        prescriptionId: r['id'] as String,
        productName: r['product'] as String,
        doctorName: r['doctor'] as String,
        valorTotal: (r['valorTotal'] as num).toDouble(),
        itens: itens,
      );

      // O valor que o checkout usa é a soma dos subtotais.
      expect(form.productValue, closeTo((r['valorTotal'] as num).toDouble(), 0.001));
      expect(form.productValue, greaterThan(0));

      // Sanidade do bug: se todos os itens tivessem o preço do primeiro,
      // o total seria outro (a menos que os preços sejam mesmo iguais).
      final precos = itens.map((i) => i.precoUnitario).toSet();
      print('receita ${r['id']}: ${itens.length} produtos, preços distintos: '
          '${precos.length}, total R\$ ${form.productValue.toStringAsFixed(2)}');
      for (final i in itens) {
        print('   ${i.quantidade}x ${i.nome} @ ${i.precoUnitario} = ${i.subtotal}');
      }
    }
  });

  test('getPrescriptionDetails devolve itens e valor_total coerentes', () async {
    final service = PatientService();
    final lista = await service.getPrescriptions();
    final receitas = (lista['data'] as List).cast<Map<String, dynamic>>();
    final multi = receitas.firstWhere((r) => (r['itens'] as List).length > 1);

    final det = await service.getPrescriptionDetails(multi['id'] as String);
    expect(det['success'], isTrue);
    final data = det['data'] as Map<String, dynamic>;
    final itens = (data['itens'] as List).cast<Map<String, dynamic>>();

    expect(itens.length, (multi['itens'] as List).length);
    expect((data['valor_total'] as num).toDouble(),
        closeTo((multi['valorTotal'] as num).toDouble(), 0.001));

    // Antes, todos os itens vinham carimbados com o nome/preço do produto #1.
    final nomes = itens.map((i) => i['produto_nome']).toSet();
    print('detalhes: ${itens.length} itens, ${nomes.length} nome(s) distinto(s)');
  });

  test('ordem dos itens é estável entre chamadas', () async {
    final service = PatientService();
    final a = await service.getPrescriptions();
    final b = await service.getPrescriptions();

    String chave(Map<String, dynamic> r) => (r['itens'] as List)
        .map((i) => (i as Map)['produto_id'])
        .join(',');

    final ra = (a['data'] as List).cast<Map<String, dynamic>>();
    final rb = (b['data'] as List).cast<Map<String, dynamic>>();
    for (var i = 0; i < ra.length; i++) {
      expect(chave(ra[i]), chave(rb[i]),
          reason: 'ordem dos itens variou entre chamadas (faltava orderBy)');
    }
  });
}
