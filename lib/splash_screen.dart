import 'package:flutter/material.dart';
import 'shopping_list_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Iniciar animación
    _controller.forward();

    // Navegar a la lista después de 4 segundos (verificar mounted)
    Future.delayed(const Duration(seconds: 4)).then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ShoppingListView()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
                Container(
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Color((0x2E << 24) | (Theme.of(context).primaryColor.toARGB32() & 0x00FFFFFF)),
                          blurRadius: 24,
                          spreadRadius: 6,
                        ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 40),

                // Título con mayor contraste (usa colores del tema)
                Builder(builder: (context) {
                  final textColor = Theme.of(context).colorScheme.onSurface;
                  return Text(
                    'Mi Listita Go',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),

                // Subtítulo elegante
                const Text(
                  'Compras inteligentes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9e9e9e),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 60),

                // Indicador de carga minimalista
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    strokeWidth: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}