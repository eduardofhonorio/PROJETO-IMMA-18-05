class ItemPedidoModel {
  final String produtoId;
  final String nome;
  final double preco;
  int quantidade;

  ItemPedidoModel({
    required this.produtoId,
    required this.nome,
    required this.preco,
    this.quantidade = 1,
  });

  Map<String, dynamic> toMap() => {
    'produtoId': produtoId,
    'nome': nome,
    'preco': preco,
    'quantidade': quantidade,
  };
}

class PedidoModel {
  final String vendedorId; 
  final String clienteId;
  final List<ItemPedidoModel> itens;
  final double total;
  final String formaPagamento;
  final DateTime dataCriacao;

  PedidoModel({
    required this.vendedorId,
    required this.clienteId,
    required this.itens,
    required this.total,
    required this.formaPagamento,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() => {
    'vendedorId': vendedorId,
    'clienteId': clienteId,
    'itens': itens.map((i) => i.toMap()).toList(),
    'total': total,
    'formaPagamento': formaPagamento,
    'dataCriacao': dataCriacao,
  };
}