
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// O ChangeNotifier permite que a tela reaja ao isLoading (loading da bolinha)
class RegisterViewModel extends ChangeNotifier {
  // Controladores do formulário
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  // Alternar a visualização da senha no olhinho
  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // ==========================================
  // VALIDAÇÃO FORTE DE E-MAIL
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
  // VALIDAÇÃO FORTE DE SENHA
  // ==========================================
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha não pode ser vazia';
    }
    if (value.length < 8) {
      return 'A senha deve ter no mínimo 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }
    if (!value.contains(RegExp(r'[1-9]'))) {
      return 'A senha deve conter pelo menos um número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'A senha deve conter pelo menos um caractere especial (!@#\$%)';
    }
    return null;
  }

  // ==========================================
  // FUNÇÃO DE SALVAR NO FIREBASE
  // ==========================================
  Future<void> cadastrar(BuildContext context) async {
    // 1. Aciona a validação forte. Se falhar, pinta os campos de vermelho e para.
    if (!formKey.currentState!.validate()) {
      return; 
    }

    // 2. Inicia o carregamento na tela
    isLoading = true;
    notifyListeners();

    try {
      // 3. Executa a sua lógica original do Firebase Auth
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 4. Executa a sua lógica original de salvar o usuário no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(result.user!.uid)
          .set({
        'email': result.user!.email,
        'name': nomeController.text.trim(),
      });

      // 5. Sucesso! Mostra a mensagem e volta para a tela de Login
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      }

    } on FirebaseAuthException catch (e) {
      // Trata erros específicos do Firebase (ex: se o e-mail já existir)
      String erroMensagem = 'Erro ao cadastrar.';
      if (e.code == 'email-already-in-use') {
        erroMensagem = 'Este e-mail já está sendo utilizado.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erroMensagem),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Qualquer outro erro genérico
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 6. Tira a tela de carregamento independentemente do resultado
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}