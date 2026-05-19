import 'package:flutter_test/flutter_test.dart';
import 'package:projeto02/features/auth/viewmodel/pedido_viewmodel.dart';

void main() {
  group('Testes de Lógica de Negócio - PedidoViewModel (Regras de Pagamento)', () {
    

    late PedidoViewModel viewModel; 

    setUp(() {
 
      viewModel = PedidoViewModel();
    });

    test('Validação de Prazo Customizado - Limite máximo de 30 dias', () {
      // 1. Falha: Campo Vazio
      expect(
        viewModel.prazoPagamentoValidator(''), 
        'Informe os dias'
      );

      // 2. Falha: Número negativo ou zero
      expect(
        viewModel.prazoPagamentoValidator('0'), 
        'Valor inválido'
      );
      expect(
        viewModel.prazoPagamentoValidator('-5'), 
        'Valor inválido'
      );

      // 3. Falha: Tentativa de burlar o limite (mais de 30 dias)
      expect(
        viewModel.prazoPagamentoValidator('31'), 
        'O limite máximo é de 30 dias'
      );
      expect(
        viewModel.prazoPagamentoValidator('99'), 
        'O limite máximo é de 30 dias'
      );

      // 4. Sucesso: Dias permitidos pela regra da IMMA
      expect(viewModel.prazoPagamentoValidator('1'), isNull);
      expect(viewModel.prazoPagamentoValidator('15'), isNull);
      expect(viewModel.prazoPagamentoValidator('30'), isNull); // O limite exato deve passar!
    });
  });
}