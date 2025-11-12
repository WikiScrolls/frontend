import '../models/notification.dart';

class MockNotificationService {
  static final MockNotificationService instance = MockNotificationService._();
  MockNotificationService._();

  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      type: 'like',
      message: 'Sarah Johnson liked your comment on "Quantum Computing Revolution"',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      type: 'follow',
      message: 'Alex Martinez started following you',
      imageUrl: 'https://i.pravatar.cc/150?img=12',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      type: 'article',
      message: 'New article in Technology: "The Future of AI and Machine Learning"',
      imageUrl: 'https://picsum.photos/seed/notification1/150/150',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    AppNotification(
      id: '4',
      type: 'comment',
      message: 'David Chen replied to your comment: "This is fascinating! Thanks for sharing..."',
      imageUrl: 'https://i.pravatar.cc/150?img=33',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    AppNotification(
      id: '5',
      type: 'like',
      message: 'Emma Wilson and 12 others liked "Ancient Roman Architecture"',
      imageUrl: 'https://i.pravatar.cc/150?img=5',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AppNotification(
      id: '6',
      type: 'article',
      message: 'Your saved article "Deep Sea Exploration" has been updated',
      imageUrl: 'https://picsum.photos/seed/notification2/150/150',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      isRead: true,
    ),
    AppNotification(
      id: '7',
      type: 'follow',
      message: 'James Taylor and 5 others started following you',
      imageUrl: 'https://i.pravatar.cc/150?img=52',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    AppNotification(
      id: '8',
      type: 'comment',
      message: 'Sophia Lee commented on your post: "Great analysis on climate change!"',
      imageUrl: 'https://i.pravatar.cc/150?img=20',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  List<AppNotification> getNotifications({bool? unreadOnly}) {
    if (unreadOnly == true) {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return List.from(_notifications);
  }

  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
  }
}
