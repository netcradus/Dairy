import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized Sawariya Dairy Typography System using Google Fonts (Poppins)
abstract class AppTextTheme {
  static TextTheme textTheme(Color textColor, Color secondaryColor) {
    return TextTheme(
      // Display Styles
      displayLarge: GoogleFonts.poppins(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.25,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),

      // Headline Styles
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Title & Subtitle Styles
      titleLarge: GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),

      // Body Styles
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: textColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: secondaryColor,
      ),

      // Label & Button Styles
      labelLarge: GoogleFonts.poppins(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10.0,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  // Pre-configured TextThemes for Light & Dark modes
  static TextTheme lightTextTheme = textTheme(
    AppColors.textPrimary,
    AppColors.textSecondary,
  );

  static TextTheme darkTextTheme = textTheme(
    AppColors.darkTextPrimary,
    AppColors.darkTextSecondary,
  );
}
