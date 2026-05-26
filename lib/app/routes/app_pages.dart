
import 'package:flutter/material.dart';
import 'package:projeto02/app/routes/app_routes.dart';
import 'package:projeto02/features/auth/view/cadastrar_cliente_page.dart';
import 'package:projeto02/features/auth/view/clientes_page.dart';
import 'package:projeto02/features/auth/view/novo_pedido_page.dart';
import 'package:projeto02/features/auth/view/home_page.dart';
import 'package:projeto02/features/auth/view/login_page.dart';
import 'package:projeto02/features/auth/view/pedidos_page.dart';
import 'package:projeto02/features/auth/view/register_page.dart';
import 'package:projeto02/features/auth/view/splash_page.dart';


abstract class AppPages {
  static Map<String, WidgetBuilder> get routes => {
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.register: (_) => const RegisterPage(),
    AppRoutes.home: (_) => const HomePage(),
    AppRoutes.clientes: (_) => const ClientesPage(),
    AppRoutes.pedidos: (_) => const PedidosPage(),
    AppRoutes.cadastrarCliente: (_) => const CadastrarClientePage(),
    AppRoutes.novoPedido: (_) => const NovoPedidoPage(),
    
  };
}