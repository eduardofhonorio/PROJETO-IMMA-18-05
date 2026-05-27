import 'package:flutter/material.dart';
import 'package:projeto02/features/auth/viewmodel/home_viewmodel.dart';

class ComissoesPage extends StatefulWidget {
  final HomeViewModel viewModel;

  const ComissoesPage({super.key, required this.viewModel});

  @override
  State<ComissoesPage> createState() => _ComissoesPageState();
}

class _ComissoesPageState extends State<ComissoesPage> {
  static const Color corPrimaria = Color(0xFF480404);
  static const Color corFundo = Color(0xFFF9F9F9);

  // Mês selecionado: começa no mês atual
  late DateTime _dataSelecionada;
   late String _labelSelecionada;

  static const List<String> _nomesMeses = [
    '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _dataSelecionada = DateTime(agora.year, agora.month, 1);
    _labelSelecionada = _formatarLabel(_dataSelecionada, isMesAtual: true);
  }

  // Gera os últimos 12 meses dinamicamente a partir de hoje
  List<Map<String, dynamic>> _gerarUltimosMeses() {
    final List<Map<String, dynamic>> meses = [];
    final agora = DateTime.now();

    for (int i = 0; i < 12; i++) {
      // Dart normaliza automaticamente: mes=0 → Dezembro do ano anterior
      final data = DateTime(agora.year, agora.month - i, 1);
      meses.add({
        'data': data,
        'label': _formatarLabel(data, isMesAtual: i == 0),
        'labelCurto': '${_nomesMeses[data.month]}/${data.year}',
      });
    }

    return meses;
  }

  String _formatarLabel(DateTime data, {bool isMesAtual = false}) {
    final nome = _nomesMeses[data.month];
    return isMesAtual ? 'Mês Atual — $nome/${data.year}' : '$nome/${data.year}';
  }

  String _labelAppBar() {
    // No AppBar exibe só "Maio 2026" (sem "Mês Atual —") para não ficar longo
    return '${_nomesMeses[_dataSelecionada.month]} ${_dataSelecionada.year}';
  }

  void _abrirSeletorDeMes() {
    final meses = _gerarUltimosMeses();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                      Icon(Icons.calendar_month_outlined,
                          color: corPrimaria, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Selecionar período',
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
                    'Escolha o mês para visualizar suas comissões.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.black12),

                // Lista dinâmica dos últimos 12 meses
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meses.length,
                  itemBuilder: (_, index) {
                    final mes = meses[index];
                    final DateTime data = mes['data'];
                    final bool isSelecionado =
                        data.month == _dataSelecionada.month &&
                            data.year == _dataSelecionada.year;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelecionado
                              ? corPrimaria
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            data.month.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelecionado
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        mes['label'],
                        style: TextStyle(
                          fontWeight: isSelecionado
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelecionado ? corPrimaria : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                      trailing: isSelecionado
                          ? const Icon(Icons.check_circle_rounded,
                              color: corPrimaria, size: 22)
                          : null,
                      onTap: () {
                        setState(() {
                          _dataSelecionada = data;
                          _labelSelecionada = mes['label'];
                        });
                        Navigator.pop(ctx);
                        // Dispara a busca no Firestore para o mês clicado
                        widget.viewModel.buscarDadosFinanceiros(data);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: corFundo,
          appBar: AppBar(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Minhas Comissões',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Acompanhe suas comissões',
                    style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: _abrirSeletorDeMes,
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        _labelAppBar(),
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: widget.viewModel.isLoadingFinanceiro
              ? const Center(
                  child: CircularProgressIndicator(color: corPrimaria))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CARD PRINCIPAL COM TOTAL
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [corPrimaria, Colors.red.shade800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Exibe o mês selecionado no card
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _labelAppBar(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Total acumulado',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'R\$ ${widget.viewModel.totalComissoes.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text('Comissões confirmadas',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                      const SizedBox(width: 4),
                                      Icon(Icons.info_outline,
                                          color: Colors.white.withOpacity(0.7),
                                          size: 14),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white, size: 14),
                                        SizedBox(width: 6),
                                        Text('Pagamento previsto em breve',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: corPrimaria,
                                        size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Total de pedidos',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12)),
                                  Text(
                                      widget.viewModel.totalPedidosMes
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  const Text('Ticket total',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12)),
                                  Text(
                                      'R\$ ${widget.viewModel.totalVendidoMes.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // REGRAS DE COMISSÃO
                      const Text('Como sua comissão é calculada?',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 4),
                      const Text(
                          'Você ganha comissão conforme a categoria dos produtos vendidos.',
                          style: TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 16),

                      _buildRegraCard(
                        icon: Icons.star_rounded,
                        corIcone: Colors.green.shade600,
                        titulo: 'Categoria Padrão',
                        descricao:
                            'Aplica-se à maioria dos produtos do catálogo (Limpeza, Utilidades e Alimentos em geral).',
                        taxa: '2,5%',
                      ),
                      _buildRegraCard(
                        icon: Icons.local_fire_department_rounded,
                        corIcone: Colors.orange.shade600,
                        titulo: 'Categorias Especiais',
                        descricao:
                            'Aplica-se exclusivamente a: Energéticos, Cervejas, Óleo de Soja e Refrigerantes.',
                        taxa: '1,5%',
                      ),
                      const SizedBox(height: 24),

                      // RESUMO
                      const Text('Resumo das comissões',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 16),

                      // Estado vazio: sem pedidos no mês
                      if (widget.viewModel.totalPedidosMes == 0)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 48, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum pedido em ${_labelAppBar()}',
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildResumoItem(
                                icon: Icons.star_rounded,
                                corIcone: Colors.green.shade600,
                                titulo: 'Categoria Padrão',
                                valorVendas:
                                    'R\$ ${widget.viewModel.totalVendasPadrao.toStringAsFixed(2)}',
                                valorComissao:
                                    'R\$ ${widget.viewModel.comissaoPadrao.toStringAsFixed(2)}',
                              ),
                              Divider(
                                  color: Colors.grey.shade100, height: 1),
                              _buildResumoItem(
                                icon: Icons.local_fire_department_rounded,
                                corIcone: Colors.orange.shade600,
                                titulo: 'Categorias Especiais',
                                valorVendas:
                                    'R\$ ${widget.viewModel.totalVendasEspecial.toStringAsFixed(2)}',
                                valorComissao:
                                    'R\$ ${widget.viewModel.comissaoEspecial.toStringAsFixed(2)}',
                              ),
                              const Divider(
                                  color: Colors.black12,
                                  height: 32,
                                  thickness: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total de comissões',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87)),
                                  Text(
                                    'R\$ ${widget.viewModel.totalComissoes.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: corPrimaria),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES
  // ==========================================
  Widget _buildRegraCard({
    required IconData icon,
    required Color corIcone,
    required String titulo,
    required String descricao,
    required String taxa,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: corIcone.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: corIcone, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text(descricao,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: corIcone.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(taxa,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: corIcone,
                        fontSize: 16)),
              ),
              const SizedBox(height: 6),
              const Text('de comissão',
                  style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem({
    required IconData icon,
    required Color corIcone,
    required String titulo,
    required String valorVendas,
    required String valorComissao,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: corIcone.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: corIcone, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text('Valor de vendas: $valorVendas',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Text(valorComissao,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: corIcone)),
        ],
      ),
    );
  }
}
