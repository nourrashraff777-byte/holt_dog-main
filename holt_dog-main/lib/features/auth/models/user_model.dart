class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePic;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePic,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePic: json['profilePic'],
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'role': role,
    };
  }
}
