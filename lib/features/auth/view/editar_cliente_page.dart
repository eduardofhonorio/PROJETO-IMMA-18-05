import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto02/features/auth/viewmodel/editar_cliente_viewmodel.dart';

class EditarClientePage extends StatefulWidget {
  final String clienteId;
  final Map<String, dynamic> clienteData;

  const EditarClientePage({
    super.key,
    required this.clienteId,
    required this.clienteData,
  });

  @override
  State<EditarClientePage> createState() => _EditarClientePageState();
}

class _EditarClientePageState extends State<EditarClientePage> {
  late final EditarClienteViewModel _viewModel;

  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF9F9F9);
  final Color corBotao = const Color(0xFFB70000);

  final List<String> estados = [
    'MG', 'SP', 'RJ', 'ES', 'PR', 'SC', 'RS',
    'GO', 'MT', 'MS', 'DF', 'BA', 'PE', 'CE', 'PA',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = EditarClienteViewModel(
      clienteId: widget.clienteId,
      dados: widget.clienteData,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Cliente',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Atualize os dados do cliente abaixo.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),

                  // DADOS DA EMPRESA
                  _buildSectionHeader(
                      Icons.storefront, 'Dados da empresa', 'Informações principais do cliente.'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Razão Social',
                    hint: 'Ex.: Café e Laticínios Bom Sabor Ltda.',
                    controller: _viewModel.razaoSocialController,
                    isRequired: true,
                    validator: _viewModel.campoObrigatorioValidator,
                  ),
                  _buildTextField(
                    label: 'Nome Fantasia',
                    hint: 'Ex.: Bom Sabor',
                    controller: _viewModel.nomeFantasiaController,
                  ),
                  _buildTextField(
                    label: 'CNPJ / CPF',
                    hint: 'Apenas números',
                    controller: _viewModel.documentoController,
                    isRequired: true,
                    keyboardType: TextInputType.number,
                    validator: _viewModel.cpfCnpjValidator,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(14),
                    ],
                  ),

                  const Divider(height: 40, color: Colors.black12),

                  // ENDEREÇO
                  _buildSectionHeader(
                      Icons.location_on_outlined, 'Endereço', 'Endereço completo do cliente.'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Endereço Completo',
                    hint: 'Ex.: Rua das Flores, 123 - Centro',
                    controller: _viewModel.enderecoController,
                    isRequired: true,
                    validator: _viewModel.campoObrigatorioValidator,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          label: 'CEP',
                          hint: 'Apenas números',
                          controller: _viewModel.cepController,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          validator: _viewModel.cepValidator,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          label: 'Cidade',
                          hint: 'Ex.: Itamogi',
                          controller: _viewModel.cidadeController,
                          isRequired: true,
                          validator: _viewModel.campoObrigatorioValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Estado',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                                children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red))
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _viewModel.estadoSelecionado,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black54),
                                  items: estados.map((String valor) {
                                    return DropdownMenuItem<String>(
                                      value: valor,
                                      child: Text(valor,
                                          style: const TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                  onChanged: _viewModel.setEstado,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: Colors.black12),

                  // CONTATO
                  _buildSectionHeader(
                      Icons.phone_in_talk_outlined, 'Contato', 'Dados de contato do cliente.'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Telefone',
                    hint: 'DDD + Número',
                    controller: _viewModel.telefoneController,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    validator: _viewModel.telefoneValidator,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  _buildTextField(
                    label: 'E-mail',
                    hint: 'Ex.: contato@cliente.com.br',
                    controller: _viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 40),

                  // BOTÃO SALVAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corBotao,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      onPressed: _viewModel.isLoading
                          ? null
                          : () => _viewModel.salvarEdicao(context),
                      child: _viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Salvar Alterações',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String titulo, String subtitulo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
              color: Color(0xFFFFF5F5),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Icon(icon, color: const Color(0xFFB70000), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              Text(subtitulo,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              children: [
                if (isRequired)
                  const TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator ??
                (isRequired
                    ? (value) => value == null || value.trim().isEmpty
                        ? 'Campo obrigatório'
                        : null
                    : null),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(fontSize: 14, color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFB70000), width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
