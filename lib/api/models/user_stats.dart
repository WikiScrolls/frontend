/// User statistics for profile display
class UserStats {
  final String userId;
  final String username;
  final DateTime joinDate;
  final int totalLikes;
  final int totalSaves;
  final int totalViews;

  const UserStats({
    required this.userId,
    required this.username,
    required this.joinDate,
    required this.totalLikes,
    required this.totalSaves,
    required this.totalViews,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        userId: json['userId']?.toString() ?? '',
        username: json['username'] ?? '',
        joinDate: DateTime.tryParse(json['joinDate']?.toString() ?? '') ?? DateTime.now(),
        totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
        totalSaves: (json['totalSaves'] as num?)?.toInt() ?? 0,
        totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'joinDate': joinDate.toIso8601String(),
        'totalLikes': totalLikes,
        'totalSaves': totalSaves,
        'totalViews': totalViews,
      };
}
