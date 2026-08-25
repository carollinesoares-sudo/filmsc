import 'package:flutter/material.dart';
import 'views/login_screen.dart';

void main() {
  runApp(const CineFavoriteApp());
}

class CineFavoriteApp extends StatelessWidget {
  const CineFavoriteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080B10);
    const surface = Color(0xFF151A22);
    const accent = Color(0xFFE50914);
    const secondary = Color(0xFF00A8E1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineFavorite',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: secondary,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardColor: surface,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: surface,
          hintStyle: TextStyle(color: Color(0xFF8993A4)),
          labelStyle: TextStyle(color: Color(0xFF8993A4)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: secondary),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0E1218),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF778092),
          type: BottomNavigationBarType.fixed,
          elevation: 12,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: accent,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
