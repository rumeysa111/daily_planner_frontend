import 'dart:convert';

import 'category_model.dart';

class TodoModel {
  final String id; // MongoDB ObjectId
  final String title;
  final String categoryId; // Kategori ID olarak tutuluyor
  final CategoryModel? category; // İlişkili kategori nesnesi
  final DateTime? dueDate;
  final String? time;
  final String? notes;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.categoryId, // Backend ID formatına uyumlu
    this.category, // Kategori nesnesi isteğe bağlı
    this.dueDate,
    this.time,
    this.notes,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  // 📌 JSON'dan `TodoModel` Nesnesine Çevirme
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    var categoryData = json['category'];
    return TodoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      categoryId:
          categoryData is Map ? categoryData['_id'] : (categoryData ?? ''),
      category: categoryData is Map
          ? CategoryModel.fromJson(Map<String, dynamic>.from(categoryData))
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate']).toLocal()
          : null,
      time: json['time'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

// 📌 `TodoModel` Nesnesini JSON'a Çevirme
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "category": categoryId, // Kategori ID olarak gönderilecek
      "dueDate": dueDate?.toUtc().toIso8601String(), // UTC'ye çevirerek gönder
      "time": time,
      "notes": notes,
      "isCompleted": isCompleted,
      "userId": userId,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  // 📌 JSON Listesini `List<TodoModel>` Nesnesine Çevirme
  static List<TodoModel> fromJsonList(String jsonString) {
    final List<dynamic> data = json.decode(jsonString);
    return data.map((todoJson) => TodoModel.fromJson(todoJson)).toList();
  }

  // 📌 `copyWith()` Metodu (Immutable Güncelleme İçin)
  TodoModel copyWith({
    String? id,
    String? title,
    String? categoryId,
    CategoryModel? category,
    DateTime? dueDate,
    String? time,
    String? notes,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, category: $categoryId, dueDate: $dueDate, notes: $notes, isCompleted: $isCompleted, userId: $userId, createdAt: $createdAt)';
  }
}
