class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profilePic;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profilePic,
    required this.role,
  });

  /// Constructs a [UserModel] from a Firestore document.
  /// [uid] is the document ID (Firebase Auth UID).
  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserModel(
      id: uid,
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      profilePic: data['profilePic'] as String?,
      role: data['role'] as String? ?? 'user',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'profilePic': profilePic,
      'role': role,
    };
  }
}
