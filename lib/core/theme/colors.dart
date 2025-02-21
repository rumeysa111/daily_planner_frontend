import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler - Ocean & Calm
  static const Color primary = Color(0xFF3F51B5);    // Indigo Blue
  static const Color secondary = Color(0xFF7986CB);  // Light Indigo
  static const Color background = Color(0xFFF8F9FC); // Cool White
  
  // Metin renkleri
  static const Color textPrimary = Color(0xFF263238);   // Deep Blue Gray
  static const Color textSecondary = Color(0xFF78909C); // Blue Gray
  
  // Durum renkleri - Soft & Clear
  static const Color success = Color(0xFF81C784);    // Soft Green
  static const Color error = Color(0xFFE57373);      // Soft Red
  static const Color warning = Color(0xFFFFB74D);    // Soft Orange
  
  // UI elementleri
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE3F2FD);    // Light Blue Gray
  static const Color icon = Color(0xFF78909C);       // Blue Gray
  
  // Task durumları
  static const Color completedTask = Color(0xFFE8EAF6); // Light Indigo Tint
  static const Color pendingTask = Color(0xFFF3F6FF);   // Softest Blue
  
  // Aksan Renkleri - Ocean Theme
  static const Color accent1 = Color(0xFF5C6BC0);    // Medium Indigo
  static const Color accent2 = Color(0xFF9FA8DA);    // Light Indigo
  
  // Gradient Renkleri - Ocean Flow
  static const List<Color> primaryGradient = [
    Color(0xFF3F51B5),  // Indigo
    Color(0xFF7986CB),  // Light Indigo
  ];
  
  // Kategori Renkleri - Ocean Palette
  static const List<Color> categoryColors = [
    Color(0xFF5C6BC0),  // Medium Indigo
    Color(0xFF7986CB),  // Light Indigo
    Color(0xFF64B5F6),  // Blue
    Color(0xFF4FC3F7),  // Light Blue
    Color(0xFF9575CD),  // Deep Purple Light
    Color(0xFF7E57C2),  // Deep Purple
  ];
}