import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const Color primaryNavy = Color(0xFF273469);
  static const Color primaryBlue = Color(0xFF1758E7);
  static const Color secondaryBlue = Color(0xFF0066CC);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E9F2);
  static const Color textSecondary = Color(0xFF8A94A6);
  static const Color textPrimary = Color(0xFF1A1D2E);

  // Status
  static const Color success = Color(0xFF01D47B);
  static const Color error = Color(0xFFE03232);
  static const Color warning = Color(0xFFFF9500);
  static const Color alertRed = Color(0xFFFF3B30);

  // SOS
  static const Color sosRed = Color(0xFFE03232);
  static const Color sosRedDark = Color(0xFFB71C1C);

  // Gradient shades
  static const List<Color> primaryGradient = [secondaryBlue, primaryNavy];
  static const List<Color> navyGradient = [Color(0xFF273469), Color(0xFF1A2456)];
  static const List<Color> authGradient = [
    Color(0xFFCC0000),
    Color(0xFF273469),
    Color(0xFF1758E7),
  ];
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0066CC), Color(0xFF273469)],
  );

  static const LinearGradient auth = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFBB0000),
      Color(0xFF273469),
      Color(0xFF1758E7),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1758E7), Color(0xFF273469)],
  );

  static const LinearGradient statusSafe = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B5BDB), Color(0xFF5C7CFA)],
  );
}

class AppTextStyles {
  // Century Gothic - for headings
  static TextStyle heading1 = const TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle heading2 = const TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle heading3 = const TextStyle(
    fontFamily: 'CenturyGothic',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // Roboto - for body
  static TextStyle bodyLarge = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle labelMedium = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle labelSmall = GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.heading3,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
    );
  }
}
