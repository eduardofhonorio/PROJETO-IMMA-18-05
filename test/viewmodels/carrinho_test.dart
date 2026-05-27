// test/viewmodels/carrinho_test.dart
//
// Testes de unidade para o motor do carrinho e o limite de prazo.
// Cobre: PedidoViewModel (calcularTotal, prazoPagamentoValidator,
//        adicionarProduto, atualizarQuantidade, removerDoCarrinho).
// Técnicas aplicadas (ISO/IEC/IEEE 29119):
//   - Análise de Valor Limite (prazo máximo 30 dias)
//   - Teste Baseado em Cenário (fluxo completo do carrinho)
//
// Execução: flutter test test/viewmodels/carrinho_test.dart
//
// ATENÇÃO: requer que PedidoViewModel.userId seja um getter
//   (e não uma final field), para que a instância possa ser criada
//   sem Firebase inicializado. A correção já foi aplicada.

import 'package:flutter_test/flutter_test.dart';
import 'package:projeto02/features/auth/viewmodel/pedido_viewmodel.dart';
import 'package:projeto02/features/auth/model/produto_model.dart';

void main() {
  // ============================================================
  // PedidoViewModel — prazoPagamentoValidator
  // ============================================================
  group('PedidoViewModel — prazoPagamentoValidator', () {
    late PedidoViewModel sut;

    setUp(() => sut = PedidoViewModel());

    test('null retorna erro', () {
      expect(sut.prazoPagamentoValidator(null), isNotNull);
    });

    test('string vazia retorna erro', () {
      expect(sut.prazoPagamentoValidator(''), isNotNull);
    });

    test('texto não numérico retorna erro', () {
      expect(sut.prazoPagamentoValidator('abc'), isNotNull);
    });

    test('zero retorna erro (valor inválido)', () {
      expect(sut.prazoPagamentoValidator('0'), isNotNull);
    });

    test('negativo retorna erro', () {
      expect(sut.prazoPagamentoValidator('-1'), isNotNull);
    });

    test('1 dia retorna null (valor limite mínimo válido)', () {
      expect(sut.prazoPagamentoValidator('1'), isNull);
    });

    test('30 dias retorna null (valor limite máximo válido)', () {
      expect(sut.prazoPagamentoValidator('30'), isNull);
    });

    test('31 dias retorna erro (acima do limite — valor limite: acima)', () {
      expect(sut.prazoPagamentoValidator('31'), isNotNull);
    });

    test('15 dias retorna null (valor de partição válida intermediária)', () {
      expect(sut.prazoPagamentoValidator('15'), isNull);
    });
  });

  // ============================================================
  // PedidoViewModel — calcularTotal
  // ============================================================
  group('PedidoViewModel — calcularTotal', () {
    late PedidoViewModel sut;

    final produtoA =
        ProdutoModel(id: 'p1', nome: 'Produto A', preco: 10.00);
    final produtoB =
        ProdutoModel(id: 'p2', nome: 'Produto B', preco: 25.00);
    final produtoC =
        ProdutoModel(id: 'p3', nome: 'Produto C', preco: 0.99);

    setUp(() => sut = PedidoViewModel());

    test('carrinho vazio retorna 0.0', () {
      expect(sut.calcularTotal(), 0.0);
    });

    test('1 unidade de 1 produto retorna o preço unitário', () {
      sut.adicionarProduto(produtoA);
      expect(sut.calcularTotal(), 10.00);
    });

    test('2 produtos distintos somam corretamente', () {
      sut.adicionarProduto(produtoA); // 10.00
      sut.adicionarProduto(produtoB); // 25.00
      expect(sut.calcularTotal(), 35.00);
    });

    test('aumentar quantidade multiplica o preço', () {
      sut.adicionarProduto(produtoA); // qtd = 1
      sut.atualizarQuantidade(0, true); // qtd = 2
      expect(sut.calcularTotal(), 20.00);
    });

    test('diminuir quantidade abaixo de 1 remove o item', () {
      sut.adicionarProduto(produtoA); // qtd = 1
      sut.atualizarQuantidade(0, false); // qtd tentaria ser 0 → remove
      expect(sut.calcularTotal(), 0.0);
      expect(sut.carrinho.isEmpty, isTrue);
    });

    test('remover item do carrinho recalcula o total', () {
      sut.adicionarProduto(produtoA); // 10.00
      sut.adicionarProduto(produtoB); // 25.00
      sut.removerDoCarrinho(0); // remove Produto A
      expect(sut.calcularTotal(), 25.00);
    });

    test('cenário completo: 3 itens com quantidades variadas', () {
      // A: 2 × 10.00 = 20.00
      sut.adicionarProduto(produtoA);
      sut.atualizarQuantidade(0, true);

      // B: 1 × 25.00 = 25.00
      sut.adicionarProduto(produtoB);

      // C: 3 × 0.99 = 2.97
      sut.adicionarProduto(produtoC);
      sut.atualizarQuantidade(2, true); // qtd = 2
      sut.atualizarQuantidade(2, true); // qtd = 3

      // Total: 20.00 + 25.00 + 2.97 = 47.97
      expect(sut.calcularTotal(), closeTo(47.97, 0.001));
    });

    test('produto com preço de centavos acumula sem erro de arredondamento',
        () {
      sut.adicionarProduto(produtoC); // 0.99
      sut.atualizarQuantidade(0, true); // 0.99 × 2 = 1.98
      expect(sut.calcularTotal(), closeTo(1.98, 0.001));
    });
  });

  // ============================================================
  // PedidoViewModel — selecionarPagamento
  // ============================================================
  group('PedidoViewModel — selecionarPagamento', () {
    late PedidoViewModel sut;

    setUp(() => sut = PedidoViewModel());

    test('forma padrão inicial é À Vista', () {
      expect(sut.formaPagamentoSelecionada, 'À Vista');
    });

    test('selecionar nova forma atualiza o estado', () {
      sut.selecionarPagamento('14 Dias');
      expect(sut.formaPagamentoSelecionada, '14 Dias');
    });

    test('selecionar formas em sequência mantém a última', () {
      sut.selecionarPagamento('7 Dias');
      sut.selecionarPagamento('28 Dias');
      expect(sut.formaPagamentoSelecionada, '28 Dias');
    });
  });
}
