class UserModel {
  final String? id; // Changed to nullable
  final String username;
  final String name;
  final String email;
  final String role;

  UserModel({
    this.id, // Made optional
    required this.username,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}