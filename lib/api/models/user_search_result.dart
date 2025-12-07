/// User search result with optional profile data
class UserSearchResult {
  final String id;
  final String username;
  final DateTime createdAt;
  final UserSearchProfile? profile;

  const UserSearchResult({
    required this.id,
    required this.username,
    required this.createdAt,
    this.profile,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) => UserSearchResult(
        id: json['id']?.toString() ?? '',
        username: json['username'] ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        profile: json['profile'] != null
            ? UserSearchProfile.fromJson(json['profile'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'createdAt': createdAt.toIso8601String(),
        'profile': profile?.toJson(),
      };

  /// Display name with fallback to username
  String get displayNameOrUsername =>
      profile?.displayName?.isNotEmpty == true ? profile!.displayName! : username;

  /// Avatar URL if available
  String? get avatarUrl => profile?.avatarUrl;
}

class UserSearchProfile {
  final String? displayName;
  final String? bio;
  final String? avatarUrl;

  const UserSearchProfile({
    this.displayName,
    this.bio,
    this.avatarUrl,
  });

  factory UserSearchProfile.fromJson(Map<String, dynamic> json) => UserSearchProfile(
        displayName: json['displayName'],
        bio: json['bio'],
        avatarUrl: json['avatarUrl'],
      );

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };
}
