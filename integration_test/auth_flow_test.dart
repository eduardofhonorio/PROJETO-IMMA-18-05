
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:projeto02/app/app_widget.dart';

void main(){
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de autenticação - Testes de Integração',(){

    testWidgets(
      'Cadastrar Cliente', 
      (WidgetTester tester) async {

        await tester.pumpWidget(const AppWidget());
        await tester.pumpAndSettle();

      
      },00000000000000000000000
    );
  });
}