import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2C1810);      // Dark brown: buttons, active elements
  static const Color primaryMed = Color(0xFF5C3317);   // Medium brown: headings, bold labels
  static const Color primaryWarm = Color(0xFF8B4513);  // Accent brown: links, streak count
  static const Color primaryLight = Color(0xFFD4956A); // Light/disabled brown: disabled buttons, hint text
  
  static const Color background = Color(0xFFF5F0EB);   // Main app background (warm off-white)
  static const Color surface = Color(0xFFFFFFFF);      // Cards, containers, bottom sheets
  static const Color inputBg = Color(0xFFF0EBE5);      // Warm grey: input fields background, tab bar background
  
  static const Color textPrimary = Color(0xFF1A0F0A);    // Main headings, text
  static const Color textSecondary = Color(0xFF6B4C3B);  // Body text, details
  static const Color textHint = Color(0xFFA08070);       // Light captions, placeholders, timestamps
  
  static const Color border = Color(0xFFE8DDD5);       // Outline borders, dividers
  
  static const Color success = Color(0xFF2D6A4F);      // Green: completed habits, streak indicators
  static const Color error = Color(0xFFC0392B);        // Red: destructive actions (e.g. delete note/habit)
}
