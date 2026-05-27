import 'package:flutter/material.dart';
import 'package:projeto02/features/auth/viewmodel/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegisterViewModel _viewModel = RegisterViewModel();

  static const Color corPrimaria = Color(0xFF480404);
  static const Color corBotao   = Color(0xFFB70000);
  static const Color corFundo   = Color(0xFFFFF9F0);

  int _calcularForca(String senha) {
    if (senha.isEmpty) return 0;
    int s = 0;
    if (senha.length >= 8) s++;
    if (senha.contains(RegExp(r'[A-Z]'))) s++;
    if (senha.contains(RegExp(r'[0-9]'))) s++;
    if (senha.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) s++;
    return s;
  }

  Color _corForca(int f) {
    if (f <= 1) return Colors.red;
    if (f == 2) return Colors.orange;
    if (f == 3) return Colors.amber;
    return Colors.green;
  }

  String _labelForca(int f) {
    const labels = ['', 'Fraca', 'Regular', 'Boa', 'Forte'];
    return f < labels.length ? labels[f] : '';
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final forca = _calcularForca(_viewModel.passwordController.text);

        return Scaffold(
          // StackFit.expand garante que o Stack preenche a tela inteira
          body: Stack(
            fit: StackFit.expand,
            children: [

              // ── 1. FUNDO CREME (base de tudo) ──────────────────
              Container(color: corFundo),

              // ── 2. HEADER GRADIENTE (topo) ──────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                height: h * 0.40,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF480404), Color(0xFF8B0000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          // Botão voltar
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const Spacer(),
                          // Logo + título
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo_IMMA.png',
                                height: 150,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.local_shipping,
                                    size: 100,
                                    color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Criar conta',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5)),
                                  Text('IMMA Atacadista',
                                      style: TextStyle(
                                          color: Color.fromARGB(153, 255, 255, 255),
                                          fontSize: 20)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── 3. CARD BRANCO DO FORMULÁRIO ───────────────────
              Positioned(
                top: h * 0.35,
                left: 0, right: 0, bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: corFundo,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.fromLTRB(28, 32, 28, 40),
                    child: Form(
                      key: _viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preencha seus dados',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const SizedBox(height: 4),
                          const Text('Todos os campos são obrigatórios.',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black45)),
                          const SizedBox(height: 28),

                          // NOME
                          _label('Nome completo'),
                          const SizedBox(height: 8),
                          _campo(
                            controller: _viewModel.nomeController,
                            hint: 'Ex.: João Silva',
                            icone: Icons.person_outline_rounded,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Informe o nome'
                                : null,
                          ),
                          const SizedBox(height: 20),

                          // E-MAIL
                          _label('E-mail'),
                          const SizedBox(height: 8),
                          _campo(
                            controller: _viewModel.emailController,
                            hint: 'seu@email.com',
                            icone: Icons.mail_outline_rounded,
                            teclado: TextInputType.emailAddress,
                            validator: _viewModel.emailValidator,
                          ),
                          const SizedBox(height: 20),

                          // SENHA
                          _label('Senha'),
                          const SizedBox(height: 8),
                          _campo(
                            controller: _viewModel.passwordController,
                            hint: 'Mínimo 8 caracteres',
                            icone: Icons.lock_outline_rounded,
                            obscuro: _viewModel.obscurePassword,
                            sufixo: IconButton(
                              icon: Icon(
                                _viewModel.obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black45,
                                size: 22,
                              ),
                              onPressed:
                                  _viewModel.togglePasswordVisibility,
                            ),
                            validator: _viewModel.passwordValidator,
                            aoMudar: (_) => setState(() {}),
                          ),

                          // Barra de força da senha
                          if (_viewModel
                              .passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ...List.generate(4, (i) => Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: i < forca
                                          ? _corForca(forca)
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                )),
                                const SizedBox(width: 8),
                                Text(_labelForca(forca),
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _corForca(forca))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Use letras maiúsculas, números e símbolos.',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.black38),
                            ),
                          ],

                          const SizedBox(height: 40),

                          // BOTÃO
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: corBotao,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor: corBotao.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16)),
                              ),
                              onPressed: _viewModel.isLoading
                                  ? null
                                  : () async =>
                                      await _viewModel.cadastrar(context),
                              child: _viewModel.isLoading
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5))
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            size: 22),
                                        SizedBox(width: 10),
                                        Text('Criar minha conta',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3)),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Link voltar ao login
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Já tem uma conta? ',
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 14),
                                  children: [
                                    TextSpan(
                                      text: 'Entrar',
                                      style: TextStyle(
                                          color: corBotao,
                                          fontWeight: FontWeight.bold,
                                          decoration:
                                              TextDecoration.underline),
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String texto) => Text(
        texto,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87),
      );

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icone,
    TextInputType teclado = TextInputType.text,
    bool obscuro = false,
    Widget? sufixo,
    String? Function(String?)? validator,
    void Function(String)? aoMudar,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      obscureText: obscuro,
      validator: validator,
      onChanged: aoMudar,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(fontSize: 14, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(icone, color: corPrimaria, size: 22),
        ),
        suffixIcon: sufixo,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: corPrimaria, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Colors.redAccent, width: 2)),
      ),
    );
  }
}