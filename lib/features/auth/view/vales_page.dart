import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto02/features/auth/viewmodel/vales_viewmodel.dart';

class ValesPage extends StatefulWidget {
  const ValesPage({super.key});

  @override
  State<ValesPage> createState() => _ValesPageState();
}

class _ValesPageState extends State<ValesPage> {
  final ValesViewModel _viewModel = ValesViewModel();
  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF8F9FA);
  
  final TextEditingController _buscaController = TextEditingController();
  int _abaSelecionada = 0; // 0: Todos, 1: Vencidos, 2: A vencer

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE DATAS E VENCIMENTOS ---
  DateTime? _calcularDataVencimento(Timestamp? criadoEm, String pagamento) {
    if (criadoEm == null) return null;
    DateTime dataCriacao = criadoEm.toDate();
    
    // Extrai o número de dias da string (Ex: "14 Dias" -> 14)
    int diasAdicionais = 30; // Padrão caso seja "Vale" genérico
    final match = RegExp(r'\d+').firstMatch(pagamento);
    if (match != null) {
      diasAdicionais = int.parse(match.group(0)!);
    }
    
    return dataCriacao.add(Duration(days: diasAdicionais));
  }

  int _calcularDiasParaVencimento(DateTime dataVencimento) {
    DateTime hoje = DateTime.now();
    DateTime dataAtual = DateTime(hoje.year, hoje.month, hoje.day);
    DateTime vencimento = DateTime(dataVencimento.year, dataVencimento.month, dataVencimento.day);
    return vencimento.difference(dataAtual).inDays;
  }

  // --- INTERFACE PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        // Aplica os filtros locais (Busca e Abas) em cima do filtro do ViewModel
        List<Map<String, dynamic>> valesExibidos = _viewModel.valesFiltrados.where((vale) {
          // Filtro de Busca por Texto
          bool passaBusca = true;
          if (_buscaController.text.isNotEmpty) {
            final termo = _buscaController.text.toLowerCase();
            final cliente = (vale['clienteNome'] ?? '').toString().toLowerCase();
            passaBusca = cliente.contains(termo);
          }

          // Filtro de Abas
          bool passaAba = true;
          final vencimento = _calcularDataVencimento(vale['criadoEm'] as Timestamp?, vale['pagamento']?.toString() ?? '');
          if (vencimento != null) {
            final dias = _calcularDiasParaVencimento(vencimento);
            if (_abaSelecionada == 1 && dias >= 0) passaAba = false; // Aba Vencidos
            if (_abaSelecionada == 2 && dias < 0) passaAba = false;  // Aba A Vencer
          }

          return passaBusca && passaAba;
        }).toList();

        // Variáveis do Dashboard Financeiro Superior
        int qtdTodos = 0;
        int qtdVencidos = 0;
        int qtdAVencer = 0;
        double totalVencidos = 0.0;
        double totalAVencer = 0.0;

        for (var vale in _viewModel.valesFiltrados) {
          qtdTodos++;
          double valor = (vale['total'] ?? 0).toDouble();
          final vencimento = _calcularDataVencimento(vale['criadoEm'] as Timestamp?, vale['pagamento']?.toString() ?? '');
          
          if (vencimento != null) {
            if (_calcularDiasParaVencimento(vencimento) < 0) {
              qtdVencidos++;
              totalVencidos += valor;
            } else {
              qtdAVencer++;
              totalAVencer += valor;
            }
          }
        }

        return Scaffold(
          backgroundColor: corFundo,
          appBar: AppBar(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vales na Rota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Acompanhe os pagamentos a prazo dos clientes', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined),
                onPressed: _viewModel.limparFiltros,
                tooltip: 'Limpar Filtros',
              )
            ],
          ),
          body: Column(
            children: [
              // 1. FILTROS SUPERIORES (Data, Cidade, Cliente)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFiltroBotao(
                        label: _viewModel.dataSelecionada != null ? DateFormat('dd/MM/yyyy').format(_viewModel.dataSelecionada!) : 'Data de emissão',
                        icon: Icons.calendar_today_outlined,
                        onTap: () async {
                          final data = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (data != null) _viewModel.definirFiltroData(data);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildDropdownFiltro(
                        hint: 'Cidades',
                        icon: Icons.location_on_outlined,
                        value: _viewModel.cidadeSelecionada,
                        items: _viewModel.cidadesDisponiveis,
                        onChanged: _viewModel.definirFiltroCidade,
                      ),
                      const SizedBox(width: 8),
                      _buildDropdownFiltro(
                        hint: 'Todos os clientes',
                        icon: Icons.person_outline,
                        value: _viewModel.clienteSelecionado,
                        items: _viewModel.clientesDisponiveis,
                        onChanged: _viewModel.definirFiltroCliente,
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 2. DASHBOARD FINANCEIRO LARANJA
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5), // Laranja bem clarinho
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.orange.shade400,
                                  radius: 24,
                                  child: const Icon(Icons.monetization_on_outlined, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total a receber (filtrado)', style: TextStyle(color: Colors.black54, fontSize: 13)),
                                      Text(
                                        'R\$ ${_viewModel.totalValesFiltrados.toStringAsFixed(2).replaceAll('.', ',')}',
                                        style: TextStyle(color: Colors.orange.shade800, fontSize: 26, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, color: Colors.black12),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoColuna('Títulos', qtdTodos.toString()),
                                _buildInfoColuna('Valor total', 'R\$ ${_viewModel.totalValesFiltrados.toStringAsFixed(2)}'),
                                _buildInfoColuna('Vencidos', 'R\$ ${totalVencidos.toStringAsFixed(2)}'),
                                _buildInfoColuna('A vencer', 'R\$ ${totalAVencer.toStringAsFixed(2)}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. ABAS NAVEGÁVEIS E BUSCA
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            _buildAba('Todos ($qtdTodos)', 0),
                            _buildAba('Vencidos ($qtdVencidos)', 1),
                            _buildAba('A vencer ($qtdAVencer)', 2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Barra de Pesquisa
                      TextField(
                        controller: _buscaController,
                        onChanged: (v) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Buscar por cliente...',
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.black45),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. LISTA DE CARDS DE VALES
                      if (_viewModel.isLoading)
                        const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())
                      else if (valesExibidos.isEmpty)
                        const Padding(padding: EdgeInsets.all(32), child: Text("Nenhum título encontrado.", style: TextStyle(color: Colors.black54)))
                      else
                        ...valesExibidos.map((vale) => _buildCardVale(vale)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildFiltroBotao({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFiltro({required String hint, required IconData icon, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 36,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColuna(String titulo, String valor) {
    return Column(
      children: [
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildAba(String titulo, int index) {
    final bool isSelected = _abaSelecionada == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _abaSelecionada = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? corPrimaria : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardVale(Map<String, dynamic> vale) {
    final cliente = vale['clienteNome'] ?? 'Cliente Desconhecido';
    final cidade = vale['cidade'] ?? 'Cidade não informada';
    final total = (vale['total'] ?? 0).toDouble();
    
    // Tratamento de datas
    final criadoEmStamp = vale['criadoEm'] as Timestamp?;
    final dataCriacaoStr = criadoEmStamp != null ? DateFormat('dd/MM/yyyy HH:mm').format(criadoEmStamp.toDate()) : 'N/A';
    
    final vencimento = _calcularDataVencimento(criadoEmStamp, vale['pagamento']?.toString() ?? '');
    final dataVencStr = vencimento != null ? DateFormat('dd/MM/yyyy').format(vencimento) : 'N/A';
    
    int diasRestantes = vencimento != null ? _calcularDiasParaVencimento(vencimento) : 0;
    bool isVencido = diasRestantes < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // CABEÇALHO DO CARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: Icon(Icons.storefront, color: Colors.red.shade800, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(cidade, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                // TAG DE STATUS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVencido ? Colors.red.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isVencido ? Colors.red.shade100 : Colors.orange.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(isVencido ? Icons.warning_amber_rounded : Icons.schedule, size: 12, color: isVencido ? Colors.red.shade700 : Colors.orange.shade800),
                      const SizedBox(width: 4),
                      Text(
                        isVencido ? 'Vencido há ${diasRestantes.abs()} dias' : 'Vence em $diasRestantes dias',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isVencido ? Colors.red.shade700 : Colors.orange.shade800),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // DADOS DO TÍTULO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardDado('Vencimento', dataVencStr),
                _buildCardDado('Forma Pgt.', vale['pagamento']?.toString() ?? 'Vale'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Valor', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isVencido ? Colors.red.shade700 : Colors.orange.shade800),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // RODAPÉ DO CARD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text('Criado em $dataCriacaoStr', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
                Row(
                  children: [
                    Text('Ver detalhes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: corPrimaria)),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 16, color: corPrimaria),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCardDado(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}