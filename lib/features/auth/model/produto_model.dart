class ProdutoModel {
  final String id;
  final String nome;
  final double preco;
  final String? urlImagem;

  ProdutoModel({required this.id, required this.nome, required this.preco, this.urlImagem});
}