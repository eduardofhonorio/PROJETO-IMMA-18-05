import 'package:flutter/material.dart';
import 'package:projeto02/app/routes/app_routes.dart';
import 'package:projeto02/features/auth/viewmodel/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewmodel viewModel;
  
  final Color corPrimaria = const Color(0xFF480404); // Bordô escuro
  final Color corBotao = const Color(0xFFB70000); // Vermelho IMMA
  final Color corFundo = const Color(0xFFF9F9F9); // Off-white
  bool _lembrarAcesso = false; // Controle do checkbox visual

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewmodel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (_, __) {
        return Scaffold( // O Scaffold tem o body
          body: Container( // O Container entra no body do Scaffold
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 59, 1, 1), // Bordô super escuro no topo
                  Color(0xFF480404), // Nossa cor primária no meio
                  Color.fromARGB(255, 255, 0, 0), // Vermelho um pouco mais vivo embaixo
                ],
              ),
            ),
            // AQUI ESTÁ O SEGREDO: O Container usa 'child:' e não 'body:'!
            child: SingleChildScrollView( 
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // ==========================================
                    // CABEÇALHO (LOGO E TEXTOS)
                    // ==========================================
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/logo_IMMA.png",
                              height: 225,
                              errorBuilder: (_, __, ___) => const Icon(Icons.local_shipping, size: 80, color: Colors.white),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "BEM-VINDO!",
                              style: TextStyle(
                                color: Color.fromARGB(255, 250, 1, 1), 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 1.2
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Acesso do Vendedor",
                              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Faça login para acessar o sistema\ne gerenciar suas atividades.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ==========================================
                    // PAINEL INFERIOR (FORMULÁRIO CARD)
                    // ==========================================
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: viewModel.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- CAMPO USUÁRIO ---
                              _buildCustomField(
                                controller: viewModel.emailController,
                                label: "Usuário",
                                hint: "Informe seu usuário",
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => (value == null || value.isEmpty) ? 'Informe seu usuário ou e-mail' : null,
                              ),
                              const SizedBox(height: 16),

                              // --- CAMPO SENHA ---
                              _buildCustomField(
                                controller: viewModel.passwordController,
                                label: "Senha",
                                hint: "Digite sua senha",
                                icon: Icons.lock_outline,
                                obscureText: viewModel.obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                                  onPressed: viewModel.togglePasswordVisibility,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Informe sua senha';
                                  if (value.length < 6) return 'Mínimo de 6 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // --- LEMBRAR ACESSO & ESQUECI A SENHA ---
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _lembrarAcesso,
                                      activeColor: corBotao,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      onChanged: (val) => setState(() => _lembrarAcesso = val ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("Lembrar meu acesso", style: TextStyle(fontSize: 13, color: Colors.black87)),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      "Esqueci minha senha",
                                      style: TextStyle(fontSize: 13, color: corBotao, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // --- BOTÃO ENTRAR ---
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: corPrimaria,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 2,
                                  ),
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : () async {
                                          if (viewModel.formKey.currentState!.validate()) {
                                            bool sucesso = await viewModel.fazerLogin(
                                              viewModel.emailController.text,
                                              viewModel.passwordController.text,
                                            );

                                            if (sucesso && context.mounted) {
                                              Navigator.pushReplacementNamed(context, AppRoutes.home);
                                            } else if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('E-mail ou senha inválidos!'), backgroundColor: Colors.redAccent),
                                              );
                                            }
                                          }
                                        },
                                  child: viewModel.isLoading
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Spacer(),
                                            Text("ENTRAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                            Spacer(),
                                            Icon(Icons.arrow_forward, color: Colors.white),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // --- DIVIDER "OU" ---
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text("ou", style: TextStyle(color: Colors.black54, fontSize: 14)),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // --- BOTÃO CADASTRE-SE ---
                              SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_outline, color: corBotao),
                                      const SizedBox(width: 8),
                                      RichText(
                                        text: TextSpan(
                                          text: "Ainda não tem conta? ",
                                          style: const TextStyle(color: Colors.black87, fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: "Cadastre-se",
                                              style: TextStyle(color: corPrimaria, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const Spacer(), // Empurra os elementos pro topo e o footer pro chão

                              // --- FOOTER SEGURANÇA ---
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.shield_outlined, color: corBotao, size: 24),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Acesso seguro e exclusivo para vendedores\n",
                                          style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
                                          children: [
                                            const TextSpan(text: "da "),
                                            TextSpan(text: "IMMA Atacadista.", style: TextStyle(fontWeight: FontWeight.bold, color: corPrimaria)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          )
        );
      },
    );
  }

  // === WIDGET AUXILIAR PARA OS CAMPOS DE TEXTO ===
  // Constrói os campos no exato estilo de "pílula dupla" com o ícone colorido ao lado
  Widget _buildCustomField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always, // Mantém o "Usuário" em cima e o "Informe..." embaixo
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFBEAEA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: corBotao, size: 20),
          ),
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: corPrimaria, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}