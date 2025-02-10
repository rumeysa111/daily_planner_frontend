import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon; // ✅ Backend'den emoji veya string olarak geliyor
  final Color color;
  final String userId; // Yeni eklenen alan

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
  });

  // ✅ JSON'dan `CategoryModel` Nesnesine Çevirme (Backend'den Çekerken)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["_id"],
      name: json["name"],
      icon: json["icon"], // 🔥 Unicode emoji veya string direkt alınır
      color: _hexToColor(json["color"]), // 🔥 HEX kodunu `Color` objesine çevir
      userId: json["userId"] ?? "",
    );
  }

  // ✅ `CategoryModel` Nesnesini JSON'a Çevirme (Backend'e Gönderirken)
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "icon": icon,
      "color":
          "#${color.value.toRadixString(16).substring(2)}", // 🔥 Color'dan HEX String'e dönüştürme
      "userId": userId,
    };
  }

  // ✅ HEX Kodunu Color Nesnesine Çeviren Yardımcı Fonksiyon
  static Color _hexToColor(String hexColor) {
    if (hexColor.startsWith("#")) {
      hexColor = hexColor.substring(1); // `#` işaretini kaldır
    }
    return Color(
        int.parse("0xFF$hexColor")); // HEX kodunu `Color` nesnesine çevir
  }
}
