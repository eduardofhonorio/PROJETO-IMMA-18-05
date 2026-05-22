import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto02/app/data/service/ai_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AiService _aiService = AiService();
  
  bool isLoadingRecomendacao = false;
  String recomendacaoIA = '';

  // ==========================================
  // NOME DO VENDEDOR (Buscado do Firebase)
  // ==========================================
  String nomeVendedor = "Carregando..."; 

  // ==========================================
  // VARIÁVEIS FINANCEIRAS (DADOS REAIS)
  // AQUI ESTÃO AS VARIÁVEIS QUE FALTARAM!
  // ==========================================
  double totalComissoes = 0.0;
  double totalVales = 0.0;
  
  int totalPedidosMes = 0;
  double totalVendidoMes = 0.0;
  double totalVendasPadrao = 0.0;
  double comissaoPadrao = 0.0;
  double totalVendasEspecial = 0.0;
  double comissaoEspecial = 0.0;
  
  bool isLoadingFinanceiro = true;

  HomeViewModel() {
    // Assim que a tela Home for aberta, ele dispara as buscas no Firebase
    _buscarNomeVendedor(); 
    buscarDadosFinanceiros();
  }

  Future<void> _buscarNomeVendedor() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          nomeVendedor = doc.data()!['name'] ?? "Vendedor";
        }
      }
    } catch (e) {
      nomeVendedor = "Vendedor"; // Fallback caso ocorra um erro
      print("Erro ao buscar nome: $e");
    } finally {
      // Notifica a HomePage para trocar o "Carregando..." pelo nome real!
      notifyListeners(); 
    }
  }

  // ==========================================
  // FUNÇÃO DO MOTOR DE COMISSÕES E VALES
  // ==========================================
  Future<void> buscarDadosFinanceiros([DateTime? mesFiltro]) async {
    isLoadingFinanceiro = true;
    notifyListeners(); // Avisa a tela para mostrar o "carregando"

    try {
      final String? vendedorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendedorId == null) return;

      final dataReferencia = mesFiltro ?? DateTime.now();
      final dataInicioMes = DateTime(dataReferencia.year, dataReferencia.month, 1);
      
      // Criamos a data do próximo mês para fazer um limite na busca do Firebase
      final dataProximoMes = DateTime(dataReferencia.year, dataReferencia.month + 1, 1);

      // Busca os pedidos EXATAMENTE dentro do mês escolhido
      final pedidosSnapshot = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('vendedorId', isEqualTo: vendedorId)
          .where('criadoEm', isGreaterThanOrEqualTo: dataInicioMes)
          .where('criadoEm', isLessThan: dataProximoMes)
          .get();

      double comissaoTemp = 0.0;
      double valesTemp = 0.0;
      int pedidosTemp = pedidosSnapshot.docs.length;
      double vendidoTemp = 0.0;
      
      double vendasPadraoTemp = 0.0;
      double comissaoPadraoTemp = 0.0;
      double vendasEspecialTemp = 0.0;
      double comissaoEspecialTemp = 0.0;

      for (var doc in pedidosSnapshot.docs) {
        final pedido = doc.data();
        final totalPedido = (pedido['total'] ?? 0).toDouble();
        final formaPagamento = (pedido['pagamento'] ?? '').toString().toLowerCase();
        
        vendidoTemp += totalPedido;

        if (formaPagamento.contains('dias') || formaPagamento.contains('vale')) {
          valesTemp += totalPedido;
        }

        List itens = pedido['itens'] ?? [];
        for (var item in itens) {
          String nomeItem = (item['nome'] ?? '').toString().toLowerCase();
          double subtotalItem = ((item['quantidade'] ?? 0) * (item['preco'] ?? 0)).toDouble();
          
          if (nomeItem.contains('energético') || 
              nomeItem.contains('energetico') || 
              nomeItem.contains('cerveja') || 
              nomeItem.contains('óleo de soja') || 
              nomeItem.contains('oleo de soja') ||
              nomeItem.contains('refrigerante')) {
            vendasEspecialTemp += subtotalItem;
            comissaoEspecialTemp += subtotalItem * 0.015;
            comissaoTemp += subtotalItem * 0.015; 
          } else {
            vendasPadraoTemp += subtotalItem;
            comissaoPadraoTemp += subtotalItem * 0.025;
            comissaoTemp += subtotalItem * 0.025; 
          }
        }
      }

      totalComissoes = comissaoTemp;
      totalVales = valesTemp;
      totalPedidosMes = pedidosTemp;
      totalVendidoMes = vendidoTemp;
      totalVendasPadrao = vendasPadraoTemp;
      comissaoPadrao = comissaoPadraoTemp;
      totalVendasEspecial = vendasEspecialTemp;
      comissaoEspecial = comissaoEspecialTemp;

    } catch (e) {
      print("Erro ao buscar financeiro: $e");
    } finally {
      isLoadingFinanceiro = false;
      notifyListeners(); // Avisa a tela que os novos dados chegaram!
    }
  }

  // ==========================================
  // FUNÇÃO DE IA PARA GERAR RECOMENDAÇÕES
  // ==========================================
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
      notifyListeners(); // Atualiza a tela removendo o "carregando"
    }
  }
}