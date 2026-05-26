import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClienteDetalhesPage extends StatelessWidget {
  // A tela precisa apenas receber o ID do cliente clicado
  final String clienteId;

  const ClienteDetalhesPage({super.key, required this.clienteId});

  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF9F9F9);
  final Color corBotao = const Color(0xFFB70000);

  // Função para excluir o cliente com caixa de confirmação
  void _excluirCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Fecha o dialog
              
              // Exclui do Firebase
              await FirebaseFirestore.instance.collection('clientes').doc(clienteId).delete();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cliente excluído com sucesso!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context); // Fecha a tela de detalhes e volta pra lista
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: AppBar(
        backgroundColor: corPrimaria,
        title: const Text('Detalhes do Cliente', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      // O StreamBuilder escuta apenas este documento. Se for editado, atualiza a tela na hora!
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('clientes').doc(clienteId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Cliente não encontrado ou excluído.'));
          }

          // Extrai os dados do Firebase
          var cliente = snapshot.data!.data() as Map<String, dynamic>;
          cliente['id'] = snapshot.data!.id; // Adiciona o ID para passar para a edição

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === CARD PRINCIPAL (Nome e Documento) ===
                Container(
                  padding: const EdgeInsets.all(20),
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
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFFFBEAEA), borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.storefront, color: corBotao, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cliente['nomeFantasia'] ?? cliente['razaoSocial'] ?? 'Sem Nome',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'CNPJ/CPF: ${cliente['cnpj'] ?? cliente['cpf'] ?? 'Não informado'}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                      
                      // === DADOS DE CONTATO ===
                      const Text('Contato', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 20, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(cliente['telefone'] ?? 'Não informado', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 20, color: Colors.black54),
                          const SizedBox(width: 8),
                          Text(cliente['email'] ?? 'Não informado', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                        ],
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                      
                      // === ENDEREÇO ===
                      const Text('Endereço Completo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 20, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${cliente['rua'] ?? ''}, ${cliente['numero'] ?? 'S/N'}\n'
                              '${cliente['bairro'] ?? ''}\n'
                              '${cliente['cidade'] ?? ''} - ${cliente['uf'] ?? ''}\n'
                              'CEP: ${cliente['cep'] ?? ''}',
                              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // === BOTOES DE AÇÃO (Excluir e Editar) ===
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('Excluir', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () => _excluirCliente(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corBotao,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text('Editar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          // TODO: Descomente e passe o cliente para a tela de Cadastro/Edição
                          /*
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CadastrarClientePage(
                                clienteExistente: cliente, // Manda o cliente para editar
                              ),
                            ),
                          );
                          */
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}