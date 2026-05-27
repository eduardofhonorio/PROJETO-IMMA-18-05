import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto02/features/auth/view/editar_cliente_page.dart';

class DetalhesClientePage extends StatelessWidget {
  final String clienteId;
  final Map<String, dynamic> clienteData;

  const DetalhesClientePage({
    super.key,
    required this.clienteId,
    required this.clienteData,
  });

  static const Color corPrimaria = Color(0xFF480404);
  static const Color corBotao = Color(0xFFB70000);
  static const Color corFundo = Color(0xFFF9F9F9);

  String get _nomeExibicao =>
      (clienteData['nomeFantasia']?.toString().isNotEmpty == true)
          ? clienteData['nomeFantasia']
          : clienteData['razaoSocial'] ?? 'Sem nome';

  // ==========================================
  // EXCLUIR CLIENTE
  // ==========================================
  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Excluir cliente',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            children: [
              const TextSpan(text: 'Tem certeza que deseja excluir '),
              TextSpan(
                text: _nomeExibicao,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                  text: '? Esta ação não pode ser desfeita.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('clientes')
            .doc(clienteId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente excluído com sucesso.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // volta à lista sinalizando mudança
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cnpj = clienteData['cnpjCpf'] ?? 'Não informado';
    final rua = clienteData['rua'] ?? '';
    final cidade = clienteData['cidade'] ?? '';
    final uf = clienteData['uf'] ?? '';
    final cep = clienteData['cep'] ?? '';
    final telefone = clienteData['telefone'] ?? 'Não informado';
    final email = clienteData['email'] ?? 'Não informado';
    final pedidos = clienteData['pedidos']?.toString() ?? '0';
    final status = clienteData['status'] ?? 'Ativo';

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
          'assets/images/logo_IMMA.png',
          height: 40,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.local_shipping, size: 36, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABEÇALHO DO CLIENTE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                        color: Color(0xFFFFF5F5), shape: BoxShape.circle),
                    child:
                        const Icon(Icons.storefront, color: corBotao, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nomeExibicao,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        if ((clienteData['razaoSocial'] ?? '').isNotEmpty &&
                            clienteData['nomeFantasia'] != clienteData['razaoSocial'])
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              clienteData['razaoSocial'] ?? '',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // MÉTRICAS RÁPIDAS
            Row(
              children: [
                _buildMetricaCard(
                    Icons.receipt_long_outlined, '$pedidos', 'Pedidos feitos'),
                const SizedBox(width: 12),
                _buildMetricaCard(
                    Icons.location_city_outlined,
                    cidade.isNotEmpty ? cidade : '—',
                    'Cidade'),
              ],
            ),
            const SizedBox(height: 24),

            // DADOS DA EMPRESA
            _buildSecao(
              titulo: 'Dados da empresa',
              icone: Icons.business_outlined,
              itens: [
                _buildInfoRow(Icons.badge_outlined, 'CNPJ / CPF', cnpj),
              ],
            ),
            const SizedBox(height: 16),

            // ENDEREÇO
            _buildSecao(
              titulo: 'Endereço',
              icone: Icons.location_on_outlined,
              itens: [
                if (rua.isNotEmpty)
                  _buildInfoRow(Icons.map_outlined, 'Logradouro', rua),
                if (cep.isNotEmpty)
                  _buildInfoRow(Icons.markunread_mailbox_outlined, 'CEP', cep),
                if (cidade.isNotEmpty)
                  _buildInfoRow(
                      Icons.location_city_outlined, 'Cidade / UF', '$cidade - $uf'),
              ],
            ),
            const SizedBox(height: 16),

            // CONTATO
            _buildSecao(
              titulo: 'Contato',
              icone: Icons.phone_in_talk_outlined,
              itens: [
                _buildInfoRow(Icons.phone_outlined, 'Telefone', telefone),
                _buildInfoRow(Icons.email_outlined, 'E-mail', email),
              ],
            ),
            const SizedBox(height: 40),

            // BOTÕES DE AÇÃO
            Row(
              children: [
                // EXCLUIR
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _confirmarExclusao(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                // EDITAR
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corBotao,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      // Abre a tela de edição e aguarda o retorno
                      final alterado = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditarClientePage(
                            clienteId: clienteId,
                            clienteData: clienteData,
                          ),
                        ),
                      );
                      // Se salvou com sucesso, fecha os detalhes também
                      if (alterado == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar cliente',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
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

  // ==========================================
  // WIDGETS AUXILIARES
  // ==========================================
  Widget _buildMetricaCard(IconData icon, String valor, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xFFFFF5F5), shape: BoxShape.circle),
              child: Icon(icon, color: corBotao, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(valor,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87),
                      overflow: TextOverflow.ellipsis),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecao({
    required String titulo,
    required IconData icone,
    required List<Widget> itens,
  }) {
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
          ...itens,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black45, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black45)),
                const SizedBox(height: 2),
                Text(
                  valor.isNotEmpty ? valor : 'Não informado',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
