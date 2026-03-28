import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Principal Palette (Stitch)
  static const Color primary = Color(0xFFEE7211); // Vibrant orange from prototype
  static const Color primaryContainer = Color(0xFFFF9944);
  static const Color surface = Color(0xFFf8f9fa);
  static const Color onSurface = Color(0xFF191c1d);
  static const Color secondary = Color(0xFF5d5e62);
  static const Color surfaceVariant = Color(0xFFe9ecef); // For cards/inputs
  static const Color background = Color(0xFFf8f9fa); // Alias for surface
  static const Color textPrimary = Color(0xFF191c1d); // Alias for onSurface
  static const Color textSecondary = Color(0xFF5d5e62); // Alias for secondary
  static const Color textHint = Color(0xFF9ca3af); // Gray 400
  static const Color primaryLight = Color(0xFFFF9944); // Alias for primaryContainer
  
  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Gradient helper
  static const LinearGradient kineticGradient = LinearGradient(
    colors: [Color(0xFFEE7211), Color(0xFFFF9944)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurface,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.lexend(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w900, // Black
          fontSize: 36,
        ),
        headlineLarge: GoogleFonts.lexend(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.lexend(
          color: AppColors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.lexend(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.secondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.inter(
          color: AppColors.secondary,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lexend(
          color: AppColors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.secondary,
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        side: const BorderSide(color: AppColors.surfaceVariant, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      iconTheme: const IconThemeData(color: AppColors.onSurface, size: 28),
    );
  }
}
