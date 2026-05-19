import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto02/app/data/service/ai_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AiService _aiService = AiService();
  
  bool isLoadingRecomendacao = false;
  String recomendacaoIA = '';

  // Função disparada quando o vendedor clica no botão "Gerar recomendações"
  Future<void> gerarRecomendacao() async {
    isLoadingRecomendacao = true;
    notifyListeners(); // Atualiza a tela para mostrar o "carregando"

    try {
      final String? vendedorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendedorId == null) throw Exception('Vendedor não logado');

      // 1. Busca os pedidos dos ÚLTIMOS 7 DIAS deste vendedor
      final dataLimite = DateTime.now().subtract(const Duration(days: 7));
      final pedidosSnapshot = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('vendedorId', isEqualTo: vendedorId)
          .where('criadoEm', isGreaterThanOrEqualTo: dataLimite)
          .get();

      // 2. Busca todos os produtos do estoque para descobrir qual NÃO vendeu
      final produtosSnapshot = await FirebaseFirestore.instance.collection('produtos').get();
      final todosProdutos = produtosSnapshot.docs.map((doc) => doc.data()['nome'] as String).toList();

      // 3. Matemática rápida: Agrupando as vendas
      double totalVendido = 0;
      Map<String, int> vendasPorProduto = {};
      Map<String, double> vendasPorCliente = {};

      for (var doc in pedidosSnapshot.docs) {
        final pedido = doc.data();
        totalVendido += (pedido['total'] ?? 0).toDouble();
        
        String cliente = pedido['clienteNome'] ?? 'Desconhecido';
        vendasPorCliente[cliente] = (vendasPorCliente[cliente] ?? 0) + (pedido['total'] ?? 0).toDouble();

        List itens = pedido['itens'] ?? [];
        for (var item in itens) {
          String nomeProduto = item['nome'] ?? 'Produto';
          int qtd = item['quantidade'] ?? 0;
          vendasPorProduto[nomeProduto] = (vendasPorProduto[nomeProduto] ?? 0) + qtd;
        }
      }

      // Descobre o Cliente Destaque
      String clienteDestaque = 'Nenhum';
      if (vendasPorCliente.isNotEmpty) {
        var entry = vendasPorCliente.entries.reduce((a, b) => a.value > b.value ? a : b);
        clienteDestaque = entry.key;
      }

      // Descobre o Produto Campeão
      String produtoCampeao = 'Nenhum';
      if (vendasPorProduto.isNotEmpty) {
        var entry = vendasPorProduto.entries.reduce((a, b) => a.value > b.value ? a : b);
        produtoCampeao = entry.key;
      }

      // Descobre o Produto Encalhado (procura algum que está no estoque mas não apareceu nas vendas)
      String produtoEncalhado = 'Nenhum identificado';
      for (var p in todosProdutos) {
        if (!vendasPorProduto.containsKey(p)) {
          produtoEncalhado = p; // Achou um que vendeu zero
          break;
        }
      }
      
      // Se por acaso ele vendeu TODOS os produtos do catálogo, pega o que vendeu menos
      if (produtoEncalhado == 'Nenhum identificado' && vendasPorProduto.isNotEmpty) {
         var entry = vendasPorProduto.entries.reduce((a, b) => a.value < b.value ? a : b);
         produtoEncalhado = entry.key;
      }

      // 4. Monta o super Resumo para a IA
      String resumoParaIA = '''
      Total vendido na semana: R\$ ${totalVendido.toStringAsFixed(2)}
      Cliente que mais comprou: $clienteDestaque
      Produto mais vendido: $produtoCampeao
      Produto encalhado (sem saída/menos vendido): $produtoEncalhado
      ''';

      // 5. Envia o resumo para a API do Gemini e salva a resposta
      recomendacaoIA = await _aiService.obterRecomendacao(resumoParaIA);

    } catch (e) {
      recomendacaoIA = 'Não foi possível analisar seus dados no momento. Continue vendendo!';
    } finally {
      isLoadingRecomendacao = false;
      notifyListeners(); // Atualiza a tela removendo o "carregando" e mostrando o texto
    }
  }
}