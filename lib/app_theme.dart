// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFD64545);
  static const Color yellowGold = Color(0xFFF7C948);
  static const Color chocolateBrown = Color(0xFF8B5A2B);
  static const Color warmBeige = Color(0xFFFFF4E3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000); // For high contrast text
}

ThemeData buildAppTheme() {
  // Base theme
  final ThemeData base = ThemeData.light();

  // Define text themes
  final TextTheme englishTextTheme = GoogleFonts.poppinsTextTheme(
    base.textTheme,
  );
  final TextTheme urduTextTheme = GoogleFonts.notoNastaliqUrduTextTheme(
    base.textTheme,
  );

  return base.copyWith(
    primaryColor: AppColors.primaryRed,
    scaffoldBackgroundColor: AppColors.warmBeige,

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 2,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.chocolateBrown),
      titleTextStyle: englishTextTheme.titleLarge?.copyWith(
        color: AppColors.chocolateBrown,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryRed,
      unselectedItemColor: AppColors.chocolateBrown.withOpacity(0.7),
      selectedLabelStyle: englishTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: englishTextTheme.labelSmall,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 1,
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: englishTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // Typography
    textTheme: englishTextTheme.copyWith(
      // English Headers
      displayLarge: englishTextTheme.displayLarge?.copyWith(
        color: AppColors.chocolateBrown,
      ),
      displayMedium: englishTextTheme.displayMedium?.copyWith(
        color: AppColors.chocolateBrown,
      ),
      displaySmall: englishTextTheme.displaySmall?.copyWith(
        color: AppColors.chocolateBrown,
      ),
      headlineLarge: englishTextTheme.headlineLarge?.copyWith(
        color: AppColors.chocolateBrown,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: englishTextTheme.headlineMedium?.copyWith(
        color: AppColors.chocolateBrown,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: englishTextTheme.headlineSmall?.copyWith(
        color: AppColors.chocolateBrown,
        fontWeight: FontWeight.bold,
      ),

      // English Body
      bodyLarge: englishTextTheme.bodyLarge?.copyWith(
        color: AppColors.black,
        height: 1.5,
      ),
      bodyMedium: englishTextTheme.bodyMedium?.copyWith(
        color: AppColors.black.withOpacity(0.8),
        height: 1.5,
      ),

      // Urdu Text Style (Example for explicit Urdu text)
      // We create a custom style 'urduTitle' for easy access
      titleMedium: urduTextTheme.titleMedium?.copyWith(
        color: AppColors.chocolateBrown,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      // We create a custom style 'urduBody' for easy access
      bodySmall: urduTextTheme.bodySmall?.copyWith(
        color: AppColors.black.withOpacity(0.8),
        fontSize: 16,
        height: 1.8,
      ),
    ),
  );
}

// Helper widget for bilingual text
class BilingualText extends StatelessWidget {
  final String englishText;
  final String urduText;
  final TextStyle? englishStyle;
  final TextStyle? urduStyle;

  const BilingualText({
    super.key,
    required this.englishText,
    required this.urduText,
    this.englishStyle,
    this.urduStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Define default styles if none are provided
    final finalEnglishStyle =
        englishStyle ?? Theme.of(context).textTheme.labelLarge;
    final finalUrduStyle =
        urduStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(englishText, style: finalEnglishStyle),
        Text(urduText, style: finalUrduStyle),
      ],
    );
  }
}
