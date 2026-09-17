import 'dart:convert';

class Contact {
  final String id;
  final String name;
  final String vpa;
  final String initials;
  final String category;
  final int avatarColor;
  final String? phone;

  const Contact({
    required this.id,
    required this.name,
    required this.vpa,
    required this.initials,
    required this.category,
    required this.avatarColor,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vpa': vpa,
      'initials': initials,
      'category': category,
      'avatarColor': avatarColor,
      'phone': phone,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      vpa: map['vpa'] ?? '',
      initials: map['initials'] ?? '',
      category: map['category'] ?? 'Recent',
      avatarColor: map['avatarColor'] ?? 0xFF0B57D0,
      phone: map['phone'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Contact.fromJson(String source) =>
      Contact.fromMap(json.decode(source));
}
