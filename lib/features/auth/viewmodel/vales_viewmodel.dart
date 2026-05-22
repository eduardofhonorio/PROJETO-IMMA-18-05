import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ValesViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _todosVales = [];
  List<Map<String, dynamic>> valesFiltrados = [];
  bool isLoading = true;

  // Filtros selecionados
  DateTime? dataSelecionada;
  String? cidadeSelecionada;
  String? clienteSelecionado;

  // Listas para preencher os Dropdowns de filtro automaticamente
  List<String> cidadesDisponiveis = [];
  List<String> clientesDisponiveis = [];

  ValesViewModel() {
    buscarVales();
  }

  Future<void> buscarVales() async {
    isLoading = true;
    notifyListeners();

    try {
      final String? vendedorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendedorId == null) return;

      // Busca todos os pedidos do vendedor
      final snapshot = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('vendedorId', isEqualTo: vendedorId)
          .orderBy('criadoEm', descending: true)
          .get();

      List<Map<String, dynamic>> valesTemp = [];
      Set<String> cidadesTemp = {};
      Set<String> clientesTemp = {};

      for (var doc in snapshot.docs) {
        final pedido = doc.data();
        final formaPagamento = (pedido['pagamento'] ?? '').toString().toLowerCase();

        // REGRA DE VALES: Filtra pedidos que possuem prazos (não são à vista)
        if (formaPagamento.contains('dias') || formaPagamento.contains('vale')) {
          valesTemp.add(pedido);
          
          // Coleta cidades e clientes únicos para os filtros
          if (pedido['cidade'] != null && pedido['cidade'].toString().isNotEmpty) {
            cidadesTemp.add(pedido['cidade']);
          }
          if (pedido['clienteNome'] != null && pedido['clienteNome'].toString().isNotEmpty) {
            clientesTemp.add(pedido['clienteNome']);
          }
        }
      }

      _todosVales = valesTemp;
      cidadesDisponiveis = cidadesTemp.toList()..sort();
      clientesDisponiveis = clientesTemp.toList()..sort();
      
      aplicarFiltros(); // Aplica os filtros iniciais (nenhum)
    } catch (e) {
      print("Erro ao buscar vales: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  void aplicarFiltros() {
    valesFiltrados = _todosVales.where((vale) {
      bool passaData = true;
      bool passaCidade = true;
      bool passaCliente = true;

      // 1. Filtro de Data (ignora horas, compara apenas o dia)
      if (dataSelecionada != null && vale['criadoEm'] != null) {
        DateTime dataVale = (vale['criadoEm'] as Timestamp).toDate();
        passaData = dataVale.year == dataSelecionada!.year &&
                    dataVale.month == dataSelecionada!.month &&
                    dataVale.day == dataSelecionada!.day;
      }

      // 2. Filtro de Cidade
      if (cidadeSelecionada != null && cidadeSelecionada!.isNotEmpty) {
        passaCidade = vale['cidade'] == cidadeSelecionada;
      }

      // 3. Filtro de Cliente
      if (clienteSelecionado != null && clienteSelecionado!.isNotEmpty) {
        passaCliente = vale['clienteNome'] == clienteSelecionado;
      }

      return passaData && passaCidade && passaCliente;
    }).toList();

    isLoading = false;
    notifyListeners();
  }

  // Métodos para a UI atualizar os filtros
  void definirFiltroData(DateTime? data) {
    dataSelecionada = data;
    aplicarFiltros();
  }

  void definirFiltroCidade(String? cidade) {
    cidadeSelecionada = cidade;
    aplicarFiltros();
  }

  void definirFiltroCliente(String? cliente) {
    clienteSelecionado = cliente;
    aplicarFiltros();
  }

  void limparFiltros() {
    dataSelecionada = null;
    cidadeSelecionada = null;
    clienteSelecionado = null;
    aplicarFiltros();
  }

  // Calcula o total em dinheiro dos vales filtrados atualmente na tela
  double get totalValesFiltrados {
    return valesFiltrados.fold(0.0, (soma, vale) => soma + (vale['total'] ?? 0).toDouble());
  }
}