import 'dart:convert';

import 'package:http/http.dart' as http;

class AiService {
  // COLE A SUA CHAVE DO GROQ AQUI MANTENDO AS ASPAS SIMPLES:
  static const _apiKey = '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'; 
  
  static const _url = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> obterRecomendacao(String resumoDeVendas) async {
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

      // Disparando a requisição para o Groq
      final res = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [{'role': 'user', 'content': prompt}],
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (res.statusCode != 200) {
        print('=== ERRO GROQ HTTP: ${res.body} ===');
        return 'Não foi possível conectar ao assistente inteligente no momento.';
      }

      final data = jsonDecode(res.body);
      
      // AQUI ESTÁ A LINHA CORRIGIDA COM O ÍNDICE  EXIGIDO PELA API:
      return data['choices'][0]['message']['content']?.trim() ?? 'Nenhuma recomendação pôde ser gerada.';
      
    } catch (e) {
      print('=== ERRO DA API GROQ: $e ===');
      return 'Não foi possível conectar ao assistente inteligente no momento. Tente novamente mais tarde.';
    }
  }
}