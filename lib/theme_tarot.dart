// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class AppTheme {
  /// Aydınlık tema tanımlaması
  static ThemeData get lightTheme {
    // Renk paleti tanımlamaları
    const Color primaryColor = Color(0xFF651FFF);
    const Color secondaryColor = Color(0xFFCDDC39);
    const Color accentColor = Color(0xFFFF5722);
    const Color backgroundColor = Colors.white;
    const Color scaffoldBackgroundColor = Colors.white;

    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      hintColor: accentColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      // AppBar teması ve metin stilleri
      appBarTheme: AppBarTheme(
        color: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 4,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Genel metin stili tanımları
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
      ),
      // Buton temaları
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      // Input alanları için dekorasyon teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      // Özel sayfa geçiş animasyonu
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
          TargetPlatform.iOS: CustomPageTransitionBuilder(),
        },
      ),
      // Fazladan eklenen genel stil ayarları ve animasyon süreleri
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Karanlık tema tanımlaması
  static ThemeData get darkTheme {
    // Karanlık renk paleti tanımlamaları
    const Color primaryColor = Color(0xFFBB86FC);
    const Color secondaryColor = Color(0xFF03DAC6);
    const Color accentColor = Color(0xFFCF6679);
    const Color backgroundColor = Colors.black;
    const Color scaffoldBackgroundColor = Colors.black;

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      hintColor: accentColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: AppBarTheme(
        color: primaryColor,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 4,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5, color: Colors.white),
        displayMedium: TextStyle(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: Colors.white),
        displaySmall: TextStyle(fontSize: 48, fontWeight: FontWeight.w400, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, color: Colors.white70),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: Colors.white70),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.white70),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25, color: Colors.white),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.white70),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: Colors.white70),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CustomPageTransitionBuilder(),
          TargetPlatform.iOS: CustomPageTransitionBuilder(),
        },
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}

/// Özel sayfa geçiş animasyonu sağlayan PageTransitionsBuilder
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    // FadeTransition ile yumuşak geçiş sağlanıyor
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
