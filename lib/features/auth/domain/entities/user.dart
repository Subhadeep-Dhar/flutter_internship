/// Pure Dart domain entity representing an authenticated user in ShopSphere.
class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? image;
  final String? phone;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.image,
    this.phone,
  });

  /// Formatted full name combining first and last names.
  String get fullName => '$firstName $lastName'.trim();

  /// User initials for avatars if an image is not available or fails to load.
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    final combined = '$first$last'.toUpperCase();
    return combined.isNotEmpty
        ? combined
        : (username.isNotEmpty ? username[0].toUpperCase() : '?');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          gender == other.gender &&
          image == other.image &&
          phone == other.phone;

  @override
  int get hashCode => Object.hash(
    id,
    username,
    email,
    firstName,
    lastName,
    gender,
    image,
    phone,
  );

  @override
  String toString() =>
      'User(id: $id, username: $username, email: $email, fullName: $fullName)';
}
