import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color gainrGreen = Color(0xFF00E676); // Vibrant Green
  static const Color gainrBlue = Color(0xFF2979FF); // Accent Blue
  static const Color neonOrange = Color(0xFFFF6600); // Terminal Accent
  static const Color darkBackground =
      Color(0xFF000000); // True Black for Terminal
  static const Color cardBackground = Color(0xFF111111); // Deep Dark
  static const Color surfaceColor = Color(0xFF1A1A1A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDisabled = Color(0xFF666666);

  // Semantic Colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2979FF);

  // Web3 Neon Accents
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonMagenta = Color(0xFFFF006E);
  static const Color neonGreen = Color(0xFF39FF14);

  // Animation Constants
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);
  static const Curve animCurve = Curves.easeOutCubic;

  // Gradient Presets
  static const List<Color> primaryGlow = [gainrGreen, neonCyan];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: neonOrange,
      colorScheme: const ColorScheme.dark(
        primary: neonOrange,
        secondary: gainrGreen,
        surface: cardBackground,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
    );
  }
}

// Helper classes for cleaner UI code
class AppColors {
  static const Color neonOrange = AppTheme.neonOrange;
  static const Color neonGreen = AppTheme.gainrGreen;
  static const Color neonCyan = AppTheme.neonCyan;
  static const Color neonMagenta = AppTheme.neonMagenta;
  static const Color black = AppTheme.darkBackground;
  static const Color darkGray = AppTheme.cardBackground;
  static const Color success = AppTheme.success;
  static const Color error = AppTheme.error;
}

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        color: Colors.white,
      );
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white70,
      );
}
