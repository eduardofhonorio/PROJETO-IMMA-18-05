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
  final Color corFundo = const Color(0xFFF9F9F9);

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: _viewModel.dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: corPrimaria),
          ),
          child: child!,
        );
      },
    );
    if (selecionada != null) {
      _viewModel.definirFiltroData(selecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: corFundo,
          appBar: AppBar(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const Text('Vales na Rota', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              // Botão para limpar os filtros
              if (_viewModel.dataSelecionada != null || _viewModel.cidadeSelecionada != null || _viewModel.clienteSelecionado != null)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off, color: Colors.white),
                  onPressed: _viewModel.limparFiltros,
                  tooltip: 'Limpar Filtros',
                )
            ],
          ),
          body: Column(
            children: [
              // HEADER DE FILTROS E TOTAL
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Área de Filtros
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: _viewModel.dataSelecionada != null 
                                ? DateFormat('dd/MM/yyyy').format(_viewModel.dataSelecionada!) 
                                : 'Data',
                            icon: Icons.calendar_today,
                            isActive: _viewModel.dataSelecionada != null,
                            onTap: () => _selecionarData(context),
                          ),
                          const SizedBox(width: 8),
                          _buildDropdownFilter(
                            hint: 'Cidade',
                            value: _viewModel.cidadeSelecionada,
                            items: _viewModel.cidadesDisponiveis,
                            onChanged: _viewModel.definirFiltroCidade,
                          ),
                          const SizedBox(width: 8),
                          _buildDropdownFilter(
                            hint: 'Cliente',
                            value: _viewModel.clienteSelecionado,
                            items: _viewModel.clientesDisponiveis,
                            onChanged: _viewModel.definirFiltroCliente,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Resumo Financeiro
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total a receber (Filtrado):", style: TextStyle(color: Colors.orange.shade900, fontSize: 13)),
                                Text(
                                  "R\$ ${_viewModel.totalValesFiltrados.toStringAsFixed(2)}", 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.orange.shade900)
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // LISTAGEM DOS VALES
              Expanded(
                child: _viewModel.isLoading
                    ? Center(child: CircularProgressIndicator(color: corPrimaria))
                    : _viewModel.valesFiltrados.isEmpty
                        ? const Center(child: Text("Nenhum vale encontrado.", style: TextStyle(color: Colors.black54)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _viewModel.valesFiltrados.length,
                            itemBuilder: (context, index) {
                              final vale = _viewModel.valesFiltrados[index];
                              return _buildValeCard(vale);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  // WIDGET: Chip de filtro customizado (usado para a Data)
  Widget _buildFilterChip({required String label, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return ActionChip(
      backgroundColor: isActive ? corPrimaria.withOpacity(0.1) : Colors.white,
      side: BorderSide(color: isActive ? corPrimaria : Colors.grey.shade300),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? corPrimaria : Colors.black54),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: isActive ? corPrimaria : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
      onPressed: onTap,
    );
  }

  // WIDGET: Dropdown customizado para Cidades e Clientes
  Widget _buildDropdownFilter({required String hint, required String? value, required List<String> items, required Function(String?) onChanged}) {
    final bool isActive = value != null && value.isNotEmpty;
    
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? corPrimaria.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? corPrimaria : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.black54, fontSize: 14)),
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: isActive ? corPrimaria : Colors.black54),
          style: TextStyle(color: isActive ? corPrimaria : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 14),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // WIDGET: Card exibindo os detalhes do pedido pendente (Vale)
  Widget _buildValeCard(Map<String, dynamic> vale) {
    final data = vale['criadoEm'] != null ? DateFormat('dd/MM/yyyy HH:mm').format((vale['criadoEm'] as Timestamp).toDate()) : 'N/A';
    final cliente = vale['clienteNome'] ?? 'Cliente Desconhecido';
    final cidade = vale['cidade'] ?? 'Cidade não informada';
    final total = (vale['total'] ?? 0).toDouble();
    final pagamento = vale['pagamento'] ?? 'Vale';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(cliente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(pagamento, style: TextStyle(color: Colors.red.shade900, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(cidade, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(data, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Valor pendente', style: TextStyle(color: Colors.black54, fontSize: 14)),
              Text('R\$ ${total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: corPrimaria)),
            ],
          )
        ],
      ),
    );
  }
}
