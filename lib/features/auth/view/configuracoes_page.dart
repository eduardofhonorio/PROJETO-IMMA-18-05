import 'package:flutter/material.dart';
import 'package:projeto02/app/app_widget.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // O Flutter agora descobre sozinho qual é o tema atual!
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Configurações",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Gerencie suas preferências e configurações do sistema.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              const Row(
                children: [
                  Icon(Icons.settings_outlined, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Preferências do sistema",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // O ValueListenableBuilder atualiza apenas este botão na tela
              ValueListenableBuilder<bool>(
                valueListenable: isDarkModeGlobal,
                builder: (context, isDarkMode, child) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                      ),
                    ),
                    child: SwitchListTile(
                      title: const Text("Aparência (Modo Escuro)"),
                      subtitle: const Text("Altera a cor do aplicativo para preto"),
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: isDarkMode ? Colors.amber : Colors.grey,
                      ),
                      value: isDarkMode,
                      activeColor: const Color.fromARGB(255, 74, 0, 0),
                      onChanged: (bool value) {
                        // A MÁGICA: Mudar isso atualiza o app todo instantaneamente!
                        isDarkModeGlobal.value = value;
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}