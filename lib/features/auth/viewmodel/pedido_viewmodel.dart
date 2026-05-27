import 'package:flutter/material.dart'; // Necessário para o ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart'; // Necessário para o FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto02/features/auth/model/pedido_model.dart';
import 'package:projeto02/features/auth/model/produto_model.dart'; // Necessário para o Firestore

class PedidoViewModel extends ChangeNotifier {
  // Lista temporária que armazena os itens do pedido atual
  List<ItemPedidoModel> carrinho = [];
  
  // Getter lazy: só acessa o Firebase quando realmente necessário.
  // Isso permite instanciar o ViewModel em testes unitários sem Firebase inicializado.
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // ==========================================
  // NOVO: CONTROLE DE PAGAMENTO (VALES)
  // ==========================================
  // Variável para controlar o botão selecionado (Padrão: À Vista)
  String formaPagamentoSelecionada = 'À Vista';

  // Função chamada ao clicar nos botões de pagamento da tela
  void selecionarPagamento(String pagamento) {
    formaPagamentoSelecionada = pagamento;
    notifyListeners(); // Atualiza a cor do botão na tela para o vendedor
  }

  // --- 1. LÓGICA DE LISTAGEM E FILTRAGEM ---

  // Retorna um stream do Firestore filtrado pelo vendedor atual (Privacidade)
  Stream<QuerySnapshot> getPedidosStream(String filtro) {
    Query query = FirebaseFirestore.instance
        .collection('pedidos')
        .where('vendedorId', isEqualTo: userId); 

    // Implementação dos filtros de data solicitados
    if (filtro == "Hoje") {
      DateTime hoje = DateTime.now();
      DateTime inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
      query = query.where('criadoEm', isGreaterThanOrEqualTo: inicioDia); // Padronizado para criadoEm
    } else if (filtro == "Ontem") {
      DateTime ontem = DateTime.now().subtract(const Duration(days: 1));
      DateTime inicioOntem = DateTime(ontem.year, ontem.month, ontem.day);
      DateTime fimOntem = DateTime(ontem.year, ontem.month, ontem.day, 23, 59, 59);
      query = query.where('criadoEm', isGreaterThanOrEqualTo: inicioOntem) // Padronizado para criadoEm
                   .where('criadoEm', isLessThanOrEqualTo: fimOntem);
    }

    return query.snapshots();
  }

  // --- 2. GESTÃO DO CARRINHO ---

  void adicionarProduto(ProdutoModel produto) {
    // Adiciona o produto ao carrinho com quantidade inicial 1
    carrinho.add(ItemPedidoModel(
      produtoId: produto.id,
      nome: produto.nome,
      preco: produto.preco,
      quantidade: 1,
    ));
    notifyListeners(); // Notifica a View para atualizar o Total e a Lista
  }

  void atualizarQuantidade(int index, bool aumentar) {
    if (aumentar) {
      carrinho[index].quantidade++;
    } else if (carrinho[index].quantidade > 1) {
      carrinho[index].quantidade--;
    }
    notifyListeners(); // Essencial para atualizar o preço total na tela em tempo real
  }

  void removerDoCarrinho(int index) {
    carrinho.removeAt(index);
    notifyListeners();
  }

  double calcularTotal() {
    return carrinho.fold(0.0, (total, item) => total + (item.preco * item.quantidade));
  }

  // ==========================================
  // 3. VALIDADOR DO PRAZO CUSTOMIZADO (Para o Pop-Up)
  // ==========================================
  String? prazoPagamentoValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe os dias';
    }
    
    final int? dias = int.tryParse(value);
    
    if (dias == null || dias <= 0) {
      return 'Valor inválido';
    }
    if (dias > 30) {
      return 'O limite máximo é de 30 dias';
    }
    
    return null; // Passou na validação!
  }

  // ==========================================
  // 4. SALVAMENTO NO BANCO DE DADOS
  // ==========================================
  
  Future<void> finalizarPedido(String clienteNome, String cidade) async {
    if (formaPagamentoSelecionada.isEmpty) {
      throw "A forma de pagamento (À Vista, 7, 14, 21 ou 28 dias) é obrigatória.";
    }

    if (carrinho.isEmpty) {
      throw "Adicione pelo menos um produto para confirmar o orçamento.";
    }

    try {
      await FirebaseFirestore.instance.collection('pedidos').add({
        'vendedorId': userId, 
        'clienteNome': clienteNome,
        'cidade': cidade, // NOVO: Salva a cidade para o Filtro de Vales funcionar
        'itens': carrinho.map((i) => i.toMap()).toList(),
        'total': calcularTotal(),
        'pagamento': formaPagamentoSelecionada, // CHAVE CORRIGIDA para Vales/Comissões
        'criadoEm': FieldValue.serverTimestamp(), // CHAVE CORRIGIDA para Vales/Comissões
      });
      
      // Limpa o carrinho após o sucesso
      carrinho.clear();
      // Volta o botão de pagamento para o padrão
      formaPagamentoSelecionada = 'À Vista'; 
      notifyListeners();
    } catch (e) {
      throw "Erro ao salvar pedido: $e";
    }
  }
}