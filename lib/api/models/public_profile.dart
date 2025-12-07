/// Public profile of a user (for viewing other users)
class PublicProfile {
  final String id;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final List<String> interests;
  final DateTime updatedAt;
  final PublicProfileUser user;

  const PublicProfile({
    required this.id,
    this.displayName,
    this.bio,
    this.avatarUrl,
    required this.interests,
    required this.updatedAt,
    required this.user,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
        id: json['id']?.toString() ?? '',
        displayName: json['displayName'],
        bio: json['bio'],
        avatarUrl: json['avatarUrl'],
        interests: (json['interests'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        updatedAt:
            DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
        user: PublicProfileUser.fromJson(json['user'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'interests': interests,
        'updatedAt': updatedAt.toIso8601String(),
        'user': user.toJson(),
      };

  /// Display name with fallback to username
  String get nameOrUsername => displayName?.isNotEmpty == true ? displayName! : user.username;
}

class PublicProfileUser {
  final String id;
  final String username;
  final DateTime createdAt;

  const PublicProfileUser({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  factory PublicProfileUser.fromJson(Map<String, dynamic> json) => PublicProfileUser(
        id: json['id']?.toString() ?? '',
        username: json['username'] ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'createdAt': createdAt.toIso8601String(),
      };
}
