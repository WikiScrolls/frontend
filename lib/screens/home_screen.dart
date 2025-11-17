import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/article_service.dart';
import '../api/models/article.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';

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
      const NotificationsPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: AppColors.orange.withOpacity(0.15),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.notifications_none),
              selectedIcon: Icon(Icons.notifications),
              label: 'Notifications'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
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
  final _service = ArticleService();
  List<ArticleModel> _articles = [];
  bool _loading = false;
  bool _end = false;
  int _page = 1;
  final int _limit = 5;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _preloadImages(List<ArticleModel> articles) async {
    for (final a in articles) {
      final img = Image.network(a.thumbnail?.isNotEmpty == true
          ? a.thumbnail!
          : "https://picsum.photos/seed/${a.id}/900/1600");

      await precacheImage(img.image, context);
    }
  }

  Future<void> _fetch() async {
    if (_loading || _end) return;

    setState(() => _loading = true);

    try {
      final result = await _service.listArticles();
      final newData = result.$1;

      if (newData.isEmpty) {
        _end = true;
      } else {
        _articles.addAll(newData);

        // ---- PRELOAD IMAGES HERE ----
        _preloadImages(newData);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loadMoreIfNeeded(int index) {
    if (index >= _articles.length - 2 && !_loading && !_end) {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _articles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null && _articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Failed to load articles",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _fetch, child: const Text("Retry")),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // FULL-SCREEN SWIPE FEED (TikTok style)
        PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _articles.length,
          onPageChanged: _loadMoreIfNeeded,
          itemBuilder: (context, i) {
            return _FullScreenArticle(article: _articles[i]);
          },
        ),

        // ----- OVERLAY UI (Search + Tabs) -----
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      hintText: "Search millions of topics…",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _TabChip(label: "Friends"),
                  SizedBox(width: 12),
                  _TabChip(label: "Following"),
                  SizedBox(width: 12),
                  _TabChip(label: "For You", selected: true),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _FullScreenArticle extends StatelessWidget {
  final ArticleModel article;
  const _FullScreenArticle({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.thumbnail?.isNotEmpty == true
        ? article.thumbnail!
        : "https://picsum.photos/seed/${article.id}/900/1600";

    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // ---- FULL SCREEN IMAGE ----
          Positioned.fill(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),

          // ---- DARK OVERLAY FOR READABILITY ----
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // ---- TEXT + ACTIONS ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3), // a bit of tint
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Content
                      Text(
                        article.content ?? "",
                        maxLines: 14,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Shared utilities
String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

class _ArticleCard extends StatelessWidget {
  final ArticleModel article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.thumbnail?.isNotEmpty == true
        ? article.thumbnail!
        : "https://picsum.photos/seed/${article.id}/900/1600";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- NEW IMAGE HERE ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imageUrl,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),

                    if (article.content != null)
                      Text(
                        article.content!.length > 180
                            ? article.content!.substring(0, 180) + '…'
                            : article.content!,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaIcon(
                          icon: Icons.favorite,
                          label: article.likeCount.toString(),
                        ),
                        if (article.createdAt != null)
                          _MetaIcon(
                            icon: Icons.access_time,
                            label: _timeAgo(article.createdAt!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _ActionIcon(icon: Icons.favorite_border),
                  SizedBox(height: 12),
                  _ActionIcon(icon: Icons.chat_bubble_outline),
                  SizedBox(height: 12),
                  _ActionIcon(icon: Icons.bookmark_border),
                  SizedBox(height: 12),
                  _ActionIcon(icon: Icons.send_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _MetaIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54)),
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }
}

// _TagChip removed (unused after integrating real feed)
// Old stub pages (_NotificationsPage, old ProfilePage, _SettingsPage, _SimpleScaffold) removed; using standalone pages now
