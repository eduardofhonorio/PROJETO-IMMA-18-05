import 'package:flutter/material.dart';
import 'package:projeto02/app/routes/app_routes.dart';
import 'package:projeto02/features/auth/viewmodel/splash_viewmodel.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashViewModel _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _iniciarSplash();
  }

  void _iniciarSplash() async {
    await _viewModel.carregarAplicativo();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E9),
      body: Stack(
        children: [
          ClipPath(
            clipper: DiagonalClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.57,
              color: const Color.fromARGB(255, 74, 0, 0),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/logo_IMMA.png",
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.image_not_supported, size: 100, color: Colors.white),
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          "Acesso do\nVendedor",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 95, 1, 1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                              backgroundColor: Color.fromARGB(255, 243, 4, 4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Carregando...",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}