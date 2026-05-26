import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto02/app/routes/app_routes.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF8F9FA);

  bool _isLoading = true;

  // Variáveis reais do vendedor
  String _nomeVendedor = 'Carregando...';
  String _emailVendedor = '';
  String _telefoneVendedor = 'Não informado';
  String _cidadeVendedor = 'Não informada';

  // Métricas
  double _totalVendas = 0.0;
  int _totalPedidos = 0;
  int _clientesAtendidos = 0;
  double _ticketMedio = 0.0;

  // Top Produto
  String _topProdutoNome = 'Nenhum dado';
  int _topProdutoQtd = 0;
  double _topProdutoValor = 0.0;

  // Top Clientes
  List<MapEntry<String, double>> _topClientes = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosVendedor();
  }

  Future<void> _carregarDadosVendedor() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // 1. Busca os dados pessoais na coleção 'users' (onde o cadastro salva)
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _nomeVendedor = data['name'] ?? 'Vendedor';
        _emailVendedor = data['email'] ?? FirebaseAuth.instance.currentUser?.email ?? '';
        // Se você tiver esses campos salvos no Firebase, ele puxa. Se não, mantem o padrão.
        _telefoneVendedor = data['telefone'] ?? 'Não cadastrado';
        _cidadeVendedor = data['endereco'] ?? 'Não cadastrado'; 
      }

      // 2. Busca todos os pedidos desse vendedor para gerar as métricas
      final pedidosSnapshot = await FirebaseFirestore.instance
          .collection('pedidos')
          .where('vendedorId', isEqualTo: uid)
          .get();

      _totalPedidos = pedidosSnapshot.docs.length;
      Set<String> clientesUnicos = {};
      Map<String, double> vendasPorCliente = {};
      Map<String, Map<String, dynamic>> produtosVendidos = {}; // Agrupa os produtos

      for (var doc in pedidosSnapshot.docs) {
        final pedido = doc.data();
        double valorPedido = (pedido['total'] ?? 0).toDouble();
        _totalVendas += valorPedido;

        String nomeCliente = pedido['clienteNome'] ?? 'Desconhecido';
        clientesUnicos.add(nomeCliente);
        vendasPorCliente[nomeCliente] = (vendasPorCliente[nomeCliente] ?? 0) + valorPedido;

        // Varrer os itens dentro do pedido para descobrir o mais vendido
        List<dynamic> itens = pedido['itens'] ?? [];
        for (var item in itens) {
          String nomeItem = item['nome'] ?? 'Produto';
          int qtd = (item['quantidade'] ?? 1).toInt();
          double preco = (item['preco'] ?? 0).toDouble();

          if (!produtosVendidos.containsKey(nomeItem)) {
            produtosVendidos[nomeItem] = {'qtd': 0, 'valorTotal': 0.0};
          }
          produtosVendidos[nomeItem]!['qtd'] += qtd;
          produtosVendidos[nomeItem]!['valorTotal'] += (qtd * preco);
        }
      }

      _clientesAtendidos = clientesUnicos.length;
      _ticketMedio = _totalPedidos > 0 ? (_totalVendas / _totalPedidos) : 0.0;

      // Ordenar os Top 3 Clientes que mais compraram
      var listaClientes = vendasPorCliente.entries.toList();
      listaClientes.sort((a, b) => b.value.compareTo(a.value));
      _topClientes = listaClientes.take(3).toList();

      // Ordenar o Produto Mais Vendido (por quantidade)
      var listaProdutos = produtosVendidos.entries.toList();
      listaProdutos.sort((a, b) => (b.value['qtd'] as int).compareTo(a.value['qtd'] as int));
      
      if (listaProdutos.isNotEmpty) {
        _topProdutoNome = listaProdutos.first.key;
        _topProdutoQtd = listaProdutos.first.value['qtd'];
        _topProdutoValor = listaProdutos.first.value['valorTotal'];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dados do perfil: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para formatar a moeda no padrão R$ Brasileiro
  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  void _deslogar(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corPrimaria,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Voltar',
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF480404)))
          : Stack(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: corPrimaria,
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Meu Perfil',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Acompanhe seu desempenho real',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      const SizedBox(height: 24),

                      // 1. CARD DO VENDEDOR
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                              child: const Icon(Icons.person, size: 50, color: Colors.black26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_nomeVendedor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('Vendedor  •  ', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                      Text('IMMA Atacadistas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: corPrimaria)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoLinha(Icons.phone, _telefoneVendedor),
                                  _buildInfoLinha(Icons.email_outlined, _emailVendedor),
                                  _buildInfoLinha(Icons.location_on_outlined, _cidadeVendedor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. BARRA VISÃO GERAL
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: const Color(0xFF380303), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.bar_chart, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Visão Geral', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('Histórico Completo da Rota', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. CARDS DE DASHBOARD 
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(icone: Icons.attach_money, corIcone: Colors.red.shade400, titulo: 'Total de Vendas', valor: _formatarMoeda(_totalVendas))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(icone: Icons.inventory_2_outlined, corIcone: Colors.green.shade400, titulo: 'Pedidos Realizados', valor: _totalPedidos.toString())),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard(icone: Icons.people_outline, corIcone: Colors.orange.shade400, titulo: 'Clientes Atendidos', valor: _clientesAtendidos.toString())),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(icone: Icons.trending_up, corIcone: Colors.purple.shade400, titulo: 'Ticket Médio', valor: _formatarMoeda(_ticketMedio))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. TOP PRODUTOS E CLIENTES
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Produto Mais Vendido
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Produto mais vendido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 16),
                                  Center(child: Icon(Icons.image_outlined, size: 50, color: Colors.grey.shade300)),
                                  const SizedBox(height: 12),
                                  Text(_topProdutoNome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('$_topProdutoQtd unidades vendidas', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Total vendido', style: TextStyle(fontSize: 10, color: Colors.red.shade800)),
                                        Text(_formatarMoeda(_topProdutoValor), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red.shade900)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Top Clientes
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Top clientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                  const SizedBox(height: 16),
                                  if (_topClientes.isEmpty)
                                    const Text('Nenhuma venda registrada.', style: TextStyle(fontSize: 11, color: Colors.black54))
                                  else
                                    ...List.generate(_topClientes.length, (index) {
                                      return Column(
                                        children: [
                                          _buildTopClienteItem(posicao: '${index + 1}', nome: _topClientes[index].key, valor: _formatarMoeda(_topClientes[index].value)),
                                          if (index < _topClientes.length - 1)
                                            const Divider(height: 16, color: Colors.black12),
                                        ],
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 5. BOTÃO DE LOGOUT
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _deslogar(context),
                          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                          label: const Text('Sair da conta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corPrimaria,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoLinha(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icone, size: 14, color: Colors.black45),
          const SizedBox(width: 6),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icone, required Color corIcone, required String titulo, required String valor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: corIcone.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icone, color: corIcone, size: 22),
          ),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTopClienteItem({required String posicao, required String nome, required String valor}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
          child: Text(posicao, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nome, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(valor, style: TextStyle(fontSize: 10, color: Colors.red.shade800, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}