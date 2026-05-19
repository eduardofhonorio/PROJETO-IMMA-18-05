o projeto do nosso PI, desenvolvido em Flutter para modernizar a operação de vendas em campo da IMMA Atacadista, passou por grandes refatorações de UI/UX e integração de dados.

# O que já foi implementado e está 100% funcional:
- Autenticação e Arquitetura: Estrutura baseada em MVVM com fluxos de Login e Cadastro seguros

- Gestão de Clientes: Nova tela de listagem integrada ao Firebase com busca dinâmica (Nome/CNPJ), filtros por cidade e ordenação alfabética (A-Z) automática.
 
- Tela de Cadastro de Clientes modernizada (labels externos, dropdown de Estado) com salvamento direto no banco de dados e vínculo automático ao vendedor logado.

- Gestão de Pedidos: Nova tela de Histórico de Pedidos com design de "pílulas" de status coloridas e filtros inteligentes de data (Hoje, Ontem, Últimos 7 dias).

- Tela de Novo Pedido (Carrinho Completo): Implementação de um carrinho de compras dinâmico, permitindo adicionar/remover produtos, alterar quantidades e calcular totais em tempo real.
  
- Catálogo de produtos sincronizado com o Firebase, barra de busca responsiva e seleção de clientes via Modal Bottom Sheet.
  
- Inserção de Observações de entrega via Pop-up e submissão completa do orçamento direto para a nuvem.
  
# Melhorias em Andamento:
Continuamos trabalhando para eliminar tarefas analógicas e entregar um sistema robusto

- Sincronização com ERP: Conectar a base de dados em tempo real ao ERP TopGerente (Telluria) da IMMA Atacadista, para leitura exata de SKUs e eliminação da redigitação de malotes
  
- Motor de BI e Comissões: Cálculo automático de comissões por categoria (ex: 2,5% normal vs. 1,5% energéticos) e alertas preditivos de contas a receber.
