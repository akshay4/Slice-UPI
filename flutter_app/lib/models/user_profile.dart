import 'dart:convert';

class UserProfile {
  final String phone;
  final String name;
  final String upiId;
  final String businessName;
  final bool isMerchant;

  const UserProfile({
    required this.phone,
    required this.name,
    required this.upiId,
    this.businessName = '',
    this.isMerchant = false,
  });

  String get displayName => businessName.isNotEmpty ? businessName : name;

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'upiId': upiId,
      'businessName': businessName,
      'isMerchant': isMerchant,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      upiId: map['upiId'] ?? '',
      businessName: map['businessName'] ?? '',
      isMerchant: map['isMerchant'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source));
}
