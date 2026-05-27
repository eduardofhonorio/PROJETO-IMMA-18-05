// test/viewmodels/validators_test.dart
//
// Testes de unidade para os validadores de formulário.
// Cobre: LoginViewmodel, RegisterViewModel, CadastrarClienteViewModel.
// Técnicas aplicadas (ISO/IEC/IEEE 29119):
//   - Particionamento de Equivalência
//   - Análise de Valor Limite
//
// Execução: flutter test test/viewmodels/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:projeto02/features/auth/viewmodel/login_viewmodel.dart';
import 'package:projeto02/features/auth/viewmodel/register_viewmodel.dart';
import 'package:projeto02/features/auth/viewmodel/cadastrar_cliente_viewmodel.dart';

void main() {
  // ============================================================
  // LoginViewmodel — emailValidator
  // ============================================================
  group('LoginViewmodel — emailValidator', () {
    late LoginViewmodel sut;

    setUp(() => sut = LoginViewmodel());
    tearDown(() => sut.dispose());

    test('null retorna mensagem de erro', () {
      expect(sut.emailValidator(null), isNotNull);
    });

    test('string vazia retorna mensagem de erro', () {
      expect(sut.emailValidator(''), isNotNull);
    });

    test('email sem domínio retorna mensagem de erro', () {
      expect(sut.emailValidator('vendedor'), isNotNull);
    });

    test('email sem TLD retorna mensagem de erro', () {
      expect(sut.emailValidator('vendedor@imma'), isNotNull);
    });

    test('email válido retorna null', () {
      expect(sut.emailValidator('vendedor@imma.com'), isNull);
    });

    test('email válido com subdomínio retorna null', () {
      expect(sut.emailValidator('v@imma.com.br'), isNull);
    });
  });

  // ============================================================
  // LoginViewmodel — passwordValidator
  // ============================================================
  group('LoginViewmodel — passwordValidator', () {
    late LoginViewmodel sut;

    setUp(() => sut = LoginViewmodel());
    tearDown(() => sut.dispose());

    test('null retorna mensagem de erro', () {
      expect(sut.passwordValidator(null), isNotNull);
    });

    test('string vazia retorna mensagem de erro', () {
      expect(sut.passwordValidator(''), isNotNull);
    });

    test('senha preenchida retorna null', () {
      expect(sut.passwordValidator('qualquersenha'), isNull);
    });
  });

  // ============================================================
  // RegisterViewModel — passwordValidator (validação forte)
  // ============================================================
  group('RegisterViewModel — passwordValidator', () {
    late RegisterViewModel sut;

    setUp(() => sut = RegisterViewModel());
    tearDown(() => sut.dispose());

    test('null retorna erro', () {
      expect(sut.passwordValidator(null), isNotNull);
    });

    test('string vazia retorna erro', () {
      expect(sut.passwordValidator(''), isNotNull);
    });

    test('menos de 8 caracteres retorna erro (valor limite: 7)', () {
      expect(sut.passwordValidator('Abc1!ab'), isNotNull);
    });

    test('exatamente 8 caracteres mas sem maiúscula retorna erro', () {
      expect(sut.passwordValidator('abc1!def'), isNotNull);
    });

    test('exatamente 8 caracteres mas sem número retorna erro', () {
      expect(sut.passwordValidator('Abcde!fg'), isNotNull);
    });

    test('exatamente 8 caracteres mas sem caractere especial retorna erro',
        () {
      expect(sut.passwordValidator('Abcde1fg'), isNotNull);
    });

    test('senha válida com exatamente 8 caracteres retorna null (valor limite)',
        () {
      expect(sut.passwordValidator('Abc1!@fg'), isNull);
    });

    test('senha longa e complexa retorna null', () {
      expect(sut.passwordValidator('Senha@Forte123!'), isNull);
    });
  });

  // ============================================================
  // CadastrarClienteViewModel — cpfCnpjValidator
  // ============================================================
  group('CadastrarClienteViewModel — cpfCnpjValidator', () {
    late CadastrarClienteViewModel sut;

    setUp(() => sut = CadastrarClienteViewModel());
    tearDown(() => sut.dispose());

    test('null retorna erro', () {
      expect(sut.cpfCnpjValidator(null), isNotNull);
    });

    test('string vazia retorna erro', () {
      expect(sut.cpfCnpjValidator(''), isNotNull);
    });

    test('10 dígitos retorna erro (abaixo do mínimo para CPF)', () {
      expect(sut.cpfCnpjValidator('1234567890'), isNotNull);
    });

    test('12 dígitos retorna erro (entre CPF e CNPJ — inválido)', () {
      expect(sut.cpfCnpjValidator('123456789012'), isNotNull);
    });

    test('11 dígitos (CPF) retorna null', () {
      expect(sut.cpfCnpjValidator('12345678901'), isNull);
    });

    test('11 dígitos com máscara (CPF formatado) retorna null', () {
      expect(sut.cpfCnpjValidator('123.456.789-01'), isNull);
    });

    test('14 dígitos (CNPJ) retorna null', () {
      expect(sut.cpfCnpjValidator('12345678000190'), isNull);
    });

    test('14 dígitos com máscara (CNPJ formatado) retorna null', () {
      expect(sut.cpfCnpjValidator('12.345.678/0001-90'), isNull);
    });
  });

  // ============================================================
  // CadastrarClienteViewModel — cepValidator
  // ============================================================
  group('CadastrarClienteViewModel — cepValidator', () {
    late CadastrarClienteViewModel sut;

    setUp(() => sut = CadastrarClienteViewModel());
    tearDown(() => sut.dispose());

    test('null retorna erro', () {
      expect(sut.cepValidator(null), isNotNull);
    });

    test('7 dígitos retorna erro (valor limite: abaixo)', () {
      expect(sut.cepValidator('1234567'), isNotNull);
    });

    test('8 dígitos retorna null (valor limite: exato)', () {
      expect(sut.cepValidator('37540000'), isNull);
    });

    test('9 dígitos retorna erro (valor limite: acima)', () {
      expect(sut.cepValidator('375400001'), isNotNull);
    });

    test('CEP formatado com hífen retorna null', () {
      expect(sut.cepValidator('37540-000'), isNull);
    });
  });

  // ============================================================
  // CadastrarClienteViewModel — telefoneValidator
  // ============================================================
  group('CadastrarClienteViewModel — telefoneValidator', () {
    late CadastrarClienteViewModel sut;

    setUp(() => sut = CadastrarClienteViewModel());
    tearDown(() => sut.dispose());

    test('null retorna erro', () {
      expect(sut.telefoneValidator(null), isNotNull);
    });

    test('9 dígitos retorna erro (sem DDD)', () {
      expect(sut.telefoneValidator('999999999'), isNotNull);
    });

    test('10 dígitos (fixo com DDD) retorna null (valor limite mínimo)', () {
      expect(sut.telefoneValidator('3599999999'), isNull);
    });

    test('11 dígitos (celular com DDD) retorna null (valor limite máximo)',
        () {
      expect(sut.telefoneValidator('35999999999'), isNull);
    });

    test('12 dígitos retorna erro (acima do máximo)', () {
      expect(sut.telefoneValidator('359999999990'), isNotNull);
    });
  });
}
