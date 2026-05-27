import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto02/app/routes/app_routes.dart';
import 'package:projeto02/features/auth/view/detalhes_cliente_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF9F9F9); 
  final Color corBotao = const Color(0xFFB70000);

  // Variáveis de Filtro
  String _cidadeSelecionada = 'Todos';
  String _termoBusca = '';

  final List<String> _cidadesFiltro = [
    'Todos',
    'Monte Santo',
    'Itamogi',
    'Arceburgo',
    'Guaxupé',
    'Mais'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPrimaria, 
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
  // ==========================================
            // CABEÇALHO BORDÔ (Sem botão de voltar para Telas Principais)
            // ==========================================
            Container(
              color: corPrimaria,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/logo_IMMA.png",
                    height: 50, // Voltei para o tamanho original
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_shipping, size: 40, color: Colors.white),
                  ),
                  // Ícones da direita
                  Row(
                    children: [
                      _buildHeaderIcon(Icons.person_outline, 'Perfil', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: corFundo,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextField(
                                onChanged: (valor) => setState(() => _termoBusca = valor.toLowerCase()),
                                decoration: const InputDecoration(
                                  hintText: 'Buscar clientes por nome, CNPJ ou código...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
                                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt_outlined, color: corPrimaria, size: 20),
                                const SizedBox(width: 6),
                                const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),


                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: _cidadesFiltro.map((cidade) {
                          bool isSelected = _cidadeSelecionada == cidade;
                          return GestureDetector(
                            onTap: () => setState(() => _cidadeSelecionada = cidade),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? corPrimaria : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isSelected ? corPrimaria : Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    cidade,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  if (cidade == 'Mais') ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? Colors.white : Colors.black87),
                                  ]
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LISTA DE CLIENTES VIA FIREBASE
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('clientes')
                            .where('vendedorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // Segurança
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: corPrimaria));
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('Nenhum cliente cadastrado ainda.', style: TextStyle(color: Colors.black54)));
                          }

                          // (Alfabética A-Z)
                          final todosClientes = snapshot.data!.docs.toList();
                          todosClientes.sort((a, b) {
                            final mapA = a.data() as Map<String, dynamic>;
                            final mapB = b.data() as Map<String, dynamic>;
                            
                            String nomeA = (mapA['nomeFantasia']?.toString().isNotEmpty == true ? mapA['nomeFantasia'] : mapA['razaoSocial']) ?? '';
                            String nomeB = (mapB['nomeFantasia']?.toString().isNotEmpty == true ? mapB['nomeFantasia'] : mapB['razaoSocial']) ?? '';
                            
                            return nomeA.toLowerCase().compareTo(nomeB.toLowerCase());
                          });

                          // (Busca + Cidade)
                          final clientesFiltrados = todosClientes.where((doc) {
                            final cliente = doc.data() as Map<String, dynamic>;
                            
                            // Confere a Cidade
                            final cidadeBanco = cliente['cidade']?.toString().toLowerCase().trim() ?? '';
                            final passaFiltroCidade = _cidadeSelecionada == 'Todos' || _cidadeSelecionada == 'Mais' || cidadeBanco == _cidadeSelecionada.toLowerCase();

                            // (Nome ou CNPJ)
                            final razaoSocial = cliente['razaoSocial']?.toString().toLowerCase() ?? '';
                            final nomeFantasia = cliente['nomeFantasia']?.toString().toLowerCase() ?? '';
                            final cnpj = cliente['cnpjCpf']?.toString().toLowerCase() ?? '';
                            
                            final passaFiltroTexto = _termoBusca.isEmpty || 
                                                     razaoSocial.contains(_termoBusca) || 
                                                     nomeFantasia.contains(_termoBusca) ||
                                                     cnpj.contains(_termoBusca);

                            return passaFiltroCidade && passaFiltroTexto;
                          }).toList();

                          if (clientesFiltrados.isEmpty) {
                            return const Center(child: Text('Nenhum cliente encontrado.', style: TextStyle(color: Colors.black54)));
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // (Total de Resultados)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(color: Color(0xFFFFF5F5), shape: BoxShape.circle),
                                      child: Icon(Icons.people_alt_outlined, color: corPrimaria, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${clientesFiltrados.length} clientes cadastrados', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                          const Text('Total de clientes ativos', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text('Ordenar por', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                        Row(
                                          children: [
                                            const Text('Nome (A-Z)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            const Icon(Icons.keyboard_arrow_down, size: 16),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                                  itemCount: clientesFiltrados.length,
                                  itemBuilder: (context, index) {
                                    var doc = clientesFiltrados[index];
                                    var cliente = doc.data() as Map<String, dynamic>;
                                    return _buildClienteCard(doc.id, cliente);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: SizedBox(
        width: 85,
        height: 85,
        child: FloatingActionButton(
          backgroundColor: corBotao, 
          shape: const CircleBorder(),
          elevation: 6,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.cadastrarCliente);
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 30),
              Text('Novo Cliente', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: corFundo, 
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: corPrimaria,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem(Icons.people_alt, 'Clientes', true, () {}), 
                _buildBottomNavItem(Icons.home_outlined, 'Início', false, () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }),
                _buildBottomNavItem(Icons.content_paste_outlined, 'Pedidos', false, () {
                  Navigator.pushReplacementNamed(context, AppRoutes.pedidos);
                }), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClienteCard(String clienteId, Map<String, dynamic> cliente) {
    String nomeExibicao = (cliente['nomeFantasia'] != null && cliente['nomeFantasia'].toString().isNotEmpty) 
        ? cliente['nomeFantasia'] 
        : cliente['razaoSocial'] ?? 'Sem Nome';
    
    String cidadeUf = '${cliente['cidade'] ?? ''} - ${cliente['uf'] ?? ''}';
    String cnpj = cliente['cnpjCpf'] ?? 'Não informado';
    String pedidosQtd = cliente['pedidos']?.toString() ?? '0';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhesClientePage(
            clienteId: clienteId,
            clienteData: cliente,
          ),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFFFF5F5), shape: BoxShape.circle),
            child: Icon(Icons.storefront, color: corBotao, size: 28),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nomeExibicao, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(child: Text(cidadeUf, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Expanded(child: Text('CNPJ $cnpj', style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text('Ativo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ),
              const SizedBox(width: 12),
              
              Column(
                children: [
                  Text(pedidosQtd, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
                  const Text('Pedidos', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
              const SizedBox(width: 12),
              
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          )
        ],
      ),
      ), // Container
    ); // GestureDetector
  }


  Widget _buildHeaderIcon(IconData icon, String label, {String? badge, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              if (badge != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }


  Widget _buildBottomNavItem(IconData icone, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: isSelected ? corPrimaria : Colors.white60, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? corPrimaria : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
