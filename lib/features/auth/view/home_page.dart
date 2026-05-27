import 'package:flutter/material.dart';
import 'package:projeto02/features/auth/view/comissoes_page.dart';
import 'package:projeto02/features/auth/view/perfil_page.dart';
import 'package:projeto02/features/auth/view/produtos_page.dart';
import 'package:projeto02/features/auth/view/vales_page.dart';
import 'package:projeto02/features/auth/viewmodel/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color corPrimaria = const Color(0xFF480404); // Vermelho escuro IMMA
  final Color corFundo = const Color(0xFFF9F9F9); // Off-white
  final Color corBotao = const Color(0xFFB70000);

  final HomeViewModel _viewModel = HomeViewModel();

  // Função que abre a aba da IA e dispara a requisição
  void _abrirModalIA() {
    _viewModel.gerarRecomendacao();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AnimatedBuilder(
          animation: _viewModel,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Color(0xFFFFF5F5), shape: BoxShape.circle),
                        child: Icon(Icons.auto_awesome, color: corBotao, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'ADA - Assistente de Vendas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  
                  Expanded(
                    child: _viewModel.isLoadingRecomendacao
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: corBotao),
                                const SizedBox(height: 16),
                                const Text('Analisando suas vendas da semana...', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Text(
                              _viewModel.recomendacaoIA,
                              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                            ),
                          ),
                  ),
                 
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _viewModel.isLoadingRecomendacao ? Colors.grey : corBotao,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _viewModel.isLoadingRecomendacao ? null : () => Navigator.pop(context),
                      child: const Text('Entendido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // CABEÇALHO VERMELHO
                Container(
                  color: corPrimaria,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        "assets/images/logo_IMMA.png",
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.local_shipping, size: 40, color: Colors.white),
                      ),
                      Row(
                      children: [
                        _buildHeaderIcon(Icons.person_outline, 'Perfil', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PerfilPage()),
                          );
                        }),
                      ],
                    )
                    ],
                  ),
                ),

                // CORPO DA TELA COM SCROLL
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // SAUDAÇÃO DINÂMICA
                        RichText(
                          text: TextSpan( 
                            text: 'Olá, ',
                            style: const TextStyle(fontSize: 22, color: Colors.black87),
                            children: [
                              TextSpan(
                                text: '${_viewModel.nomeVendedor}!', 
                                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ROTA DO DIA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: Colors.black87, size: 28),
                                SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [     
                                    Text('Rota de Hoje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    Text('Arceburgo e Região', style: TextStyle(fontSize: 14, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // BANNER PROMOCIONAL
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [corPrimaria, corBotao], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 28),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Seu atacado de confiança para o seu negócio crescer!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildBannerTag(Icons.sell_outlined, 'Preços\ncompetitivos'),
                                  _buildBannerTag(Icons.local_shipping_outlined, 'Entrega\nrápida'),
                                  _buildBannerTag(Icons.verified_outlined, 'Produtos de\nqualidade'),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // TÍTULO CATEGORIAS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Produtos em Estoque', 
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                            ),
                            
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ProdutosPage()),
                                );
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Ver todos', 
                                    style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)
                                  ),
                                  Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),

                        // GRID DE CATEGORIAS
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.00,
                          children: [
                            _buildCategoriaCard(context, 'Alimentos', 'assets/images/alimentos.png', 'Alimentos'),
                            _buildCategoriaCard(context, 'Higiene & Limpeza', 'assets/images/higiene.png', 'Higiene & Limpeza'),
                            _buildCategoriaCard(context, 'Utilidades & Diversos', 'assets/images/utilidades.png', 'Utilidades'), 
                            _buildCategoriaCard(context, 'Bebidas', 'assets/images/bebidas.png', 'Bebidas'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // CARDS DE RESUMO ESTRATÉGICOS
                        Row(
                          children: [
                            // CARD DE COMISSÕES CLICÁVEL COM A NOVA NAVEGAÇÃO
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ComissoesPage(viewModel: _viewModel), // SÓ ISSO AGORA!
                                    ),
                                  );
                                },
                                child: _buildInfoCard(
                                  Icons.monetization_on_outlined, 
                                  'Minhas Comissões', 
                                  _viewModel.isLoadingFinanceiro ? 'Calculando...' : 'Atualizado hoje', 
                                  'R\$ ${_viewModel.totalComissoes.toStringAsFixed(2)}'
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // CARD DE VALES (Ainda mantido aqui como atalho)
                           Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ValesPage(), // Abre a nova página!
                                    ),
                                  );
                                },
                                child: _buildInfoCard(
                                  Icons.warning_amber_rounded, 
                                  'Vales na Rota', 
                                  _viewModel.isLoadingFinanceiro ? 'Calculando...' : 'Cobranças hoje', 
                                  'R\$ ${_viewModel.totalVales.toStringAsFixed(2)}'
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // CARD DA IA
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD6D6), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.psychology_outlined, size: 40, color: corBotao),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Obter recomendação por IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    const Text('Receba sugestões personalizadas para aumentar suas vendas.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: corBotao,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      onPressed: _abrirModalIA, 
                                      icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                                      label: const Text('Gerar recomendações', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BOTTOM NAVIGATION BAR
          bottomNavigationBar: Container(
            color: corFundo,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: corPrimaria,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomNavItem(Icons.people_alt_outlined, 'Clientes', false, () {
                      Navigator.pushReplacementNamed(context, '/clientes'); 
                    }),
                    _buildBottomNavItem(Icons.home, 'Início', true, () {}),
                    _buildBottomNavItem(Icons.content_paste_outlined, 'Pedidos', false, () {
                      Navigator.pushReplacementNamed(context, '/pedidos');
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // === WIDGETS AUXILIARES ===

  Widget _buildHeaderIcon(IconData icon, String label, VoidCallback onTap, {String? badge}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              if (badge != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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

  Widget _buildBannerTag(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _buildCategoriaCard(BuildContext context, String titulo, String caminhoImagem, String filtro) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProdutosPage(categoriaInicial: filtro),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    caminhoImagem,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image_outlined, size: 40, color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text('Ver produtos', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 14, color: Colors.black54),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String titulo, String subtitulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: corBotao, size: 20),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.black45, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(subtitulo, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icone, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(30)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: isSelected ? corPrimaria : Colors.white60, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? corPrimaria : Colors.white60, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}