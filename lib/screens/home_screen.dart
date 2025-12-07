import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../api/article_service.dart';
import '../api/pagerank_service.dart';
import '../api/models/article.dart';
import '../state/interaction_state.dart';
import '../state/auth_state.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'search_screen.dart';

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
  int _page = 1;
  final int _limit = 5;
  String? _error;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadImages(List<ArticleModel> articles) async {
  for (final a in articles) {
        final img = Image.network(
        "https://picsum.photos/seed/${a.title.hashCode}/900/1600",
        );

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
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _articles.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            _loadMoreIfNeeded(index);
            // Fetch interaction status for newly visible articles
            if (index < _articles.length) {
              context.read<InteractionState>().fetchInteraction(_articles[index].id);
            }
          },
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
              // Search bar - now tappable
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.white70),
                        SizedBox(width: 12),
                        Text(
                          'Search articles or users…',
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
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

class _FullScreenArticle extends StatefulWidget {
  final ArticleModel article;
  const _FullScreenArticle({required this.article});

  @override
  State<_FullScreenArticle> createState() => _FullScreenArticleState();
}

class _FullScreenArticleState extends State<_FullScreenArticle> {
  bool _isReadMoreLoading = false;
  String? _extendedSummary;
  bool _isExpanded = false;

  Future<void> _handleReadMore() async {
    if (_isReadMoreLoading) return;

    // If already expanded, just toggle back
    if (_isExpanded) {
      setState(() => _isExpanded = false);
      return;
    }

    // If we already have the summary, just expand
    if (_extendedSummary != null) {
      setState(() => _isExpanded = true);
      return;
    }

    setState(() => _isReadMoreLoading = true);

    try {
      final articleService = ArticleService();
      final pageRankService = PageRankService();
      
      // Get user ID for PageRank
      final authState = context.read<AuthState>();
      final userId = authState.user?.id;

      // Use wikipediaId for MF recommender API, fall back to id if not available
      final wikipediaId = widget.article.wikipediaId ?? widget.article.id;
      
      // Fetch extended summary
      final summary = await articleService.getReadMore(wikipediaId);
      
      // Record open in PageRank (fire and forget)
      if (userId != null) {
        pageRankService.recordOpen(articleId: wikipediaId, userId: userId);
      }

      if (mounted) {
        setState(() {
          _extendedSummary = summary;
          _isExpanded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isReadMoreLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    
    // Use actual image URL if available, otherwise use placeholder
    final imageUrl = article.imageUrl ??
        "https://picsum.photos/seed/${article.title.hashCode}/900/1600";

    // Watch interaction state for this article
    final interactionState = context.watch<InteractionState>();
    final isLiked = interactionState.isLiked(article.id);
    final isSaved = interactionState.isSaved(article.id);
    final isLikePending = interactionState.isLikePending(article.id);
    final isSavePending = interactionState.isSavePending(article.id);

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
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.white24, size: 64),
                ),
              ),
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
                // Category chip
                if (article.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _parseColor(article.category!.color),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      article.category!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

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

                // Content / AI Summary (expandable with Read More)
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _isExpanded && _extendedSummary != null
                          ? _extendedSummary!
                          : (article.displayContent ?? ""),
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tags
                if (article.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: article.tags.take(5).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Bottom metadata + buttons
                Row(
                  children: [
                    _MetaIcon(
                      icon: Icons.favorite,
                      label: '${isLiked ? article.likeCount + 1 : article.likeCount}',
                    ),
                    const SizedBox(width: 12),
                    if (article.createdAt != null)
                      _MetaIcon(
                        icon: Icons.access_time,
                        label: _timeAgo(article.createdAt!),
                      ),
                    const Spacer(),
                    // Like button
                    _InteractionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                      isLoading: isLikePending,
                      onPressed: () {
                        context.read<InteractionState>().toggleLike(article.id);
                      },
                    ),
                    // Read More button
                    _InteractionButton(
                      icon: _isExpanded ? Icons.expand_less : Icons.auto_stories,
                      color: _isExpanded ? AppColors.orange : Colors.white,
                      isLoading: _isReadMoreLoading,
                      onPressed: _handleReadMore,
                    ),
                    // Save button
                    _InteractionButton(
                      icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? AppColors.orange : Colors.white,
                      isLoading: isSavePending,
                      onPressed: () {
                        context.read<InteractionState>().toggleSave(article.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.orange;
    try {
      final color = hex.replaceFirst('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (_) {
      return AppColors.orange;
    }
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _InteractionButton({
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          : Icon(icon, color: color),
      onPressed: isLoading ? null : onPressed,
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
    final randomImageUrl =
        "https://picsum.photos/seed/${article.id ?? article.title.hashCode}/500/300";

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
                        randomImageUrl,
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

                    if (article.displayContent != null)
                      Text(
                        article.displayContent!.length > 180
                            ? article.displayContent!.substring(0, 180) + '…'
                            : article.displayContent!,
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

