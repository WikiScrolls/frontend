class UserModel {
  final String id;
  final String username;
  final String email;
  final bool isAdmin;
  // Profile fields
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final List<String> interests;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.interests = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle nested profile object if present
    final profile = json['profile'] as Map<String, dynamic>?;
    
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: (json['isAdmin'] as bool?) ?? false,
      displayName: profile?['displayName'] ?? json['displayName'],
      bio: profile?['bio'] ?? json['bio'],
      avatarUrl: profile?['avatarUrl'] ?? json['avatarUrl'],
      interests: (profile?['interests'] ?? json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'isAdmin': isAdmin,
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'interests': interests,
      };
  
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    bool? isAdmin,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? interests,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      interests: interests ?? this.interests,
    );
  }
}
