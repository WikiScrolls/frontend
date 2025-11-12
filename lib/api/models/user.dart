class UserModel {
  final String id;
  final String username;
  final String email;
  final bool isAdmin;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        username: json['username'] ?? json['name'] ?? '',
        email: json['email'] ?? '',
        isAdmin: (json['isAdmin'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'isAdmin': isAdmin,
      };
}
