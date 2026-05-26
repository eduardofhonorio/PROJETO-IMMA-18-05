
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto02/features/auth/viewmodel/cadastrar_cliente_viewmodel.dart';

void main() {
  group('Testes de Validação - CadastrarClienteViewModel (Máscaras e Limites)', () {
    late CadastrarClienteViewModel viewModel;

    // O setUp roda antes de CADA teste, garantindo um ViewModel "limpo" e zerado
    setUp(() {
      viewModel = CadastrarClienteViewModel();
    });

    test('Validação de CNPJ e CPF - Ignorando máscaras e checando quantidade', () {
      // 1. Falha: Faltando números (apenas 6 números)
      expect(
        viewModel.cpfCnpjValidator('123.456'), 
        'O documento deve ter 11 dígitos (CPF) ou 14 dígitos (CNPJ)'
      );
      
      // 2. Sucesso: CPF válido digitado COM máscara (11 números disfarçados com pontuação)
      expect(viewModel.cpfCnpjValidator('123.456.789-00'), isNull);
      
      // 3. Sucesso: CNPJ válido digitado COM máscara (14 números com pontuação)
      expect(viewModel.cpfCnpjValidator('12.345.678/0001-90'), isNull);
      
      // 4. Sucesso: Apenas os números diretos (sem máscara nenhuma)
      expect(viewModel.cpfCnpjValidator('12345678000190'), isNull);
    });

    test('Validação de CEP - Ignorando traço e checando 8 dígitos', () {
      // 1. Falha: CEP incompleto (5 números)
      expect(
        viewModel.cepValidator('12345'), 
        'O CEP deve conter exatamente 8 números'
      );
      
      // 2. Sucesso: Digitado com traço
      expect(viewModel.cepValidator('12345-678'), isNull);
      
      // 3. Sucesso: Digitado sem traço
      expect(viewModel.cepValidator('12345678'), isNull);
    });

    test('Validação de Telefone - Ignorando parênteses/traços e aceitando 10 ou 11 dígitos', () {
      // 1. Falha: Telefone sem o DDD (apenas 9 números)
      expect(
        viewModel.telefoneValidator('99999-9999'), 
        'O telefone deve ter 10 ou 11 números (incluindo o DDD)'
      );
      
      // 2. Sucesso: Telefone celular com DDD e máscara completa (11 números úteis)
      expect(viewModel.telefoneValidator('(35) 99999-9999'), isNull);
      
      // 3. Sucesso: Telefone fixo com DDD e máscara completa (10 números úteis)
      expect(viewModel.telefoneValidator('(35) 3444-4444'), isNull);
    });

    test('Validação de Campos Obrigatórios Gerais (Razão Social, Endereço, etc)', () {
      // 1. Falha: Campo completamente vazio
      expect(viewModel.campoObrigatorioValidator(''), 'Este campo é obrigatório');
      
      // 2. Falha: Campo preenchido apenas com espaços em branco ("gato" tentando enganar o sistema)
      expect(viewModel.campoObrigatorioValidator('   '), 'Este campo é obrigatório');
      
      // 3. Sucesso: Preenchimento correto
      expect(viewModel.campoObrigatorioValidator('Mercado do Zé'), isNull);
    });

    test('Regra de Negócio: O estado inicial do formulário deve ser em MG', () {
      // Prova que a regra de definir Minas Gerais como padrão está funcionando
      expect(viewModel.estadoSelecionado, 'MG');
      
      // Simula a troca para São Paulo
      viewModel.setEstado('SP');
      expect(viewModel.estadoSelecionado, 'SP');
    });
  });
}