import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastrarClienteViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  // Controladores
  final razaoSocialController = TextEditingController();
  final nomeFantasiaController = TextEditingController();
  final documentoController = TextEditingController(); 
  final enderecoController = TextEditingController();
  final cepController = TextEditingController();
  final cidadeController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();

  String estadoSelecionado = 'MG'; 
  bool isLoading = false;

  void setEstado(String? novoEstado) {
    if (novoEstado != null) {
      estadoSelecionado = novoEstado;
      notifyListeners();
    }
  }

  // ==========================================
  // VALIDADORES GERAIS
  // ==========================================
  String? campoObrigatorioValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  // ==========================================
  // VALIDAÇÕES ESPECÍFICAS
  // ==========================================
  String? cpfCnpjValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CNPJ ou CPF não pode ser vazio';
    }
    String numeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 11 && numeros.length != 14) {
      return 'O documento deve ter 11 dígitos (CPF) ou 14 dígitos (CNPJ)';
    }
    return null;
  }

  String? cepValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP não pode ser vazio';
    }
    String numeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 8) {
      return 'O CEP deve conter exatamente 8 números';
    }
    return null;
  }

  String? telefoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'O telefone não pode ser vazio';
    }
    String numeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length < 10 || numeros.length > 11) {
      return 'O telefone deve ter 10 ou 11 números (incluindo o DDD)';
    }
    return null;
  }

  // ==========================================
  // AÇÃO DE SALVAR NO FIREBASE
  // ==========================================
  Future<void> cadastrarCliente(BuildContext context) async {
    // 1. Roda todas as validações dos TextFormFields
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // 2. Verifica se o vendedor está logado no Firebase Auth
      final String? vendedorId = FirebaseAuth.instance.currentUser?.uid;
      if (vendedorId == null) throw Exception("Vendedor não autenticado.");

      // 3. Salva os dados limpos no Cloud Firestore
      await FirebaseFirestore.instance.collection('clientes').add({
        'vendedorId': vendedorId,
        'razaoSocial': razaoSocialController.text.trim(),
        'nomeFantasia': nomeFantasiaController.text.trim(),
        // Limpa a máscara do documento antes de salvar no banco para facilitar futuras buscas!
        'cnpjCpf': documentoController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'rua': enderecoController.text.trim(),
        // Limpa a máscara do CEP
        'cep': cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'cidade': cidadeController.text.trim(),
        'uf': estadoSelecionado,
        // Limpa a máscara do telefone
        'telefone': telefoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'email': emailController.text.trim(),
        'pedidos': 0, 
        'status': 'Ativo', 
        'criadoEm': FieldValue.serverTimestamp(),
      });

      // 4. Feedback e navegação
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para a lista de clientes
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    } finally {
      // 5. Finaliza o carregamento
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    razaoSocialController.dispose();
    nomeFantasiaController.dispose();
    documentoController.dispose();
    enderecoController.dispose();
    cepController.dispose();
    cidadeController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}