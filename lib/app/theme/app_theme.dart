import 'package:flutter/material.dart';

class AppTheme {
  // Ana renkler
  static const Color background = Color(0xFF181a20);
  static const Color primary = Color(0xFFcfaf30); // Binance sarısı
  static const Color textPrimary = Color(0xFFeaecef); // Ana metin rengi
  static const Color textSecondary = Color(0xFF848e9c); // İkincil metin rengi
  static const Color surface = Color(0xFF272c34); // Kart ve buton arkaplanı
  static const Color cardBackground = Color(0xFF1F2329); // Kart arkaplanı

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      background: background,
      primary: primary,
      secondary: primary,
      surface: surface,
      onBackground: textPrimary,
      onPrimary: background,
      onSecondary: background,
      onSurface: textPrimary,
    ),

    scaffoldBackgroundColor: background,

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
    ),

    cardTheme: CardTheme(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    bottomNavigationBarTheme:  BottomNavigationBarThemeData(
      backgroundColor: background,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: TextStyle(color: textSecondary),
      labelStyle: TextStyle(color: textSecondary),
      prefixIconColor: textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primary),
      ),
    ),
    
    iconTheme: IconThemeData(
      color: textPrimary,
    ),
  );

  // Koyu tema için aynı temayı kullanıyoruz çünkü Binance teması zaten koyu
  static final ThemeData darkTheme = lightTheme;
}
