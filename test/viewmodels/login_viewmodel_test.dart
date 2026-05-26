import 'package:flutter_test/flutter_test.dart';
import 'package:projeto02/features/auth/viewmodel/login_viewmodel.dart';

void main() {
  group('Testes de Lógica e Validação - LoginViewmodel', () {
    late LoginViewmodel viewModel;

    // O setUp prepara um ViewModel novo antes de cada teste
    setUp(() {
      viewModel = LoginViewmodel();
    });

    test('TC07 - Login Vazio (Campos Obrigatórios)', () {
      // Verifica se o sistema barra a tentativa de login sem preencher e-mail e senha
      // O "isNotNull" significa que esperamos que a função retorne uma mensagem de erro (qualquer String)
      expect(viewModel.emailValidator(''), isNotNull);
      expect(viewModel.passwordValidator(''), isNotNull);
    });

    test('TC03 - Validação de Formato de E-mail no Login', () {
      // Garante que a mesma falha do Documento 07 não ocorra na tela de Login
      // 1. Falha: E-mail sem domínio
      expect(viewModel.emailValidator('vendedor@imma'), isNotNull);
      
      // 2. Sucesso: E-mail formatado corretamente (Deve retornar null)
      expect(viewModel.emailValidator('vendedor@imma.com.br'), isNull);
    });

    test('Teste de Interação - Alternar Visibilidade da Senha (Olhinho)', () {
      // 1. A senha deve começar oculta (true) por padrão de segurança
      expect(viewModel.obscurePassword, true);

      // 2. Simula o usuário clicando no ícone de "olhinho" na tela de login
      viewModel.togglePasswordVisibility();

      // 3. A propriedade deve mudar para false (senha visível)
      expect(viewModel.obscurePassword, false);
    });

    test('Teste de Estado - Loading Inicial', () {
      // Garante que o botão de "ENTRAR" não comece bloqueado ou girando a bolinha ao abrir a tela
      expect(viewModel.isLoading, false);
    });
  });
}