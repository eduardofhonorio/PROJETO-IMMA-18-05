import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto02/app/routes/app_routes.dart';
import 'package:projeto02/features/auth/view/pedido_detalhes_page.dart';
import 'package:projeto02/features/auth/view/perfil_page.dart';


class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  final Color corPrimaria = const Color(0xFF480404); 
  final Color corFundo = const Color(0xFFF9F9F9); 

  String _termoBusca = '';
  String _filtroData = 'Todos'; 

  final List<String> _opcoesFiltro = ['Todos', 'Hoje', 'Ontem', 'Últimos 7 dias'];

  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return 'Data não informada';
    DateTime d = timestamp.toDate();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _getEstiloStatus(String status) {
    switch (status.toLowerCase()) {
      case 'concluído':
        return {'cor': Colors.green.shade700, 'fundo': Colors.green.shade50, 'icone': Icons.check_circle_outline};
      case 'pendente':
      case 'em preparo':
        return {'cor': Colors.blue.shade700, 'fundo': Colors.blue.shade50, 'icone': Icons.hourglass_top};
      case 'saiu para entrega':
        return {'cor': Colors.orange.shade700, 'fundo': Colors.orange.shade50, 'icone': Icons.local_shipping_outlined};
      case 'agendado':
        return {'cor': Colors.purple.shade700, 'fundo': Colors.purple.shade50, 'icone': Icons.schedule};
      case 'cancelado':
        return {'cor': Colors.grey.shade700, 'fundo': Colors.grey.shade200, 'icone': Icons.remove_circle_outline};
      default:
        return {'cor': Colors.orange.shade700, 'fundo': Colors.orange.shade50, 'icone': Icons.info_outline}; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPrimaria, 
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo_IMMA.png",
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.local_shipping, size: 40, color: Colors.white),
                  ),
                  Row(
                    children: [
                      _buildHeaderIcon(Icons.person_outline, 'Perfil', onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PerfilPage()),
                         );
                      }),
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
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pedidos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(height: 4),
                          Text('Acompanhe e gerencie todos os seus pedidos.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),

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
                                  hintText: 'Buscar pedidos por cliente ou número...',
                                  hintStyle: TextStyle(fontSize: 14, color: Colors.black45),
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
                        children: _opcoesFiltro.map((opcao) {
                          bool isSelected = _filtroData == opcao;
                          return GestureDetector(
                            onTap: () => setState(() => _filtroData = opcao),
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
                                  if (opcao == 'Hoje') ...[
                                    Icon(Icons.calendar_today, size: 14, color: isSelected ? Colors.white : Colors.black87),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    opcao,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('pedidos')
                            .where('vendedorId', isEqualTo: FirebaseAuth.instance.currentUser?.uid) 
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator(color: corPrimaria));
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('Você ainda não possui pedidos cadastrados.', style: TextStyle(color: Colors.black54)));
                          }

                          final todosPedidos = snapshot.data!.docs.toList();
                          todosPedidos.sort((a, b) {
                            Timestamp? tA = (a.data() as Map<String, dynamic>)['criadoEm'] as Timestamp?;
                            Timestamp? tB = (b.data() as Map<String, dynamic>)['criadoEm'] as Timestamp?;
                            if (tA == null || tB == null) return 0;
                            return tB.compareTo(tA);
                          });

                          DateTime agora = DateTime.now();
                          DateTime inicioHoje = DateTime(agora.year, agora.month, agora.day);
                          DateTime inicioOntem = inicioHoje.subtract(const Duration(days: 1));
                          DateTime inicio7Dias = inicioHoje.subtract(const Duration(days: 7));

                          final pedidosFiltrados = todosPedidos.where((doc) {
                            final pedido = doc.data() as Map<String, dynamic>;
                            final nomeCliente = (pedido['clienteNome'] ?? '').toString().toLowerCase();
                            final idFirebase = doc.id.toLowerCase();
                            final dataPedido = (pedido['criadoEm'] as Timestamp?)?.toDate() ?? DateTime(2000);

                            bool passaTexto = _termoBusca.isEmpty || nomeCliente.contains(_termoBusca) || idFirebase.contains(_termoBusca);

                            bool passaData = true;
                            if (_filtroData == 'Hoje') {
                              passaData = dataPedido.isAfter(inicioHoje) || dataPedido.isAtSameMomentAs(inicioHoje);
                            } else if (_filtroData == 'Ontem') {
                              passaData = dataPedido.isAfter(inicioOntem) && dataPedido.isBefore(inicioHoje);
                            } else if (_filtroData == 'Últimos 7 dias') {
                              passaData = dataPedido.isAfter(inicio7Dias);
                            }

                            return passaTexto && passaData;
                          }).toList();

                          if (pedidosFiltrados.isEmpty) {
                            return const Center(child: Text('Nenhum pedido encontrado para os filtros selecionados.', style: TextStyle(color: Colors.black54)));
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: const Color(0xFFFFF5F5), shape: BoxShape.circle),
                                      child: Icon(Icons.assignment_outlined, color: corPrimaria, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${pedidosFiltrados.length} pedidos encontrados', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const Text('Atualizado agora há pouco', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    const Text('Ordenar por', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(width: 4),
                                    const Text('Mais recentes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const Icon(Icons.keyboard_arrow_down, size: 16),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

 Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                                  itemCount: pedidosFiltrados.length,
                                  itemBuilder: (context, index) {
                                    var pedido = pedidosFiltrados[index].data() as Map<String, dynamic>;
                                    
                                    // === ADICIONE ESTA LINHA AQUI ===
                                    pedido['id'] = pedidosFiltrados[index].id;
                                    // ================================
                                    
                                    var idVisual = pedidosFiltrados[index].id.substring(0, 6).toUpperCase(); 
                                    
                                    return _buildPedidoCard(pedido, idVisual);
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

    floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB70000), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.novoPedido); 
        },
        child: const Icon(Icons.add, color: Colors.white, size: 32),
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
                _buildBottomNavItem(Icons.people_alt_outlined, 'Clientes', false, () {
                  Navigator.pushReplacementNamed(context, AppRoutes.clientes);
                }),
                _buildBottomNavItem(Icons.home_outlined, 'Início', false, () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }),
                _buildBottomNavItem(Icons.content_paste, 'Pedidos', true, () {}), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido, String idCurto) {
    String nome = pedido['clienteNome'] ?? 'Cliente Desconhecido';
    double total = (pedido['total'] ?? 0.0).toDouble();
    String statusStr = pedido['status'] ?? 'Pendente';
    
    String dataFormatada = _formatarData(pedido['criadoEm'] as Timestamp?);
    Map<String, dynamic> uiStatus = _getEstiloStatus(statusStr);

    return Container(
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
            child: Icon(Icons.storefront, color: corPrimaria, size: 28),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text('Pedido #$idCurto', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: uiStatus['fundo'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(uiStatus['icone'], size: 14, color: uiStatus['cor']),
                      const SizedBox(width: 4),
                      Text(statusStr, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: uiStatus['cor'])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
  Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(dataFormatada, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // === GESTURE DETECTOR ADICIONADO AQUI ===
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PedidoDetalhesPage(pedido: pedido),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.visibility_outlined, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        const Text('Visualizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 18, color: Colors.black54),
                      ],
                    ),
                  )
                  // =========================================
                ],
              )
            ],
          ),
    );
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