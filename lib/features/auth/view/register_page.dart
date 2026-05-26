import 'package:flutter/material.dart';
import 'package:projeto02/features/auth/viewmodel/register_viewmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Inicializamos APENAS o ViewModel. Ele gerencia todo o resto!
  final RegisterViewModel _viewModel = RegisterViewModel();

  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFFFF9F0);

  @override
  void dispose() {
    // Boa prática: limpar o ViewModel da memória ao fechar a tela
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O AnimatedBuilder faz a tela reagir sozinha ao isLoading do ViewModel
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: corFundo,
          appBar: AppBar(
            backgroundColor: corPrimaria,
            title: const Text(
              'Criar Conta',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Form(
                // 1. Usando a chave do formulário que está no ViewModel
                key: _viewModel.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 70,
                      color: corPrimaria,
                    ),
                    const SizedBox(height: 40),

                    // CAMPO NOME
                    TextFormField(
                      controller: _viewModel.nomeController, // Controller do ViewModel
                      decoration: InputDecoration(
                        hintText: 'Nome Completo',
                        hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 2.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 3.5),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                          child: Icon(Icons.person_outline, color: corPrimaria),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 20),

                    // CAMPO E-MAIL
                    TextFormField(
                      controller: _viewModel.emailController, // Controller do ViewModel
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 2.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 3.5),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                          child: Icon(Icons.email_outlined, color: corPrimaria),
                        ),
                      ),
                      // 2. Validador Forte de E-mail do ViewModel!
                      validator: _viewModel.emailValidator, 
                    ),
                    const SizedBox(height: 20),

                    // CAMPO SENHA
                    TextFormField(
                      controller: _viewModel.passwordController, // Controller do ViewModel
                      obscureText: _viewModel.obscurePassword,   // Esconde/mostra a senha
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 2.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 2.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: corPrimaria, width: 3.5),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                          child: Icon(Icons.lock_outlined, color: corPrimaria),
                        ),
                        // 3. Olhinho da Senha interativo
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: IconButton(
                            icon: Icon(
                              _viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: corPrimaria,
                            ),
                            onPressed: _viewModel.togglePasswordVisibility,
                          ),
                        ),
                      ),
                      // 4. Validador Forte de Senha do ViewModel!
                      validator: _viewModel.passwordValidator, 
                    ),
                    const SizedBox(height: 40),

                    // BOTÃO FINALIZAR CADASTRO
                    SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corPrimaria,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        // 5. Ação acionada direto no ViewModel
                        onPressed: _viewModel.isLoading 
                            ? null 
                            : () async {
                                await _viewModel.cadastrar(context);
                              },
                        // 6. Troca o texto pela bolinha automaticamente
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text(
                                'SALVAR CADASTRO',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}