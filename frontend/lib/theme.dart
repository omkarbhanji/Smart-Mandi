import 'package:flutter/material.dart';

// Custom Color definitions based on the provided green theme
class AppColors {
  static const Color primary = Color(0xFF047857); // Dark Green
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  static const Color background = Color(0xFFF0FAF5); // Very light Mint
  static const Color textDark = Color(0xFF374151); // Dark Gray for text
  static const Color accentYellow = Color(0xFFFBBF24); // Amber/Gold for action
}

// Global App Theme Configuration
final ThemeData smartMandiTheme = ThemeData(
  // Use Inter font (requires adding 'flutter_localizations' and font assets in a real app)
  fontFamily: 'Inter',

  // Set the background color for Scaffold
  scaffoldBackgroundColor: AppColors.background,

  // Define the primary color swatch
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
  ),

  // AppBar style
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),

  // Button style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Rounded corners
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Input Field Decoration
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFD1FAE5)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: Color(0xFFD1FAE5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(color: AppColors.secondary, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.textDark),
    hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.5)),
  ),
);
