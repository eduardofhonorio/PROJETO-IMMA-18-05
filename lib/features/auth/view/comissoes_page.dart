import 'package:flutter/material.dart';
import 'package:projeto02/features/auth/viewmodel/home_viewmodel.dart';

class ComissoesPage extends StatefulWidget {
  final HomeViewModel viewModel; // Recebe o "cérebro" das regras financeiras

  const ComissoesPage({super.key, required this.viewModel});

  @override
  State<ComissoesPage> createState() => _ComissoesPageState();
}

class _ComissoesPageState extends State<ComissoesPage> {
  String _mesSelecionado = 'Mês Atual';

  void _abrirSeletorDeMes() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecione o Mês',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                // Aqui passamos o nome visível, o número do mês e o ano
                _buildOpcaoMes('Mês Atual', DateTime.now().month, DateTime.now().year),
                _buildOpcaoMes('Abril/2026', 4, 2026),
                _buildOpcaoMes('Março/2026', 3, 2026),
                _buildOpcaoMes('Fevereiro/2026', 2, 2026),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpcaoMes(String label, int mes, int ano) {
    final bool isSelected = _mesSelecionado == label;
    
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFB70000) : Colors.black87,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFB70000)) : null,
      onTap: () {
        setState(() {
          _mesSelecionado = label;
        });
        Navigator.pop(context);
        
        // DISPARA A BUSCA NO FIREBASE PARA O MÊS CLICADO!
        widget.viewModel.buscarDadosFinanceiros(DateTime(ano, mes, 1));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color corPrimaria = const Color(0xFF480404);
    final Color corFundo = const Color(0xFFF9F9F9);

    // O AnimatedBuilder escuta as mudanças do ViewModel
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
                Text('Minhas Comissões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Acompanhe suas comissões', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: _abrirSeletorDeMes,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 18, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        _mesSelecionado,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white),
                    ],
                  ),
                ),
              )
            ],
          ),
          
          // Se estiver carregando, mostra o indicador. Se não, desenha a tela com os valores.
          body: widget.viewModel.isLoadingFinanceiro
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF480404)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          BoxShadow(color: Colors.red.shade900.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
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
                                const Text('Total acumulado', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  // Puxando os dados diretamente do ViewModel atualizado!
                                  'R\$ ${widget.viewModel.totalComissoes.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Comissões confirmadas', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.info_outline, color: Colors.white.withOpacity(0.7), size: 14),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 14),
                                      SizedBox(width: 6),
                                      Text('Pagamento previsto em breve', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ],
                                  ),
                                )
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
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Icon(Icons.account_balance_wallet_outlined, color: corPrimaria, size: 24),
                                ),
                                const SizedBox(height: 12),
                                const Text('Total de pedidos', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text(widget.viewModel.totalPedidosMes.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                const Text('Ticket total', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                Text('R\$ ${widget.viewModel.totalVendidoMes.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text('Como sua comissão é calculada?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    const Text('Você ganha comissão conforme a categoria dos produtos vendidos.', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 16),

                    _buildRegraCard(
                      icon: Icons.star_rounded,
                      corIcone: Colors.green.shade600,
                      titulo: 'Categoria Padrão',
                      descricao: 'Aplica-se à maioria dos produtos do catálogo (Limpeza, Utilidades e Alimentos em geral).',
                      taxa: '2,5%',
                    ),
                    _buildRegraCard(
                      icon: Icons.local_fire_department_rounded,
                      corIcone: Colors.orange.shade600,
                      titulo: 'Categorias Especiais',
                      descricao: 'Aplica-se exclusivamente a: Energéticos, Cervejas, Óleo de Soja e Refrigerantes.',
                      taxa: '1,5%',
                    ),
                    const SizedBox(height: 24),

                    const Text('Resumo das comissões', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 16),
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
                            valorVendas: 'R\$ ${widget.viewModel.totalVendasPadrao.toStringAsFixed(2)}',
                            valorComissao: 'R\$ ${widget.viewModel.comissaoPadrao.toStringAsFixed(2)}',
                          ),
                          Divider(color: Colors.grey.shade100, height: 1),
                          _buildResumoItem(
                            icon: Icons.local_fire_department_rounded,
                            corIcone: Colors.orange.shade600,
                            titulo: 'Categorias Especiais',
                            valorVendas: 'R\$ ${widget.viewModel.totalVendasEspecial.toStringAsFixed(2)}',
                            valorComissao: 'R\$ ${widget.viewModel.comissaoEspecial.toStringAsFixed(2)}',
                          ),
                          const Divider(color: Colors.black12, height: 32, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total de comissões', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              Text('R\$ ${widget.viewModel.totalComissoes.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: corPrimaria)),
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

  Widget _buildRegraCard({required IconData icon, required Color corIcone, required String titulo, required String descricao, required String taxa}) {
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
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(descricao, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: corIcone.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(taxa, style: TextStyle(fontWeight: FontWeight.bold, color: corIcone, fontSize: 16)),
              ),
              const SizedBox(height: 6),
              const Text('de comissão', style: TextStyle(fontSize: 10, color: Colors.black54)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResumoItem({required IconData icon, required Color corIcone, required String titulo, required String valorVendas, required String valorComissao}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: corIcone.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: corIcone, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 2),
                Text('Valor de vendas: $valorVendas', style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          Text(valorComissao, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: corIcone)),
        ],
      ),
    );
  }
}
