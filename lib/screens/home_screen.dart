import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../api/article_service.dart';
import '../api/models/article.dart';
import '../api/interaction_service.dart';
import '../state/auth_state.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'search_screen.dart';
import 'friends_list_screen.dart';
import 'following_list_screen.dart';

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
  bool _loading = false;
  bool _end = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _preloadImages(List<ArticleModel> articles) async {
  for (final a in articles) {
        final img = Image.network(
        "https://picsum.photos/seed/${a.title.hashCode}/900/1600",
        );

        await precacheImage(img.image, context);
    }
    }


  Future<void> _fetch({bool refresh = false}) async {
    if (_loading || (_end && !refresh)) return;

    setState(() {
      _loading = true;
      if (refresh) {
        _articles.clear();
        _end = false;
        _error = null;
      }
    });

    try {
        // Get userId from AuthState
        final authState = context.read<AuthState>();
        final userId = authState.user?.id;
        
        // Fetch articles from Gorse recommendation API
        final result = await _service.listArticles(userId: userId, limit: 10);
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

  Future<void> _refreshArticles() async {
    await _fetch(refresh: true);
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
            const Text("Failed to load articles", style: TextStyle(color: Colors.white70)),
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
            final authState = context.watch<AuthState>();
            return _FullScreenArticle(
              article: _articles[i],
              userId: authState.user?.id,
            );
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
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white12,
                        hintText: "Search millions of topics…",
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FriendsListScreen()),
                      );
                    },
                    child: const _TabChip(label: "Friends"),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FollowingListScreen()),
                      );
                    },
                    child: const _TabChip(label: "Following"),
                  ),
                  const SizedBox(width: 12),
                  const _TabChip(label: "For You", selected: true),
                ],
              )
            ],
          ),
        ),

        // ----- FLOATING REFRESH BUTTON -----
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white24,
            onPressed: _refreshArticles,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _FullScreenArticle extends StatefulWidget {
  final ArticleModel article;
  final String? userId;
  const _FullScreenArticle({required this.article, this.userId});

  @override
  State<_FullScreenArticle> createState() => _FullScreenArticleState();
}

class _FullScreenArticleState extends State<_FullScreenArticle> {
  final _interactionService = InteractionService();
  final _articleService = ArticleService();
  bool _isLiked = false;
  bool _isSaved = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkInteractions();
    _recordView();
  }

  Future<void> _recordView() async {
    // Record view to Gorse if userId is available
    if (widget.userId != null) {
      try {
        await _articleService.recordView(widget.article.id, widget.userId!);
      } catch (e) {
        // Silently fail
      }
    }
  }

  Future<void> _checkInteractions() async {
    try {
      final liked = await _interactionService.hasInteraction(widget.article.id, type: 'LIKE');
      final saved = await _interactionService.hasInteraction(widget.article.id, type: 'SAVE');
      if (mounted) {
        setState(() {
          _isLiked = liked;
          _isSaved = saved;
        });
      }
    } catch (e) {
      // Silently fail - user might not be logged in
    }
  }

  Future<void> _toggleLike() async {
    if (_loading || widget.userId == null) return;
    setState(() => _loading = true);
    
    try {
      final newState = await _interactionService.toggleLike(widget.article.id, widget.userId!, _isLiked);
      if (mounted) {
        setState(() {
          _isLiked = newState;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to like: $e')),
        );
      }
    }
  }

  Future<void> _toggleSave() async {
    if (_loading || widget.userId == null) return;
    setState(() => _loading = true);
    
    try {
      final newState = await _interactionService.toggleSave(widget.article.id, widget.userId!, _isSaved);
      if (mounted) {
        setState(() {
          _isSaved = newState;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  void _showComments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        "https://picsum.photos/seed/${widget.article.title.hashCode}/900/1600";

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.article.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Content
                Text(
                  widget.article.content ?? "",
                  maxLines: 14,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                    fontSize: 17,
                  ),
                ),

                const Spacer(),

                // Bottom metadata + buttons
                Row(
                  children: [
                    _MetaIcon(icon: Icons.favorite, label: widget.article.likeCount.toString()),
                    const SizedBox(width: 12),
                    if (widget.article.createdAt != null)
                      _MetaIcon(
                        icon: Icons.access_time,
                        label: _timeAgo(widget.article.createdAt!),
                      ),
                    const Spacer(),
                    IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? AppColors.orange : Colors.white,
                        ),
                        onPressed: _toggleLike),
                    IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        onPressed: _showComments),
                    IconButton(
                        icon: Icon(
                          _isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: _isSaved ? AppColors.orange : Colors.white,
                        ),
                        onPressed: _toggleSave),
                  ],
                ),
              ],
            ),
          ),
        ],
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
