import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors - Agriculture themed with soft greens, mints, and earth tones
  static const Color primaryGreen = Color(0xFF2D6A4F); // Deep forest green
  static const Color secondaryMint = Color(0xFF52B788); // Mint green
  static const Color accentLime = Color(0xFF95D5B2); // Light mint
  static const Color neutralWarm = Color(0xFFF5F3F0); // Warm white/cream
  static const Color earthBrown = Color(0xFF9B7E77); // Earth brown accent

  // Status colors
  static const Color statusAman = Color(0xFF2D6A4F); // Green
  static const Color statusWaspada = Color(0xFFF4A261); // Amber/Orange
  static const Color statusRisikoTinggi = Color(0xFFE76F51); // Red/Orange

  // Neutral colors
  static const Color textDark = Color(0xFF1B1B1B);
  static const Color textMedium = Color(0xFF555555);
  static const Color textLight = Color(0xFF999999);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE76F51);

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: secondaryMint,
        error: errorColor,
        surface: cardColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryGreen,
        selectionHandleColor: primaryGreen,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 32,
          ),
          displayMedium: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
          displaySmall: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
          headlineSmall: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          titleLarge: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          titleMedium: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          bodyLarge: TextStyle(
            color: textMedium,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: textMedium,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: textLight,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        hintStyle: const TextStyle(color: textLight),
        labelStyle: const TextStyle(color: textMedium),
        floatingLabelStyle: const TextStyle(color: primaryGreen),
        prefixIconColor: textMedium,
        suffixIconColor: textMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 3,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryMint,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGreen,
      ),
    );
  }
}
