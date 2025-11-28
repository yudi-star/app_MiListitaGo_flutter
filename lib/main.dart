import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_screen.dart';
import 'theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        final lightTheme = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: const Color(0xFFF6F7F6),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Color(0xFF1a1a1a),
            centerTitle: false,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFFFF8A00),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        );

        final darkTheme = ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            centerTitle: false,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFFFF8A00),
          ),
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        );

        return MaterialApp(
          title: 'Mi Listita Go',
          theme: dark ? darkTheme : lightTheme,
          home: const SplashScreen(), // Inicia con el Splash Screen
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}