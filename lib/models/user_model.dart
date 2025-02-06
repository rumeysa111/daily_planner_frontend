// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime? createdAt;
  final String token;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.createdAt, // 📌 Null olabileceği için opsiyonel yaptık
    required this.token,
    this.updatedAt, // 📌 Null olabileceği için opsiyonel yaptık
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? createdAt,
    String? token,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      token: token ?? this.token,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': id,
      'email': email,
      'name': name,
      'createdAt': createdAt?.toIso8601String(), // 📌 createdAt opsiyonel olduğu için `?` ekledik
      'token': token,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['userId'] ?? "", // 📌 Eğer `null` gelirse boş string yap
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null, // 📌 `tryParse` ile hata önleme
      token: map['token'] ?? '',
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) {
    final Map<String, dynamic> data = json.decode(source);
    return UserModel.fromMap(data);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, createdAt: $createdAt, token: $token, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    return 
      other.id == id &&
      other.email == email &&
      other.name == name &&
      other.createdAt == createdAt &&
      other.token == token &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      token.hashCode ^
      updatedAt.hashCode;
  }
}
