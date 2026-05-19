import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto02/features/auth/viewmodel/cadastrar_cliente_viewmodel.dart';

class CadastrarClientePage extends StatefulWidget {
  const CadastrarClientePage({super.key});

  @override
  State<CadastrarClientePage> createState() => _CadastrarClientePageState();
}

class _CadastrarClientePageState extends State<CadastrarClientePage> {
  final CadastrarClienteViewModel _viewModel = CadastrarClienteViewModel();

  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF9F9F9);
  final Color corBotao = const Color(0xFFB70000);

  final List<String> estados = ['MG', 'SP', 'RJ', 'ES', 'PR', 'SC', 'RS', 'GO', 'MT', 'MS', 'DF'];

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
              "assets/images/logo_IMMA.png",
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
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
                  const Text('Cadastrar Cliente', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  const Text('Preencha os dados abaixo para cadastrar um novo cliente.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 32),

                  _buildSectionHeader(Icons.storefront, 'Dados da empresa', 'Informe os dados principais do seu cliente.'),
                  const SizedBox(height: 16),
                  
                  _buildCustomTextField(
                    label: 'Razão Social', 
                    hint: 'Ex.: Café e Laticínios Bom Sabor Ltda.', 
                    controller: _viewModel.razaoSocialController, 
                    isRequired: true,
                    validator: _viewModel.campoObrigatorioValidator,
                  ),
                  _buildCustomTextField(
                    label: 'Nome Fantasia', 
                    hint: 'Ex.: Bom Sabor', 
                    controller: _viewModel.nomeFantasiaController
                  ),
                  _buildCustomTextField(
                    label: 'CNPJ / CPF', 
                    hint: 'Apenas números (Ex: 12345678000190)', // Dica atualizada
                    controller: _viewModel.documentoController, 
                    isRequired: true, 
                    suffixIcon: Icons.badge_outlined, 
                    keyboardType: TextInputType.number,
                    validator: _viewModel.cpfCnpjValidator, 
                    // LIMITADOR EM TEMPO REAL:
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Bloqueia letras e símbolos
                      LengthLimitingTextInputFormatter(14),   // Trava no máximo em 14 números
                    ],
                  ),
                  
                  const Divider(height: 40, color: Colors.black12),

                  _buildSectionHeader(Icons.location_on_outlined, 'Endereço', 'Informe o endereço completo do cliente.'),
                  const SizedBox(height: 16),
                  
                  _buildCustomTextField(
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
                        child: _buildCustomTextField(
                          label: 'CEP', 
                          hint: 'Apenas números', 
                          controller: _viewModel.cepController, 
                          isRequired: true, 
                          keyboardType: TextInputType.number,
                          validator: _viewModel.cepValidator, 
                          // LIMITADOR EM TEMPO REAL:
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Bloqueia letras
                            LengthLimitingTextInputFormatter(8),    // Trava em exatos 8 números
                          ],
                        )
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2, 
                        child: _buildCustomTextField(
                          label: 'Cidade', 
                          hint: 'Ex.: Itamogi', 
                          controller: _viewModel.cidadeController, 
                          isRequired: true,
                          validator: _viewModel.campoObrigatorioValidator,
                        )
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
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87), 
                                children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white, 
                                borderRadius: BorderRadius.circular(12), 
                                border: Border.all(color: Colors.grey.shade300)
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _viewModel.estadoSelecionado, 
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                                  items: estados.map((String valor) {
                                    return DropdownMenuItem<String>(value: valor, child: Text(valor, style: const TextStyle(fontSize: 14)));
                                  }).toList(),
                                  onChanged: _viewModel.setEstado, 
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), 
                          ],
                        )
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: Colors.black12),

                  _buildSectionHeader(Icons.phone_in_talk_outlined, 'Contato', 'Informe os dados de contato do cliente.'),
                  const SizedBox(height: 16),
                  
                  _buildCustomTextField(
                    label: 'Telefone', 
                    hint: 'DDD + Número (Ex: 35999999999)', 
                    controller: _viewModel.telefoneController, 
                    isRequired: true, 
                    suffixIcon: Icons.chat_outlined, 
                    keyboardType: TextInputType.phone,
                    validator: _viewModel.telefoneValidator, 
                    // LIMITADOR EM TEMPO REAL:
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Bloqueia letras
                      LengthLimitingTextInputFormatter(11),   // Trava no máximo de 11 números
                    ],
                  ),
                  _buildCustomTextField(
                    label: 'E-mail', 
                    hint: 'Ex.: contato@cliente.com.br', 
                    controller: _viewModel.emailController, 
                    suffixIcon: Icons.email_outlined, 
                    keyboardType: TextInputType.emailAddress
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: corBotao, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Campos obrigatórios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                              SizedBox(height: 2),
                              Text('Os campos com * são obrigatórios para o cadastro.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corBotao,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
                        elevation: 4,
                      ),
                      onPressed: _viewModel.isLoading ? null : () async {
                        await _viewModel.cadastrarCliente(context);
                      },
                      child: _viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Finalizar Cadastro', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildSectionHeader(IconData icon, String titulo, String subtitulo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Color(0xFFFFF5F5), borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Icon(icon, color: const Color(0xFFB70000), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(subtitulo, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    IconData? suffixIcon,
    Widget? suffixWidget,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator, 
    List<TextInputFormatter>? inputFormatters, // <-- NOVA PROPRIEDADE AQUI
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
              children: [
                if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters, // <-- CONECTADA AO FLUTTER AQUI
            validator: validator ?? (isRequired ? (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório' : null : null),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: corBotao, width: 2)),
              suffixIcon: suffixWidget ?? (suffixIcon != null ? Icon(suffixIcon, color: Colors.black45) : null),
            ),
          ),
        ],
      ),
    );
  }
}