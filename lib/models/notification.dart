class AppNotification {
  final String id;
  final String type; // 'like', 'comment', 'follow', 'article'
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? type,
    String? message,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
