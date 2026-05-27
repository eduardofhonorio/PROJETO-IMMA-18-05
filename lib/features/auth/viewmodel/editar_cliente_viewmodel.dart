import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditarClienteViewModel extends ChangeNotifier {
  final String clienteId;
  final formKey = GlobalKey<FormState>();

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

  EditarClienteViewModel({
    required this.clienteId,
    required Map<String, dynamic> dados,
  }) {
    // Pré-preenche todos os campos com os dados atuais do cliente
    razaoSocialController.text = dados['razaoSocial'] ?? '';
    nomeFantasiaController.text = dados['nomeFantasia'] ?? '';
    documentoController.text = dados['cnpjCpf'] ?? '';
    enderecoController.text = dados['rua'] ?? '';
    cepController.text = dados['cep'] ?? '';
    cidadeController.text = dados['cidade'] ?? '';
    telefoneController.text = dados['telefone'] ?? '';
    emailController.text = dados['email'] ?? '';
    estadoSelecionado = dados['uf'] ?? 'MG';
  }

  void setEstado(String? novoEstado) {
    if (novoEstado != null) {
      estadoSelecionado = novoEstado;
      notifyListeners();
    }
  }

  // ==========================================
  // VALIDADORES (iguais ao de cadastro)
  // ==========================================
  String? campoObrigatorioValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo é obrigatório';
    return null;
  }

  String? cpfCnpjValidator(String? value) {
    if (value == null || value.isEmpty) return 'O CNPJ ou CPF não pode ser vazio';
    final numeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 11 && numeros.length != 14) {
      return 'O documento deve ter 11 dígitos (CPF) ou 14 dígitos (CNPJ)';
    }
    return null;
  }

  String? cepValidator(String? value) {
    if (value == null || value.isEmpty) return 'O CEP não pode ser vazio';
    final numeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 8) return 'O CEP deve conter exatamente 8 números';
    return null;
  }

  String? telefoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'O telefone não pode ser vazio';
    final numeros = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length < 10 || numeros.length > 11) {
      return 'O telefone deve ter 10 ou 11 números (incluindo o DDD)';
    }
    return null;
  }

  // ==========================================
  // SALVAR EDIÇÃO NO FIRESTORE
  // ==========================================
  Future<void> salvarEdicao(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('clientes')
          .doc(clienteId)
          .update({
        'razaoSocial': razaoSocialController.text.trim(),
        'nomeFantasia': nomeFantasiaController.text.trim(),
        'cnpjCpf': documentoController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'rua': enderecoController.text.trim(),
        'cep': cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'cidade': cidadeController.text.trim(),
        'uf': estadoSelecionado,
        'telefone': telefoneController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'email': emailController.text.trim(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cliente atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Volta duas telas: fecha edição e detalhes, retornando à lista
        Navigator.pop(context, true); // true = sinaliza que houve alteração
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
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
