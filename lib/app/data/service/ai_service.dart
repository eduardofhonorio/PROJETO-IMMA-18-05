import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  // A chave é injetada em tempo de build via --dart-define=GROQ_API_KEY=sua_chave
  // Exemplo de execução: flutter run --dart-define=GROQ_API_KEY=gsk_xxxx
  // Exemplo de build:    flutter build apk --dart-define=GROQ_API_KEY=gsk_xxxx
  static const _apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  static const _url = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> obterRecomendacao(String resumoDeVendas) async {
    if (_apiKey.isEmpty) {
      return 'Assistente indisponível: chave de API não configurada. '
          'Execute o app com --dart-define=GROQ_API_KEY=sua_chave.';
    }

    try {
      final prompt = '''
        Você é o "ADA", um assistente virtual de inteligência de vendas especialista em atacado da empresa IMMA Atacadista.
        Sua missão é analisar o resumo de vendas dos últimos 7 dias deste vendedor e fornecer um insight estratégico, direto e motivacional em no máximo 4 linhas.
        
        Com base nos dados fornecidos abaixo, sua recomendação DEVE conter obrigatoriamente:
        1. Um reconhecimento rápido do que deu certo (ex: cidade que mais comprou ou produto campeão de vendas).
        2. Um alerta claro sobre qual produto está "mais parado no estoque" (que teve a menor saída ou nenhuma venda).
        3. Uma sugestão de ação prática e motivacional para o vendedor focar em vender esse produto parado na rota de hoje.

        Regra: Seja direto, persuasivo e use um tom de parceria profissional. Não use formatações complexas.

        DADOS DE VENDAS DO VENDEDOR:
        $resumoDeVendas
      ''';

      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (res.statusCode != 200) {
        return 'Não foi possível conectar ao assistente inteligente no momento.';
      }

      final data = jsonDecode(res.body);

      return data['choices'][0]['message']['content']?.trim() ??
          'Nenhuma recomendação pôde ser gerada.';
    } catch (e) {
      return 'Não foi possível conectar ao assistente inteligente no momento. Tente novamente mais tarde.';
    }
  }
}
