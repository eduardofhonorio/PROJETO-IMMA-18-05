import 'package:flutter/material.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// 1. Variável global que "avisa" o app inteiro sobre a mudança
final ValueNotifier<bool> isDarkModeGlobal = ValueNotifier(false);

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. O ValueListenableBuilder fica "escutando" a variável global
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeGlobal,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Projeto IMMA Atacadista',
          
          // TEMA CLARO (Padrão da IMMA)
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFFF5E9), // Cor creme
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 74, 0, 0), // Bordô
              foregroundColor: Colors.white,
            ),
          ),
          
          // TEMA ESCURO (Fundo bem mais escuro, conforme pedido)
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212), // Quase preto!
            cardColor: const Color(0xFF1E1E1E), 
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
          
          // 3. Define qual tema usar baseado na nossa variável global
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          
          initialRoute: AppRoutes.login,
          routes: AppPages.routes,
        );
      },
    );
  }
}