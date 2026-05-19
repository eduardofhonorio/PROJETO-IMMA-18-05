import 'package:flutter/material.dart'; // Necessário para o ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart'; // Necessário para o FirebaseAuth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto02/features/auth/model/pedido_model.dart';
import 'package:projeto02/features/auth/model/produto_model.dart'; // Necessário para o Firestore


class PedidoViewModel extends ChangeNotifier {
  // Lista temporária que armazena os itens do pedido atual (Imagem fazendopedido.PNG)
  List<ItemPedidoModel> carrinho = [];
  
  // Identificador do vendedor logado para garantir a SEGREGACÃO DE DADOS
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // --- 1. LÓGICA DE LISTAGEM E FILTRAGEM (Referência: pedidos.png) ---

  // Retorna um stream do Firestore filtrado pelo vendedor atual (Privacidade)
  Stream<QuerySnapshot> getPedidosStream(String filtro) {
    Query query = FirebaseFirestore.instance
        .collection('pedidos')
        .where('vendedorId', isEqualTo: userId); // Garante que e-mails diferentes vejam dados diferentes

    // Implementação dos filtros de data solicitados
    if (filtro == "Hoje") {
      DateTime hoje = DateTime.now();
      DateTime inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
      query = query.where('dataCriacao', isGreaterThanOrEqualTo: inicioDia);
    } else if (filtro == "Ontem") {
      DateTime ontem = DateTime.now().subtract(const Duration(days: 1));
      DateTime inicioOntem = DateTime(ontem.year, ontem.month, ontem.day);
      DateTime fimOntem = DateTime(ontem.year, ontem.month, ontem.day, 23, 59, 59);
      query = query.where('dataCriacao', isGreaterThanOrEqualTo: inicioOntem)
                   .where('dataCriacao', isLessThanOrEqualTo: fimOntem);
    }

    return query.snapshots();
  }

  // --- 2. GESTÃO DO CARRINHO (Referência: fazendopedido.PNG) ---

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

  // --- 4. SALVAMENTO NO BANCO DE DADOS ---
  
  Future<void> finalizarPedido(String clienteNome, String pagamento) async {
    if (pagamento.isEmpty) {
      throw "A forma de pagamento (À Vista, 7, 14, 21 ou 28 dias) é obrigatória.";
    }

    if (carrinho.isEmpty) {
      throw "Adicione pelo menos um produto para confirmar o orçamento.";
    }

    try {
      await FirebaseFirestore.instance.collection('pedidos').add({
        'vendedorId': userId, 
        'clienteNome': clienteNome,
        'itens': carrinho.map((i) => i.toMap()).toList(),
        'total': calcularTotal(),
        'formaPagamento': pagamento,
        'dataCriacao': FieldValue.serverTimestamp(), 
      });
      

      carrinho.clear();
      notifyListeners();
    } catch (e) {
      throw "Erro ao salvar pedido: $e";
    }
  }
}