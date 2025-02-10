// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id;
  final String username;
  final String email;
  String? photoUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.photoUrl,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userID': id,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['userId'] ?? "", // 📌 Eğer `null` gelirse boş string yap
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) {
    final Map<String, dynamic> data = json.decode(source);
    return UserModel.fromMap(data);
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    return 
      other.id == id &&
      other.username == username &&
      other.email == email &&
      other.photoUrl == photoUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      photoUrl.hashCode;
  }
}
