import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../state/auth_state.dart';
import '../api/profile_service.dart';
import '../api/interaction_service.dart';
import '../api/models/user_stats.dart';
import '../api/models/article.dart';
import '../api/models/pagination.dart';
import 'article_detail_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _profileService = ProfileService();
  final _interactionService = InteractionService();

  late TabController _tabController;

  UserStats? _stats;
  bool _loadingStats = true;
  String? _statsError;

  List<ArticleModel> _likedArticles = [];
  PaginationInfo? _likedPagination;
  bool _loadingLiked = false;

  List<ArticleModel> _savedArticles = [];
  PaginationInfo? _savedPagination;
  bool _loadingSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
    _loadLikedArticles();
    _loadSavedArticles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _profileService.getMyStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = e.toString();
          _loadingStats = false;
        });
      }
    }
  }

  Future<void> _loadLikedArticles({int page = 1}) async {
    if (_loadingLiked) return;
    setState(() => _loadingLiked = true);

    try {
      final (articles, pagination) =
          await _interactionService.getMyLikedArticles(
        page: page,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          if (page == 1) {
            _likedArticles = articles;
          } else {
            _likedArticles.addAll(articles);
          }
          _likedPagination = pagination;
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      if (mounted) setState(() => _loadingLiked = false);
    }
  }

  Future<void> _loadSavedArticles({int page = 1}) async {
    if (_loadingSaved) return;
    setState(() => _loadingSaved = true);

    try {
      final (articles, pagination) =
          await _interactionService.getMySavedArticles(
        page: page,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          if (page == 1) {
            _savedArticles = articles;
          } else {
            _savedArticles.addAll(articles);
          }
          _savedPagination = pagination;
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
    } finally {
      if (mounted) setState(() => _loadingSaved = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadStats(),
      _loadLikedArticles(),
      _loadSavedArticles(),
    ]);
  }

  Future<void> _showEditBioDialog(BuildContext context) async {
    final authState = context.read<AuthState>();
    final user = authState.user;
    final controller = TextEditingController(text: user?.bio ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Edit Bio', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 150,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tell us about yourself...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child:
                const Text('Save', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );

    if (result != null && result != user?.bio) {
      try {
        // Update bio via API
        await _profileService.updateProfile({'bio': result});

        // Update local user state
        if (user != null) {
          authState.setUser(user.copyWith(bio: result));
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bio updated!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update bio: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final username = user?.username ?? 'Guest';

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.orange,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Centered title
                    Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.lightBrown,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 24),

                    // Avatar
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      child: const Icon(Icons.person,
                          size: 56, color: Colors.white70),
                    ),
                    const SizedBox(height: 16),

                    // Username
                    Text(
                      user?.displayName ?? username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Bio with edit button
                    GestureDetector(
                      onTap: () => _showEditBioDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              user?.bio ?? 'Tap to add a bio...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: user?.bio != null
                                    ? Colors.white70
                                    : Colors.white38,
                                fontSize: 14,
                                fontStyle: user?.bio == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit,
                              size: 14, color: Colors.white38),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.orange,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, size: 18),
                          const SizedBox(width: 8),
                          Text(
                              'Liked${_stats != null ? ' (${_stats!.totalLikes})' : ''}'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmark, size: 18),
                          const SizedBox(width: 8),
                          Text(
                              'Saved${_stats != null ? ' (${_stats!.totalSaves})' : ''}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildArticlesList(
                articles: _likedArticles,
                loading: _loadingLiked,
                pagination: _likedPagination,
                onLoadMore: () {
                  if (_likedPagination?.hasNextPage == true) {
                    _loadLikedArticles(page: _likedPagination!.page + 1);
                  }
                },
                emptyIcon: Icons.favorite_border,
                emptyMessage: 'No liked articles yet',
              ),
              _buildArticlesList(
                articles: _savedArticles,
                loading: _loadingSaved,
                pagination: _savedPagination,
                onLoadMore: () {
                  if (_savedPagination?.hasNextPage == true) {
                    _loadSavedArticles(page: _savedPagination!.page + 1);
                  }
                },
                emptyIcon: Icons.bookmark_border,
                emptyMessage: 'No saved articles yet',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    if (_loadingStats) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.orange, strokeWidth: 2),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatItem(
          count: _stats?.totalLikes.toString() ?? '0',
          label: 'Likes',
          icon: Icons.favorite,
        ),
        Container(
          width: 1,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: Colors.white24,
        ),
        _StatItem(
          count: _stats?.totalSaves.toString() ?? '0',
          label: 'Saved',
          icon: Icons.bookmark,
        ),
        Container(
          width: 1,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: Colors.white24,
        ),
        _StatItem(
          count: _stats?.totalViews.toString() ?? '0',
          label: 'Views',
          icon: Icons.visibility,
        ),
      ],
    );
  }

  Widget _buildArticlesList({
    required List<ArticleModel> articles,
    required bool loading,
    required PaginationInfo? pagination,
    required VoidCallback onLoadMore,
    required IconData emptyIcon,
    required String emptyMessage,
  }) {
    if (loading && articles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start exploring to add articles here!',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + (loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
            );
          }
          return _ProfileArticleCard(article: articles[index]);
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.orange),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ProfileArticleCard extends StatelessWidget {
  final ArticleModel article;

  const _ProfileArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(article: article),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (article.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _parseColor(article.category!.color),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category!.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.favorite,
                            size: 12, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          '${article.likeCount}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.visibility,
                            size: 12, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          '${article.viewCount}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 70,
        height: 70,
        color: Colors.white12,
        child: const Icon(Icons.article, color: Colors.white24, size: 28),
      );

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppColors.orange.withOpacity(0.5);
    try {
      final color = hex.replaceFirst('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (_) {
      return AppColors.orange.withOpacity(0.5);
    }
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
