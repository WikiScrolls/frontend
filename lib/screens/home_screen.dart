import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/user_profile.dart';
import '../models/article.dart';
import '../models/notification.dart';
import '../services/mock_feed_service.dart';
import '../services/mock_notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _FeedPage(),
      const _NotificationsPage(),
      ProfilePage(profile: UserProfile.instance),
      const _SettingsPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: AppColors.orange.withOpacity(0.15),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  final PageController _pageController = PageController();
  late List<Article> _articles;

  @override
  void initState() {
    super.initState();
    _articles = MockFeedService.instance.getFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleLike(String articleId) {
    setState(() {
      final updated = MockFeedService.instance.toggleLike(articleId);
      final index = _articles.indexWhere((a) => a.id == articleId);
      if (index != -1) {
        _articles[index] = updated;
      }
    });
  }

  void _toggleSave(String articleId) {
    setState(() {
      final updated = MockFeedService.instance.toggleSave(articleId);
      final index = _articles.indexWhere((a) => a.id == articleId);
      if (index != -1) {
        _articles[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search millions of topics...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tabs row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                _TabChip(label: 'Friends'),
                SizedBox(width: 12),
                _TabChip(label: 'Following'),
                SizedBox(width: 12),
                _TabChip(label: 'For You', selected: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Scrollable feed
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _articles.length,
              itemBuilder: (context, index) {
                return _ArticleCard(
                  article: _articles[index],
                  onLike: () => _toggleLike(_articles[index].id),
                  onSave: () => _toggleSave(_articles[index].id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onLike;
  final VoidCallback onSave;

  const _ArticleCard({
    required this.article,
    required this.onLike,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        Image.network(
          article.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[900],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[900],
              child: const Center(
                child: Icon(Icons.broken_image, size: 64, color: Colors.white38),
              ),
            );
          },
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: article.isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(article.likeCount),
                onTap: onLike,
                isActive: article.isLiked,
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatCount(article.commentCount),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments coming soon!')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: article.isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: _formatCount(article.saveCount),
                onTap: onSave,
                isActive: article.isSaved,
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
              ),
            ],
          ),
        ),
        // Bottom content area
        Positioned(
          left: 16,
          right: 80,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(int.parse(article.categoryColor.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                article.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Summary
              Text(
                article.summary,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: article.tags
                    .map((tag) => Text(
                          '#$tag',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.orange : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.orange : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final style = selected
        ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)
        : const TextStyle(color: Colors.white70);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style),
        const Icon(Icons.expand_more, size: 18, color: Colors.white54),
      ],
    );
  }
}

class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage();

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = MockNotificationService.instance.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = MockNotificationService.instance.getUnreadCount();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.lightBrown,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        MockNotificationService.instance.markAllAsRead();
                        _notifications = MockNotificationService.instance.getNotifications();
                      });
                    },
                    child: const Text('Mark all read'),
                  ),
              ],
            ),
          ),
          // Notification list
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 72,
                          color: AppColors.lightBrown.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          setState(() {
                            MockNotificationService.instance.deleteNotification(notification.id);
                            _notifications = MockNotificationService.instance.getNotifications();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification deleted')),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: notification.imageUrl != null
                                ? NetworkImage(notification.imageUrl!)
                                : null,
                            backgroundColor: AppColors.lightBrown.withOpacity(0.2),
                            child: notification.imageUrl == null
                                ? Icon(
                                    _getIconForType(notification.type),
                                    color: AppColors.lightBrown,
                                  )
                                : null,
                          ),
                          title: Text(
                            notification.message,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _formatTimestamp(notification.timestamp),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: !notification.isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () {
                            if (!notification.isRead) {
                              setState(() {
                                MockNotificationService.instance.markAsRead(notification.id);
                                _notifications = MockNotificationService.instance.getNotifications();
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.chat_bubble;
      case 'follow':
        return Icons.person_add;
      case 'article':
        return Icons.article;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

class ProfilePage extends StatefulWidget {
  final UserProfile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _username;
  late TextEditingController _pass1;
  late TextEditingController _pass2;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.profile.username);
    _pass1 = TextEditingController();
    _pass2 = TextEditingController();
  }

  @override
  void dispose() {
    _username.dispose();
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _save() {
    if (_pass1.text != _pass2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() {
      widget.profile.username = _username.text.trim();
      if (_pass1.text.isNotEmpty) {
        widget.profile.password = _pass1.text; // In real app: hash & send to API
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.lightBrown,
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () async {
                  // Placeholder for image picker integration
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker not implemented yet.')),
                  );
                },
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 48, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _fieldLabel('Username'),
            TextField(
              controller: _username,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _fieldLabel('New Password'),
            TextField(
              controller: _pass1,
              obscureText: _obscure1,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Confirm Password'),
            TextField(
              controller: _pass2,
              obscureText: _obscure2,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _save,
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
      );
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();
  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Settings');
  }
}

class _SimpleScaffold extends StatelessWidget {
  final String title;
  const _SimpleScaffold({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              title == 'Notifications'
                  ? Icons.notifications
                  : title == 'Profile'
                      ? Icons.person
                      : Icons.settings,
              size: 72,
              color: AppColors.lightBrown,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('This page is coming soon.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
