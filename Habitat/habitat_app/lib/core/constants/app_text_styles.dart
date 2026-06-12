import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final textTheme = TextTheme(
    headlineLarge: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
    titleLarge: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: AppColors.textSecondary),
    bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
    bodySmall: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textHint),
  );
}
