// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon; 
  final Color color;
  final String userId; 

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.userId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["_id"],
      name: json["name"],
      icon: json["icon"], 
      color: _hexToColor(json["color"]), 
      userId: json["userId"] ?? "",
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "icon": icon,
      "color":
          "#${color.value.toRadixString(16).substring(2)}",
      "userId": userId,
    };
  }

  static Color _hexToColor(String hexColor) {
    if (hexColor.startsWith("#")) {
      hexColor = hexColor.substring(1);
    }
    return Color(
        int.parse("0xFF$hexColor")); 
  }
}
