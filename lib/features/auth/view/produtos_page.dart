import 'package:flutter/material.dart';



class ProdutosPage extends StatefulWidget {
  // Variável que recebe a categoria clicada lá na Home
  final String categoriaInicial; 
  
  // Se abrir pelo "Ver todos", assume 'Todos' por padrão
  const ProdutosPage({super.key, this.categoriaInicial = 'Todos'});

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  final Color corPrimaria = const Color(0xFF480404);
  final Color corFundo = const Color(0xFFF9F9F9);
  final Color corBotao = const Color(0xFFB70000);

  // Variáveis de estado
  String _termoBusca = '';
  late String _categoriaSelecionada; // Inicializada no initState
  String _ordemSelecionada = 'Mais vendidos';

  @override
  void initState() {
    super.initState();
    // A página agora inicia com a categoria que veio da tela anterior!
    _categoriaSelecionada = widget.categoriaInicial; 
  }

  // Categorias baseadas no design
  final List<Map<String, dynamic>> _categorias = [
    {'nome': 'Todos', 'icone': Icons.grid_view_rounded},
    {'nome': 'Alimentos', 'icone': Icons.shopping_bag_outlined},
    {'nome': 'Bebidas', 'icone': Icons.local_drink_outlined},
    {'nome': 'Higiene & Limpeza', 'icone': Icons.cleaning_services_outlined},
    {'nome': 'Utilidades', 'icone': Icons.home_repair_service_outlined},
  ];

  // Lista mockada com os exatos produtos do seu protótipo
  final List<Map<String, dynamic>> _produtosMock = [
    {
      'nome': 'Chocolate KitKat',
      'marca': 'Nestlé | Caixa com 24 un. 41,5g',
      'codigo': '7891000245678',
      'estoque': 152,
      'preco': '49,90',
      'unidade': 'cx',
      'categoria': 'Alimentos',
    },
    {
      'nome': 'Chocolate Lacta Ao Leite',
      'marca': 'Lacta | Barra 80g',
      'codigo': '7891962058891',
      'estoque': 320,
      'preco': '4,29',
      'unidade': 'un',
      'categoria': 'Alimentos',
    },
    {
      'nome': 'Desinfetante Ypê Lavanda',
      'marca': 'Ypê | Frasco 2L',
      'codigo': '7896098901234',
      'estoque': 85,
      'preco': '6,99',
      'unidade': 'un',
      'categoria': 'Higiene & Limpeza',
    },
    {
      'nome': 'Sabão em Pó OMO',
      'marca': 'OMO | Caixa 1,6kg',
      'codigo': '7891150061021',
      'estoque': 64,
      'preco': '18,90',
      'unidade': 'cx',
      'categoria': 'Higiene & Limpeza',
    },
    {
      'nome': 'Óleo de Soja Liza',
      'marca': 'Liza | Pet 900ml',
      'codigo': '7891020101237',
      'estoque': 210,
      'preco': '6,49',
      'unidade': 'un',
      'categoria': 'Alimentos',
    },
    {
      'nome': 'Coca-Cola Original',
      'marca': 'Coca-Cola | Pet 2L',
      'codigo': '7894900011517',
      'estoque': 128,
      'preco': '8,49',
      'unidade': 'un',
      'categoria': 'Bebidas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Lógica de Filtro (Busca + Categoria)
    final produtosFiltrados = _produtosMock.where((produto) {
      final passaCategoria = _categoriaSelecionada == 'Todos' || produto['categoria'] == _categoriaSelecionada;
      final nome = produto['nome'].toString().toLowerCase();
      final codigo = produto['codigo'].toString();
      final marca = produto['marca'].toString().toLowerCase();
      
      final passaBusca = _termoBusca.isEmpty || 
                         nome.contains(_termoBusca) || 
                         codigo.contains(_termoBusca) || 
                         marca.contains(_termoBusca);

      return passaCategoria && passaBusca;
    }).toList();

    return Scaffold(
      backgroundColor: corFundo,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==========================================
            // CABEÇALHO BORDÔ (Com botão de voltar)
            // ==========================================
            Container(
              color: corPrimaria,
              padding: const EdgeInsets.only(left: 4.0, right: 16.0, top: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                        onPressed: () {
                          Navigator.pop(context); // Comando que fecha a página
                        },
                      ),
                      Image.asset(
                        "assets/images/logo_IMMA.png",
                        height: 40, 
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_shipping, size: 36, color: Colors.white),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildHeaderIcon(Icons.person_outline, 'Perfil', onTap: () {}), 
                    ],
                  ),
                ],
              ),
            ),

            // ==========================================
            // CONTEÚDO DA PÁGINA
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO DA PÁGINA
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Text(
                        'Estoque Disponível',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Consulte todos os produtos disponíveis em estoque.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BARRA DE PESQUISA E BOTÃO FILTROS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: TextField(
                                onChanged: (valor) => setState(() => _termoBusca = valor.toLowerCase()),
                                decoration: const InputDecoration(
                                  hintText: 'Buscar produtos por nome, marca ou código...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
                                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_alt_outlined, color: corPrimaria, size: 20),
                                const SizedBox(width: 6),
                                const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CHIPS DE CATEGORIAS (Filtro Horizontal)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: _categorias.map((cat) {
                          bool isSelected = _categoriaSelecionada == cat['nome'];
                          return GestureDetector(
                            onTap: () => setState(() => _categoriaSelecionada = cat['nome']),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? corPrimaria : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? corPrimaria : Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    cat['icone'], 
                                    size: 16, 
                                    color: isSelected ? Colors.white : corBotao
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat['nome'],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CABEÇALHO DA LISTA (Quantidade e Ordenação)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.inventory_2_outlined, color: corPrimaria, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${produtosFiltrados.length} produtos',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                  ),
                                  const Text('em estoque', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Ordenar por', style: TextStyle(color: Colors.black54, fontSize: 12)),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _ordemSelecionada,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
                                underline: const SizedBox(),
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                                items: <String>['Mais vendidos', 'Menor preço', 'Maior preço', 'A - Z'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _ordemSelecionada = newValue!;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LISTA DE PRODUTOS
                    produtosFiltrados.isEmpty 
                      ? const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("Nenhum produto encontrado.", style: TextStyle(color: Colors.black54))))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: produtosFiltrados.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildProdutoCard(produtosFiltrados[index]),
                            );
                          },
                        ),
                        
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: CARD DE EXIBIÇÃO DO PRODUTO
  // ==========================================
  Widget _buildProdutoCard(Map<String, dynamic> produto) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 30),
            ),
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produto['nome'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    produto['marca'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cód. ${produto['codigo']}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Em estoque', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '${produto['estoque']} ', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87)),
                      const TextSpan(text: 'un.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                
                Text(
                  'R\$ ${produto['preco']} / ${produto['unidade']}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: ÍCONES DO CABEÇALHO SUPERIOR
  // ==========================================
  Widget _buildHeaderIcon(IconData icon, String label, {String? badge, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              if (badge != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}