import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const surfaceDim = Color(0xFF0E0E0E);
  static const surfaceContainerLow = Color(0xFF131313);
  static const surfaceContainerLowest = Color(0xFF191919);
  static const surfaceContainer = Color(0xFF1A1A1A);
  static const surfaceContainerHigh = Color(0xFF20201F);
  static const surfaceContainerHighest = Color(0xFF262626);
  static const surfaceBright = Color(0xFF2C2C2C);
  
  static const primary = Color(0xFF69DAFF);
  static const primaryDim = Color(0xFF00C0EA);
  static const secondary = Color(0xFF6BFE9C);
  static const tertiary = Color(0xFFD277FF);

  static const orange = Color(0xFFFFA726);
  static const teal = Color(0xFF26A69A);
  static const green = Color(0xFF66BB6A);
  
  static const onSurface = Color(0xFFFFFFFF);
  static const onSurfaceVariant = Color(0xFFADAAAA);
  static const outlineVariant = Color(0x26484847); // 15% opacity как в гайде
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceDim,
      
      // Настройка Space Grotesk для заголовков
      textTheme: TextTheme(
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurfaceVariant,
        ),
        bodySmall: GoogleFonts.firaCode( // Для кода
          fontSize: 13,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}