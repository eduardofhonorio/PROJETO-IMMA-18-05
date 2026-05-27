import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoDetalhesPage extends StatefulWidget {
  final String pedidoId;

  const PedidoDetalhesPage({super.key, required this.pedidoId});

  @override
  State<PedidoDetalhesPage> createState() => _PedidoDetalhesPageState();
}

class _PedidoDetalhesPageState extends State<PedidoDetalhesPage> {
  static const Color corPrimaria = Color(0xFF480404);
  static const Color corBotao = Color(0xFFB70000);
  static const Color corFundo = Color(0xFFF9F9F9);

  bool _atualizandoStatus = false;

  // Definição de todos os status disponíveis com visual
  static const List<Map<String, dynamic>> _statusDisponiveis = [
    {
      'valor': 'Pendente',
      'icone': Icons.hourglass_empty_rounded,
      'cor': Color(0xFF1565C0),
      'fundo': Color(0xFFE3F2FD),
      'descricao': 'Pedido recebido, aguardando confirmação.',
    },
    {
      'valor': 'Em Preparo',
      'icone': Icons.inventory_2_outlined,
      'cor': Color(0xFF6A1B9A),
      'fundo': Color(0xFFF3E5F5),
      'descricao': 'O pedido está sendo separado no estoque.',
    },
    {
      'valor': 'Saiu para Entrega',
      'icone': Icons.local_shipping_outlined,
      'cor': Color(0xFFE65100),
      'fundo': Color(0xFFFFF3E0),
      'descricao': 'Pedido a caminho do cliente.',
    },
    {
      'valor': 'Concluído',
      'icone': Icons.check_circle_outline_rounded,
      'cor': Color(0xFF2E7D32),
      'fundo': Color(0xFFE8F5E9),
      'descricao': 'Entregue e confirmado pelo cliente.',
    },
    {
      'valor': 'Cancelado',
      'icone': Icons.cancel_outlined,
      'cor': Color(0xFF616161),
      'fundo': Color(0xFFF5F5F5),
      'descricao': 'Pedido cancelado.',
    },
  ];

  Map<String, dynamic> _getEstiloStatus(String status) {
    return _statusDisponiveis.firstWhere(
      (s) => s['valor'].toString().toLowerCase() == status.toLowerCase(),
      orElse: () => _statusDisponiveis.first,
    );
  }

  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return 'Data não informada';
    final d = timestamp.toDate();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  // ==========================================
  // ATUALIZAR STATUS NO FIRESTORE
  // ==========================================
  Future<void> _atualizarStatus(String novoStatus) async {
    setState(() => _atualizandoStatus = true);

    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(widget.pedidoId)
          .update({
        'status': novoStatus,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Status atualizado para "$novoStatus"'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _atualizandoStatus = false);
    }
  }

  // ==========================================
  // BOTTOM SHEET DE TROCA DE STATUS
  // ==========================================
  void _abrirSeletorDeStatus(String statusAtual) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arraste
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded,
                        color: corPrimaria, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Alterar status do pedido',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Selecione o novo status para este pedido.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.black12),

              ...(_statusDisponiveis.map((status) {
                final bool isSelecionado =
                    status['valor'].toString().toLowerCase() ==
                        statusAtual.toLowerCase();

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelecionado
                          ? status['cor']
                          : (status['fundo'] as Color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      status['icone'] as IconData,
                      color: isSelecionado ? Colors.white : status['cor'],
                      size: 22,
                    ),
                  ),
                  title: Text(
                    status['valor'],
                    style: TextStyle(
                      fontWeight: isSelecionado
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelecionado
                          ? status['cor']
                          : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    status['descricao'],
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  trailing: isSelecionado
                      ? Icon(Icons.check_circle_rounded,
                          color: status['cor'], size: 22)
                      : null,
                  onTap: isSelecionado
                      ? null // Status já selecionado: desabilita o tap
                      : () {
                          Navigator.pop(ctx);
                          _atualizarStatus(status['valor']);
                        },
                );
              }).toList()),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corPrimaria,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/logo_IMMA.png',
          height: 90,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.local_shipping, size: 60, color: Colors.white),
        ),
        centerTitle: true,
      ),

      // StreamBuilder: reflete qualquer mudança de status em tempo real
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pedidos')
            .doc(widget.pedidoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: corPrimaria));
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Pedido não encontrado.',
                  style: TextStyle(color: Colors.black54)),
            );
          }

          final pedido = snapshot.data!.data() as Map<String, dynamic>;
          final String statusAtual = pedido['status'] ?? 'Pendente';
          final String clienteNome =
              pedido['clienteNome'] ?? 'Cliente não informado';
          final double total = (pedido['total'] ?? 0.0).toDouble();
          final String pagamento = pedido['pagamento'] ?? 'Não informado';
          final String idCurto =
              widget.pedidoId.substring(0, 6).toUpperCase();
          final List itens = pedido['itens'] ?? [];
          final estiloStatus = _getEstiloStatus(statusAtual);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CABEÇALHO DO PEDIDO
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                            color: Color(0xFFFFF5F5), shape: BoxShape.circle),
                        child: const Icon(Icons.receipt_long_outlined,
                            color: corBotao, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido #$idCurto',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              clienteNome,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            // BADGE DE STATUS ATUAL
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: estiloStatus['fundo'],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(estiloStatus['icone'] as IconData,
                                      size: 14,
                                      color: estiloStatus['cor']),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusAtual,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: estiloStatus['cor']),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // INFORMAÇÕES DO PEDIDO
                _buildSecao(
                  titulo: 'Informações do pedido',
                  icone: Icons.info_outline_rounded,
                  conteudo: Column(
                    children: [
                      _buildInfoRow(Icons.calendar_today_outlined, 'Criado em',
                          _formatarData(pedido['criadoEm'] as Timestamp?)),
                      _buildInfoRow(Icons.payment_outlined, 'Pagamento',
                          pagamento),
                      _buildInfoRow(Icons.attach_money_rounded, 'Total',
                          'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ITENS DO PEDIDO
                _buildSecao(
                  titulo: 'Itens (${itens.length})',
                  icone: Icons.shopping_bag_outlined,
                  conteudo: itens.isEmpty
                      ? const Text('Nenhum item registrado.',
                          style: TextStyle(color: Colors.black54))
                      : Column(
                          children: itens.asMap().entries.map((entry) {
                            final int i = entry.key;
                            final item = entry.value as Map<String, dynamic>;
                            final nome = item['nome'] ?? 'Produto';
                            final int qtd = (item['quantidade'] ?? 1) as int;
                            final double preco =
                                (item['preco'] ?? 0.0).toDouble();
                            final double subtotal = qtd * preco;

                            return Column(
                              children: [
                                if (i > 0)
                                  Divider(
                                      color: Colors.grey.shade100, height: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$qtd',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(nome,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Colors.black87)),
                                          Text(
                                            '${qtd}x  R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black45),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 16),

                // TOTAL FINAL
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: corPrimaria,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total do pedido',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      Text(
                        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // BOTÃO ALTERAR STATUS
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corBotao,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _atualizandoStatus
                        ? null
                        : () => _abrirSeletorDeStatus(statusAtual),
                    icon: _atualizandoStatus
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.swap_horiz_rounded, size: 22),
                    label: Text(
                      _atualizandoStatus
                          ? 'Atualizando...'
                          : 'Alterar Status do Pedido',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES
  // ==========================================
  Widget _buildSecao(
      {required String titulo,
      required IconData icone,
      required Widget conteudo}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, color: corBotao, size: 18),
              const SizedBox(width: 8),
              Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87)),
            ],
          ),
          const Divider(height: 20, color: Colors.black12),
          conteudo,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black45)),
                const SizedBox(height: 2),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
