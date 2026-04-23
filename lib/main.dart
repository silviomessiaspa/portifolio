import 'package:flutter/material.dart';
import 'home_page.dart';

void main() => runApp(const MyApp());

const String _kFontFamily = 'Montserrat';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2DC8BD)),
      useMaterial3: true,
      fontFamily: _kFontFamily,
    );
    return MaterialApp(
      title: 'Portfólio • Silvio Duarte',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.copyWith(
          displaySmall: const TextStyle(
            fontFamily: _kFontFamily,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            height: .95,
          ),
          titleMedium: const TextStyle(
            fontFamily: _kFontFamily,
            fontWeight: FontWeight.w700,
          ),
          bodySmall: const TextStyle(
            fontFamily: _kFontFamily,
            fontWeight: FontWeight.w400,
            height: 1.15,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
