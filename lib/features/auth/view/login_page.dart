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
  
  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFFFF9F0); 

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewmodel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (_, __) {
        return Scaffold(
          backgroundColor: corFundo, 
          body: Stack(
            children: [
              ClipPath(
                clipper: LoginDiagonalClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75, 
                  color: corPrimaria,
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 32, right: 32, top: 10, bottom: 24),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              "assets/images/logo_IMMA.png",
                              height: 130,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.local_shipping, size: 100, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          const Text(
                            "Acesso do\nVendedor",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          
                          const SizedBox(height: 50), 
                          
                          TextFormField(
                            controller: viewModel.emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe seu usuário ou e-mail';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Usuário",
                              hintStyle: const TextStyle(fontSize: 18, color: Colors.black54),
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
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Campo de Senha
                          TextFormField(
                            controller: viewModel.passwordController,
                            obscureText: viewModel.obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, informe sua senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Senha",
                              hintStyle: const TextStyle(fontSize: 18, color: Colors.black54),
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
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  onPressed: viewModel.togglePasswordVisibility,
                                  icon: Icon(
                                    viewModel.obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: corPrimaria,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          
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
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      if (viewModel.formKey.currentState!.validate()) {                                  
                                        bool sucesso = await viewModel.fazerLogin(
                                          viewModel.emailController.text,
                                          viewModel.passwordController.text,
                                        );
                                        

                                        if (sucesso) {
                                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('E-mail ou senha inválidos!'),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : const Text(
                                      "ENTRAR", 
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Não tem conta?", style: TextStyle(color: Colors.black87)),
                              TextButton(
                                style: TextButton.styleFrom(foregroundColor: corPrimaria),
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRoutes.register);
                                },
                                child: const Text(
                                  "Cadastre-se",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
}

class LoginDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.68); 
    path.lineTo(size.width, size.height * 0.40); 
    path.lineTo(size.width, 0); 
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}