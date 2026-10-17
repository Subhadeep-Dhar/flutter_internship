import '../../domain/entities/user.dart';

/// Data transfer model for [User] deserialization.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.gender,
    super.image,
    super.phone,
  });

  /// Defensive JSON deserializer handling missing or null optional fields from DummyJSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      gender: json['gender'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      if (gender != null) 'gender': gender,
      if (image != null) 'image': image,
      if (phone != null) 'phone': phone,
    };
  }
}
