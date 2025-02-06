import 'dart:convert';

class TodoModel {
  final String id;
  final String title;
  final String category;
  final DateTime? dueDate;
  final String color;
  final String? notes;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.category,
    this.dueDate,
    required this.color,
    this.notes,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
  });

  // 📌 JSON'dan `TodoModel` Nesnesine Çevirme
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['_id'] ?? json['id'] ?? '', // ✅ `_id` ile `id` desteklendi
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null, // ✅ Null güvenliği
      color: json['color'] ?? '#000000',
      notes: json['notes'], // ✅ `null` olabilir, hata vermez
      isCompleted: json['isCompleted'] ?? false,
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // 📌 `TodoModel` Nesnesini JSON'a Çevirme
  Map<String, dynamic> toJson() {
    return {
      // ✅ `_id`'yi göndermiyoruz çünkü MongoDB bunu otomatik atıyor!
      "title": title,
      "category": category,
      "dueDate": dueDate?.toIso8601String(), // ✅ `null` olursa hata vermez
      "color": color,
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
    String? category,
    DateTime? dueDate,
    String? color,
    String? notes,
    bool? isCompleted,
    String? userId,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, category: $category, dueDate: $dueDate, color: $color, notes: $notes, isCompleted: $isCompleted, userId: $userId, createdAt: $createdAt)';
  }
}
