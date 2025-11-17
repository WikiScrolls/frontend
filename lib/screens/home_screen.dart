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
  final _service = ArticleService();
  List<ArticleModel> _articles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.listArticles(page: 1, limit: 5);
      setState(() {
        _articles = result.$1;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Search bar
            Row(
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
            const SizedBox(height: 10),
            // Tabs row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TabChip(label: 'Friends'),
                const SizedBox(width: 12),
                _TabChip(label: 'Following'),
                const SizedBox(width: 12),
                const _TabChip(label: 'For You', selected: true),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Failed to load articles', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 8),
                              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                              const SizedBox(height: 12),
                              ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _articles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 24),
                          padding: const EdgeInsets.only(bottom: 32, top: 8),
                          itemBuilder: (context, i) {
                            final a = _articles[i];
                            return _ArticleCard(article: a);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleModel article;
  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
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
                        style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 14),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaIcon(icon: Icons.favorite, label: article.likeCount.toString()),
                        if (article.createdAt != null)
                          _MetaIcon(icon: Icons.access_time, label: _timeAgo(article.createdAt!)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Action icons
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

