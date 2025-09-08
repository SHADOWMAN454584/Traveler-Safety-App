import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.white,

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(textStyle: AppTextStyles.heading1),
        displayMedium: GoogleFonts.poppins(textStyle: AppTextStyles.heading2),
        displaySmall: GoogleFonts.poppins(textStyle: AppTextStyles.heading3),
        bodyLarge: GoogleFonts.poppins(textStyle: AppTextStyles.bodyLarge),
        bodyMedium: GoogleFonts.poppins(textStyle: AppTextStyles.bodyMedium),
        bodySmall: GoogleFonts.poppins(textStyle: AppTextStyles.bodySmall),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(0, 144, 45, 45),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          textStyle: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          elevation: 8,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largeSpacing,
            vertical: AppConstants.mediumSpacing,
          ),
          textStyle: GoogleFonts.poppins(textStyle: AppTextStyles.buttonLarge),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 150, 174, 238),
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largeSpacing,
            vertical: AppConstants.mediumSpacing,
          ),
          textStyle: GoogleFonts.poppins(
            textStyle: AppTextStyles.buttonLarge.copyWith(
              color: const Color.fromARGB(255, 119, 127, 147),
            ),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.mediumSpacing,
            vertical: AppConstants.smallSpacing,
          ),
          textStyle: GoogleFonts.poppins(
            textStyle: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          borderSide: const BorderSide(color: AppColors.dangerRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumSpacing,
          vertical: AppConstants.mediumSpacing,
        ),
        labelStyle: GoogleFonts.poppins(textStyle: AppTextStyles.bodyMedium),
        hintStyle: GoogleFonts.poppins(
          textStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.smallSpacing),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: GoogleFonts.poppins(
          textStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          textStyle: AppTextStyles.bodySmall,
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.panicRed,
        foregroundColor: AppColors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.circularRadius),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius),
        ),
        elevation: 16,
        backgroundColor: AppColors.white,
        titleTextStyle: GoogleFonts.poppins(textStyle: AppTextStyles.heading3),
        contentTextStyle: GoogleFonts.poppins(
          textStyle: AppTextStyles.bodyMedium,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
        space: AppConstants.mediumSpacing,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.darkGray, size: 24),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(color: AppColors.white, size: 24),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPurple,
        surface: AppColors.white,
        error: AppColors.dangerRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onError: AppColors.white,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.black,

      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.poppins(
              textStyle: AppTextStyles.heading1.copyWith(
                color: AppColors.white,
              ),
            ),
            displayMedium: GoogleFonts.poppins(
              textStyle: AppTextStyles.heading2.copyWith(
                color: AppColors.white,
              ),
            ),
            displaySmall: GoogleFonts.poppins(
              textStyle: AppTextStyles.heading3.copyWith(
                color: AppColors.white,
              ),
            ),
            bodyLarge: GoogleFonts.poppins(
              textStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.white,
              ),
            ),
            bodyMedium: GoogleFonts.poppins(
              textStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightGray,
              ),
            ),
            bodySmall: GoogleFonts.poppins(
              textStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryPurple,
        surface: AppColors.darkGray,
        error: AppColors.dangerRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
        brightness: Brightness.dark,
      ),
    );
  }
}
