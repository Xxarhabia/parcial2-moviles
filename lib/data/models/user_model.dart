import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String hashedPassword;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.hashedPassword,
    required this.createdAt,
  });

  Map<String, dynamic> topMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'hashedPassword': hashedPassword,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'], 
      name: map['name'], 
      email: map['email'], 
      hashedPassword: map['hashedPassword'], 
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => jsonEncode(topMap());
  factory UserModel.fromJson(String source) => 
    UserModel.fromMap(jsonDecode(source));

  UserModel copyWith({String? name, String? email}) {
    return UserModel(
      id: id, 
      name: name ?? this.name, 
      email: email ?? this.email, 
      hashedPassword: hashedPassword, 
      createdAt: createdAt
    );
  }
}