import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto02/features/auth/view/novo_pedido_page.dart';

class PedidoDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> pedido;

  const PedidoDetalhesPage({super.key, required this.pedido});

  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF8F9FA);

  // Formatação de Moeda
  String _formatarMoeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Tag de Status
  Widget _buildStatusTag(String? status) {
    String s = status ?? 'Concluído';
    Color bgColor = Colors.green.shade50;
    Color textColor = Colors.green.shade700;
    IconData icon = Icons.check_circle_outline;

    if (s.toLowerCase().contains('preparo')) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      icon = Icons.hourglass_top;
    } else if (s.toLowerCase().contains('entrega')) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.local_shipping_outlined;
    } else if (s.toLowerCase().contains('agendado')) {
      bgColor = Colors.purple.shade50;
      textColor = Colors.purple.shade700;
      icon = Icons.schedule;
    } else if (s.toLowerCase().contains('cancelado')) {
      bgColor = Colors.grey.shade200;
      textColor = Colors.grey.shade800;
      icon = Icons.remove_circle_outline;
    } else if (s.toLowerCase().contains('pendente')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  // === LÓGICA DE EXCLUSÃO COM MODAL DE CONFIRMAÇÃO ===
   void _confirmarExclusao(BuildContext contextPrincipal) {
    showDialog(
      context: contextPrincipal,
      builder: (BuildContext contextDialog) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 8),
            const Text('Excluir Pedido?'),
          ],
        ),
        content: const Text(
          'Tem certeza que deseja excluir este pedido permanentemente? Essa ação não poderá ser desfeita.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contextDialog), // Fecha apenas o Modal
            child: const Text('Cancelar', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Fecha o Modal de confirmação primeiro usando o contextDialog
              Navigator.pop(contextDialog);
              
              final String? idPedido = pedido['id']; 
              
              if (idPedido != null && idPedido.isNotEmpty) {
                try {
                  // 2. Deleta o pedido no banco de dados Firebase
                  await FirebaseFirestore.instance.collection('pedidos').doc(idPedido).delete();
                  
                  // 3. Usa o contexto da TELA PRINCIPAL para exibir o aviso e fechar a página inteira
                  if (contextPrincipal.mounted) {
                    ScaffoldMessenger.of(contextPrincipal).showSnackBar(
                      const SnackBar(content: Text('Pedido excluído com sucesso!'), backgroundColor: Colors.green),
                    );
                    
                    // Fecha a página de Detalhes do Pedido e volta para a lista automaticamente
                    Navigator.pop(contextPrincipal); 
                  }
                } catch (e) {
                  if (contextPrincipal.mounted) {
                    ScaffoldMessenger.of(contextPrincipal).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sim, Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteNome = pedido['clienteNome'] ?? 'Cliente Desconhecido';
    final total = (pedido['total'] ?? 0).toDouble();
    final pagamento = pedido['pagamento']?.toString() ?? 'À Vista';
    final observacoes = pedido['observacoes'] ?? '';
    final status = pedido['status'] ?? 'Pendente';
    final List<dynamic> itens = pedido['itens'] ?? [];
    
    final criadoEm = pedido['criadoEm'] as Timestamp?;
    final dataStr = criadoEm != null 
        ? '${DateFormat('dd/MM/yyyy').format(criadoEm.toDate())} às ${DateFormat('HH:mm').format(criadoEm.toDate())}'
        : 'Data indisponível';
    final numPedido = '#${criadoEm?.seconds.toString().substring(0, 6) ?? '000000'}';

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalhes do Pedido', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            Text('Acompanhe todas as informações do pedido', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CARD PRINCIPAL (Pedido e Cliente integrados)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.storefront, color: Colors.red.shade800, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pedido', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            Text(numPedido, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                                const SizedBox(width: 6),
                                Text(dataStr, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildStatusTag(status),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1, color: Colors.black12)),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.person, color: Colors.red.shade800, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cliente', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(clienteNome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. LISTA DE ITENS DO PEDIDO
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: corPrimaria, size: 20),
                const SizedBox(width: 8),
                Text('Itens do pedido (${itens.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itens.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
                itemBuilder: (context, index) {
                  final item = itens[index];
                  final nomeItem = item['nome'] ?? 'Produto';
                  final qtd = (item['quantidade'] ?? 1).toInt();
                  final preco = (item['preco'] ?? 0).toDouble();
                  final totalItem = qtd * preco;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nomeItem, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('${qtd}x ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: corPrimaria)),
                                  Text(_formatarMoeda(preco), style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(_formatarMoeda(totalItem), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: corPrimaria)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // 3. RESUMO DO PEDIDO
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, color: corPrimaria, size: 20),
                const SizedBox(width: 8),
                const Text('Resumo do pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), child: const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87)),
                      const SizedBox(width: 12),
                      const Text('Condição de Pagamento', style: TextStyle(color: Colors.black54, fontSize: 14)),
                      const Spacer(),
                      Text(pagamento, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle), child: const Icon(Icons.local_offer_outlined, size: 16, color: Colors.black87)),
                      const SizedBox(width: 12),
                      const Text('Subtotal', style: TextStyle(color: Colors.black54, fontSize: 14)),
                      const Spacer(),
                      Text(_formatarMoeda(total), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1, color: Colors.black12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total do Pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      Text(_formatarMoeda(total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: corPrimaria)),
                    ],
                  ),
                ],
              ),
            ),

            if (observacoes.toString().trim().isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Icon(Icons.notes, color: corPrimaria, size: 20),
                  const SizedBox(width: 8),
                  const Text('Observações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.yellow.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.yellow.shade200)),
                child: Text(observacoes, style: TextStyle(fontSize: 14, color: Colors.yellow.shade900)),
              ),
            ],
            const SizedBox(height: 40),

            // ==========================================
            // 4. BOTÕES DE AÇÃO (EDITAR E EXCLUIR)
            // ==========================================
            Row(
              children: [
                // Botão Excluir (Outlined)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmarExclusao(context),
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 20),
                    label: Text('Excluir', style: TextStyle(color: Colors.red.shade700, fontSize: 15, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.shade200, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
              Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // ATENÇÃO: Substitua 'NovoPedidoPage' pelo nome correto da sua tela de carrinho/pedido
                          builder: (context) => const NovoPedidoPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    label: const Text('Editar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corPrimaria,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}