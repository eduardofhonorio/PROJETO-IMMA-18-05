import 'package:flutter_test/flutter_test.dart';
import 'package:projeto02/features/auth/viewmodel/register_viewmodel.dart';

void main() {
  group('Testes de Validação - RegisterViewModel (Camadas de Segurança)', () {
    late RegisterViewModel viewModel;

    // O setUp roda antes de CADA teste, garantindo um ViewModel "limpo"
    setUp(() {
      viewModel = RegisterViewModel();
    });

    test('TC02 - Validação de Campos Vazios', () {
      // Verifica se o sistema barra e-mail e senha em branco
      expect(viewModel.emailValidator(''), 'O e-mail não pode ser vazio');
      expect(viewModel.passwordValidator(''), 'A senha não pode ser vazia');
    });

    test('TC03 - Validação Forte de E-mail (Correção do Relatório de Teste)', () {
      // 1. Falha: E-mail sem domínio (O erro que constava no Documento 07)
      expect(
        viewModel.emailValidator('vendedor@imma'), 
        'Digite um e-mail válido com domínio (ex: vendedor@imma.com)'
      );

      // 2. Falha: E-mail sem o @
      expect(
        viewModel.emailValidator('vendedor.imma.com'), 
        'Digite um e-mail válido com domínio (ex: vendedor@imma.com)'
      );

      // 3. Sucesso: E-mail perfeitamente formatado (Deve retornar null)
      expect(viewModel.emailValidator('vendedor@imma.com.br'), isNull);
    });

    test('TC10 - Validação de Senha Forte (Novo Cenário de Segurança)', () {
      // 1. Falha: Menos de 8 caracteres
      expect(
        viewModel.passwordValidator('Senha1!'), 
        'A senha deve ter no mínimo 8 caracteres'
      );

      // 2. Falha: Sem letra maiúscula
      expect(
        viewModel.passwordValidator('senha123!'), 
        'A senha deve conter pelo menos uma letra maiúscula'
      );

      // 3. Falha: Sem letra minúscula
      expect(
        viewModel.passwordValidator('SENHA123!'), 
        'A senha deve conter pelo menos uma letra minúscula'
      );

      // 4. Falha: Sem números
      expect(
        viewModel.passwordValidator('SenhaForte!'), 
        'A senha deve conter pelo menos um número'
      );

      // 5. Falha: Sem caractere especial
      expect(
        viewModel.passwordValidator('Senha1234'), 
        'A senha deve conter pelo menos um caractere especial (!@#\$%)'
      );

      // 6. Sucesso: Senha que atende a TODOS os critérios (Deve retornar null)
      expect(viewModel.passwordValidator('Senha@123'), isNull);
    });
  });
}