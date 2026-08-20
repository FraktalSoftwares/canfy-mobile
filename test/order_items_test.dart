// Teste da correção do pedido multi-produto (QA): o total precisa somar
// preço × quantidade de CADA produto da receita, e não aplicar o preço do
// primeiro item a todos.
import 'package:flutter_test/flutter_test.dart';
import 'package:canfy_mobile/models/order/new_order_form_data.dart';

void main() {
  group('OrderItem / NewOrderFormData multi-produto', () {
    test('fromReceitaItem lê nome, preço e quantidade do próprio item', () {
      final item = OrderItem.fromReceitaItem({
        'produto_id': 'p1',
        'produto_nome': 'Óleo Canabidiol 10% (30ml)',
        'preco_unitario': 199.0,
        'quantidade_prescrita': 2,
      });
      expect(item.produtoId, 'p1');
      expect(item.nome, 'Óleo Canabidiol 10% (30ml)');
      expect(item.precoUnitario, 199.0);
      expect(item.quantidade, 2);
      expect(item.subtotal, 398.0);
    });

    test('productValue soma o subtotal de cada produto da receita', () {
      // Receita real do QA: e247302d — 3 produtos distintos.
      final form = NewOrderFormData(
        prescriptionId: 'r1',
        productName: 'Pomada Dermatológica de CBD + 2 outros',
        doctorName: 'Dr Teste',
        valorTotal: 0,
        itens: const [
          OrderItem(produtoId: 'a', nome: 'Pomada Dermatológica de CBD', precoUnitario: 119.0, quantidade: 2),
          OrderItem(produtoId: 'b', nome: 'Óleo Canabidiol 10% (30ml)', precoUnitario: 199.0, quantidade: 2),
          OrderItem(produtoId: 'c', nome: 'Pastilha Mastigável de CBD', precoUnitario: 90.0, quantidade: 3),
        ],
      );
      // 238 + 398 + 270 = 906 — confere com o total calculado no banco.
      expect(form.productValue, 906.0);
      expect(form.totalWithShipping, 906.0);
    });

    test('o bug antigo (preço do 1º item para todos) daria outro valor', () {
      // Comportamento anterior: precoUnitario do item[0] × soma das quantidades.
      const precoDoPrimeiro = 119.0;
      const somaQuantidades = 2 + 2 + 3;
      expect(precoDoPrimeiro * somaQuantidades, isNot(906.0));
    });

    test('primeiro produto sem preço não zera o total dos demais', () {
      final form = NewOrderFormData(
        prescriptionId: 'r2',
        productName: 'X + 1 outro',
        doctorName: 'Dr Teste',
        valorTotal: 0,
        itens: const [
          OrderItem(produtoId: 'a', nome: 'Sem preço', precoUnitario: 0.0, quantidade: 1),
          OrderItem(produtoId: 'b', nome: 'Com preço', precoUnitario: 69.9, quantidade: 2),
        ],
      );
      // Antes: total 0 -> snackbar "não foi possível calcular o valor".
      expect(form.productValue, closeTo(139.8, 0.001));
      expect(form.productValue > 0, isTrue);
    });

    test('receita de produto único mantém o cálculo antigo', () {
      final form = NewOrderFormData(
        prescriptionId: 'r3',
        productName: 'Ole de Canabidiol',
        doctorName: 'Dr Teste',
        valorTotal: 69.9,
        quantity: 3,
        precoUnitario: 69.9,
      );
      expect(form.productValue, closeTo(209.7, 0.001));
    });

    test('copyWith preserva e substitui a lista de itens', () {
      final form = NewOrderFormData(
        prescriptionId: 'r4',
        productName: 'A',
        doctorName: 'D',
        valorTotal: 0,
        itens: const [OrderItem(produtoId: 'a', nome: 'A', precoUnitario: 10, quantidade: 1)],
      );
      expect(form.copyWith(quantity: 2).itens.length, 1);
      final trocado = form.copyWith(itens: const [
        OrderItem(produtoId: 'b', nome: 'B', precoUnitario: 20, quantidade: 2),
      ]);
      expect(trocado.itens.single.produtoId, 'b');
      expect(trocado.productValue, 40.0);
    });
  });
}
