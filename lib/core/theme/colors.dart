import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler - Ocean & Calm
  static const Color primary = Color(0xFF3F51B5);   
  static const Color secondary = Color(0xFF7986CB);  
  static const Color background = Color(0xFFF8F9FC); 
  
  // Metin renkleri
  static const Color textPrimary = Color(0xFF263238);  
  static const Color textSecondary = Color(0xFF78909C); 
  
  // Durum renkleri - Soft & Clear
  static const Color success = Color(0xFF81C784);    
  static const Color error = Color(0xFFE57373);      
  static const Color warning = Color(0xFFFFB74D);    
  
  // UI elementleri
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE3F2FD);    
  static const Color icon = Color(0xFF78909C);     
  
  // Task durumları
  static const Color completedTask = Color(0xFFE8EAF6);
  static const Color pendingTask = Color(0xFFF3F6FF);  
  
  // Aksan Renkleri - Ocean Theme
  static const Color accent1 = Color(0xFF5C6BC0);    
  static const Color accent2 = Color(0xFF9FA8DA);    
  
  // Gradient Renkleri - Ocean Flow
  static const List<Color> primaryGradient = [
    Color(0xFF3F51B5), 
    Color(0xFF7986CB),  
  ];
  
  // Kategori Renkleri - Ocean Palette
  static const List<Color> categoryColors = [
    Color(0xFF5C6BC0),  
    Color(0xFF7986CB),  
    Color(0xFF64B5F6), 
    Color(0xFF4FC3F7), 
    Color(0xFF9575CD), 
    Color(0xFF7E57C2),  
  ];
    // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkIcon = Color(0xFF9E9E9E);
}