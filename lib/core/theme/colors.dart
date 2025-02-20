import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler
  static const Color primary = Color(0xFF2196F3);    // Material Blue
  static const Color secondary = Color(0xFF64B5F6);  // Light Blue
  static const Color background = Color(0xFFF5F5F5); // Light Grey Background
  
  // Metin renkleri
  static const Color textPrimary = Color(0xFF2C3E50);   // Koyu metin
  static const Color textSecondary = Color(0xFF95A5A6); // İkincil metin
  
  // Durum renkleri
  static const Color success = Color(0xFF4CAF50);    // Başarı/Tamamlandı
  static const Color error = Color(0xFFE74C3C);      // Hata/Silme
  static const Color warning = Color(0xFFFFA000);    // Uyarı
  
  // UI elementleri
  static const Color cardBackground = Colors.white;   // Kart arkaplanı
  static const Color divider = Color(0xFFE0E0E0);    // Ayraç çizgisi
  static const Color icon = Color(0xFF757575);       // İkon rengi
  
  // Task durumları
  static const Color completedTask = Color(0xFFECECEC); // Tamamlanmış görev
  static const Color pendingTask = Color(0xFFFFF3E0);   // Bekleyen görev
}