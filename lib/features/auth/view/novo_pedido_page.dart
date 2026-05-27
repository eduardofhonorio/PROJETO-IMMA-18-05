import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NovoPedidoPage extends StatefulWidget {
  const NovoPedidoPage({super.key});

  @override
  State<NovoPedidoPage> createState() => _NovoPedidoPageState();
}

class _NovoPedidoPageState extends State<NovoPedidoPage> {
  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF9F9F9);
  final Color corBotao = const Color(0xFFB70000);


  String pagamentoSelecionado = '14 Dias';
  final List<String> opcoesPagamento = ['À Vista', '7 Dias', '14 Dias', '21 Dias', '28 Dias', '30 Dias', 'Customizar'];
  bool _isLoading = false; 

  String _termoBusca = '';
  String _observacao = ''; 


  Map<String, dynamic>? _clienteSelecionado;
  String? _clienteIdSelecionado;


  Map<String, Map<String, dynamic>> _carrinho = {};

  double get _totalCarrinho {
    double total = 0.0;
    for (var item in _carrinho.values) {
      total += (item['preco'] as double) * (item['quantidade'] as int);
    }
    return total;
  }

  int get _quantidadeItens {
    int qtd = 0;
    for (var item in _carrinho.values) {
      qtd += item['quantidade'] as int;
    }
    return qtd;
  }

  void _adicionarAoCarrinho(Map<String, dynamic> produto) {
    String codigo = produto['codigo'];
    setState(() {
      if (_carrinho.containsKey(codigo)) {
        _carrinho[codigo]!['quantidade'] += 1;
      } else {
        _carrinho[codigo] = {
          ...produto,
          'quantidade': 1,
        };
      }
    });
  }

  void _abrirDialogCustomizarPrazo(BuildContext context) {
    // Controladores locais apenas para o escopo do Pop-up
    final TextEditingController diasController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.calendar_month, color: Color(0xFF480404)),
              SizedBox(width: 8),
              Text('Customizar Prazo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF480404), fontSize: 18)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Faz o pop-up ocupar apenas o espaço necessário
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Digite a quantidade de dias para o pagamento (máximo 30 dias).',
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: diasController,
                  keyboardType: TextInputType.number,
                  // BLOQUEIO EM TEMPO REAL: Aceita apenas números e até 2 dígitos (ex: 99)
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Ex: 15',
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFB70000), width: 2)),
                    suffixText: 'dias',
                  ),
                  // VALIDAÇÃO DA REGRA DE NEGÓCIO (Máximo 30)
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe os dias';
                    final int? dias = int.tryParse(value);
                    if (dias == null || dias <= 0) return 'Valor inválido';
                    if (dias > 30) return 'O limite máximo é de 30 dias';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Fecha o pop-up sem fazer nada
              child: const Text('Cancelar', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB70000),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final int dias = int.parse(diasController.text);

                  // Aplica o prazo customizado no estado da tela ANTES de fechar o pop-up
                  setState(() {
                    pagamentoSelecionado = '$dias Dias';
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Prazo de $dias dias aplicado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _alterarQuantidade(String codigo, int delta) {
    setState(() {
      if (_carrinho.containsKey(codigo)) {
        _carrinho[codigo]!['quantidade'] += delta;
        if (_carrinho[codigo]!['quantidade'] <= 0) {
          _carrinho.remove(codigo);
        }
      }
    });
  }

  void _removerDoCarrinho(String codigo) {
    setState(() {
      _carrinho.remove(codigo);
    });
  }

  void _limparCarrinho() {
    setState(() {
      _carrinho.clear();
    });
  }
  
  void _abrirDialogObservacao() {
    TextEditingController obsController = TextEditingController(text: _observacao);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Observações', style: TextStyle(fontWeight: FontWeight.bold, color: corPrimaria)),
          content: TextField(
            controller: obsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Digite aqui detalhes importantes para a entrega ou faturamento...',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: corPrimaria, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: corBotao,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                setState(() {
                  _observacao = obsController.text.trim(); 
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }


  void _abrirModalClientes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6, 
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Selecione um Cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('clientes')
                      .where('vendedorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: corPrimaria));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Você não possui clientes cadastrados.'));
                    }

                    final clientes = snapshot.data!.docs.toList();

                    return ListView.builder(
                      itemCount: clientes.length,
                      itemBuilder: (context, index) {
                        final doc = clientes[index];
                        final cliente = doc.data() as Map<String, dynamic>;
                        
                        String nomeExibicao = (cliente['nomeFantasia'] != null && cliente['nomeFantasia'].toString().isNotEmpty) 
                            ? cliente['nomeFantasia'] 
                            : cliente['razaoSocial'] ?? 'Sem nome';
                            
                        String enderecoExibicao = '${cliente['rua'] ?? ''}, ${cliente['numero'] ?? ''} - ${cliente['cidade'] ?? ''}';

                        return ListTile(
                          leading: CircleAvatar(backgroundColor: const Color(0xFFFFF5F5), child: Icon(Icons.storefront, color: corBotao)),
                          title: Text(nomeExibicao, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          subtitle: Text(enderecoExibicao, style: const TextStyle(color: Colors.black54)),
                          onTap: () {
                            setState(() {
                              _clienteSelecionado = cliente;
                              _clienteIdSelecionado = doc.id;
                            });
                            Navigator.pop(context); 
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _abrirModalTodosProdutos() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75, 
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Todos os Produtos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('produtos').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: corPrimaria));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Nenhum produto cadastrado no estoque.'));
                    }

                    final produtos = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: produtos.length,
                      itemBuilder: (context, index) {
                        final produto = produtos[index].data() as Map<String, dynamic>;
                        
                        String nome = produto['nome'] ?? 'Produto';
                        String imagem = produto['imagem'] ?? 'assets/images/higiene.png';
                        double preco = (produto['preco'] ?? 0.0).toDouble();
                        String precoFmt = preco.toStringAsFixed(2).replaceAll('.', ',');

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Image.asset(imagem, width: 50, height: 50, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, color: Colors.grey.shade300)),
                          title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('R\$ $precoFmt', style: TextStyle(color: corBotao, fontWeight: FontWeight.bold)),
                          trailing: Container(
                            decoration: BoxDecoration(color: corPrimaria, borderRadius: BorderRadius.circular(8)),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                _adicionarAoCarrinho(produto);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$nome adicionado!'), 
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.green,
                                  )
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarPedido() async {
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente antes de continuar!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos 1 produto ao pedido!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? vendedorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendedorId == null) throw Exception("Vendedor não autenticado.");

      // Pegando o nome
      String nomeDoClienteSalvo = (_clienteSelecionado!['nomeFantasia'] != null && _clienteSelecionado!['nomeFantasia'].toString().isNotEmpty)
          ? _clienteSelecionado!['nomeFantasia']
          : _clienteSelecionado!['razaoSocial'] ?? 'Sem nome';

      // NOVO: Extraindo a cidade do cliente selecionado (importante para o filtro de Vales na Rota funcionar!)
      // Tenta pegar 'cidade', se não existir tenta 'municipio', se não houver nenhuma, salva como não informada.
      String cidadeDoCliente = _clienteSelecionado!['cidade'] ?? _clienteSelecionado!['municipio'] ?? 'Cidade não informada';

      await FirebaseFirestore.instance.collection('pedidos').add({
        'vendedorId': vendedorId,
        'clienteId': _clienteIdSelecionado, 
        'clienteNome': nomeDoClienteSalvo,
        'cidade': cidadeDoCliente, // <--- ADICIONADO AQUI PARA ALIMENTAR O FILTRO
        'total': _totalCarrinho,
        'pagamento': pagamentoSelecionado,
        'quantidadeItens': _quantidadeItens,
        'status': 'Pendente', 
        'observacao': _observacao, 
        'itens': _carrinho.values.toList(),
        'criadoEm': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido enviado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Volta para a tela anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar pedido: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String clienteNomeExibicao = _clienteSelecionado != null
        ? ((_clienteSelecionado!['nomeFantasia']?.toString().isNotEmpty == true)
            ? _clienteSelecionado!['nomeFantasia']
            : _clienteSelecionado!['razaoSocial'] ?? 'Sem nome')
        : 'Nenhum cliente selecionado';

    String clienteEnderecoExibicao = _clienteSelecionado != null
        ? '${_clienteSelecionado!['rua']}, ${_clienteSelecionado!['numero']} - ${_clienteSelecionado!['cidade']} - ${_clienteSelecionado!['uf']}'
        : 'Toque em trocar para selecionar';

    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corPrimaria,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          "assets/images/logo_IMMA.png",
          height: 40,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.local_shipping, size: 36, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _abrirModalClientes,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _clienteSelecionado == null ? corBotao : Colors.grey.shade200, width: _clienteSelecionado == null ? 2 : 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFFFFF5F5), shape: BoxShape.circle),
                      child: Icon(Icons.storefront, color: corBotao, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cliente', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(
                            clienteNomeExibicao, 
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold, 
                              color: _clienteSelecionado == null ? corBotao : Colors.black87
                            )
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: _clienteSelecionado == null ? corBotao : Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  clienteEnderecoExibicao, 
                                  style: TextStyle(fontSize: 12, color: _clienteSelecionado == null ? corBotao : Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Icon(Icons.sync, color: corBotao),
                        const SizedBox(height: 4),
                        Text('Trocar\ncliente', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: corBotao, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (valor) {
                setState(() {
                  _termoBusca = valor.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar produtos por nome, marca ou código',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Catálogo de Produtos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                GestureDetector(
                  onTap: _abrirModalTodosProdutos,
                  child: Row(
                    children: [
                      Text('Ver todos', style: TextStyle(fontSize: 13, color: corBotao, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right, size: 18, color: corBotao),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 190,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('produtos').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: corPrimaria));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Nenhum produto em estoque.', style: TextStyle(color: Colors.black54)));
                  }

                  final todosProdutos = snapshot.data!.docs;

                  final produtosFiltrados = todosProdutos.where((doc) {
                    final p = doc.data() as Map<String, dynamic>;
                    final nome = (p['nome'] ?? '').toString().toLowerCase();
                    final codigo = (p['codigo'] ?? '').toString().toLowerCase();
                    return _termoBusca.isEmpty || nome.contains(_termoBusca) || codigo.contains(_termoBusca);
                  }).toList();

                  if (produtosFiltrados.isEmpty) {
                    return const Center(child: Text('Nenhum produto encontrado na busca.', style: TextStyle(color: Colors.black54)));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: produtosFiltrados.length,
                    itemBuilder: (context, index) {
                      final produtoMap = produtosFiltrados[index].data() as Map<String, dynamic>;
                      return _buildProdutoCard(produtoMap);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Itens do pedido (${_carrinho.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                if (_carrinho.isNotEmpty)
                  GestureDetector(
                    onTap: _limparCarrinho,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: corBotao),
                        const SizedBox(width: 4),
                        Text('Limpar tudo', style: TextStyle(fontSize: 13, color: corBotao, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            
            if (_carrinho.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: const Text('Seu carrinho está vazio.\nAdicione produtos pelo botão "+"', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _carrinho.length,
                itemBuilder: (context, index) {
                  String chave = _carrinho.keys.elementAt(index);
                  Map<String, dynamic> item = _carrinho[chave]!;
                  return _buildItemCarrinho(item);
                },
              ),
            const SizedBox(height: 20),

            // RESUMO DO TOTAL
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Color(0xFFFFF5F5), shape: BoxShape.circle),
                    child: Icon(Icons.shopping_cart_outlined, color: corBotao),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total de itens', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text('$_quantidadeItens itens', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total do pedido', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      Text('R\$ ${_totalCarrinho.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Pagamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: opcoesPagamento.map((pagamento) {
                  bool isSelected = pagamento == pagamentoSelecionado;
                  return GestureDetector(
                    onTap: () {
                      if (pagamento == 'Customizar') {
                        // 1. Se for Customizar, abre o nosso Pop-Up inteligente!
                        _abrirDialogCustomizarPrazo(context);
                      } else {
                        // 2. Se for qualquer outra opção, seleciona ela normalmente
                        setState(() => pagamentoSelecionado = pagamento);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? corBotao : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? corBotao : Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          if (pagamento == 'Customizar') ...[
                            Icon(Icons.calendar_month, size: 16, color: isSelected ? Colors.white : Colors.black87),
                            const SizedBox(width: 6),
                          ],
                          Text(pagamento, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _abrirDialogObservacao, 
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFD6D6))),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: corBotao),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Observações (opcional)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text(
                            _observacao.isEmpty 
                                ? 'Adicione informações importantes para este pedido'
                                : _observacao, 
                            style: TextStyle(
                              fontSize: 12, 
                              color: _observacao.isEmpty ? Colors.black54 : Colors.black87,
                              fontWeight: _observacao.isEmpty ? FontWeight.normal : FontWeight.w600,
                            ),
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: corBotao,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 4,
                ),
                onPressed: _isLoading ? null : _salvarPedido, 
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmar Orçamento', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Text('Pedido seguro e seus dados protegidos', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    String nome = produto['nome'] ?? 'Produto';
    String imagem = produto['imagem'] ?? 'assets/images/higiene.png';
    double preco = (produto['preco'] ?? 0.0).toDouble();
    String precoFormatado = preco.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(imagem, errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey.shade300, size: 40)),
          ),
          const SizedBox(height: 8),
          Text(nome, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('R\$ $precoFormatado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: corBotao)),
          const SizedBox(height: 8),
          
          InkWell(
            onTap: () => _adicionarAoCarrinho(produto),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.add, size: 16, color: Colors.black87),
            ),
          )
        ],
      ),
    );
  }
  

  Widget _buildItemCarrinho(Map<String, dynamic> item) {
    String codigo = item['codigo'];
    String nome = item['nome'];
    String imagem = item['imagem'];
    int quantidade = item['quantidade'];
    double precoUnitario = (item['preco'] as double);
    double precoTotal = precoUnitario * quantidade;

    String precoUnitarioFmt = precoUnitario.toStringAsFixed(2).replaceAll('.', ',');
    String precoTotalFmt = precoTotal.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagem, width: 50, height: 50, errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, color: Colors.grey.shade300, size: 40)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                Text('Código: $codigo', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                const SizedBox(height: 8),
                Text('R\$ $precoUnitarioFmt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: corBotao)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _removerDoCarrinho(codigo), 
                child: const Icon(Icons.close, size: 18, color: Colors.black45),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _alterarQuantidade(codigo, -1), 
                    child: Container(decoration: BoxDecoration(color: corPrimaria, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.remove, color: Colors.white, size: 20)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('$quantidade', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  GestureDetector(
                    onTap: () => _alterarQuantidade(codigo, 1), 
                    child: Container(decoration: BoxDecoration(color: corPrimaria, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.add, color: Colors.white, size: 20)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('R\$ $precoTotalFmt', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }
}