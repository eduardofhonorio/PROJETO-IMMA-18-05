import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginViewmodel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  bool obscurePassword = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }
  
  // ==========================================
  // VALIDAÇÃO DE E-MAIL (Igual ao do Cadastro)
  // ==========================================
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail não pode ser vazio';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Digite um e-mail válido com domínio (ex: vendedor@imma.com)';
    }
    return null;
  }

  // ==========================================
  // VALIDAÇÃO BÁSICA DE SENHA PARA O LOGIN
  // ==========================================
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha não pode ser vazia'; // É este texto que faz o teste isNotNull passar!
    }
    return null;
  }

  Future<bool> fazerLogin(String email, String senha) async {
    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );
      
      isLoading = false;
      notifyListeners();
      return true; 
      
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      print("Erro no Firebase: ${e.message}");
      return false;
    }
  }
  
}