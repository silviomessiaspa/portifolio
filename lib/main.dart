import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2DC8BD)),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'Portfólio • Silvio Duarte',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
          displaySmall: GoogleFonts.montserrat(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            height: .95,
          ),
          titleMedium: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
          ),
          bodySmall: GoogleFonts.montserrat(
            fontWeight: FontWeight.w400,
            height: 1.15,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
