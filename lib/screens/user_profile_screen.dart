import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/profile_service.dart';
import '../api/interaction_service.dart';
import '../api/models/public_profile.dart';
import '../api/models/article.dart';
import '../api/models/pagination.dart';
import '../api/models/user_search_result.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final UserSearchResult? searchResult; // Optional fallback data from search

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.searchResult,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  final _profileService = ProfileService();
  final _interactionService = InteractionService();

  late TabController _tabController;

  PublicProfile? _profile;
  bool _loadingProfile = true;
  String? _profileError;

  List<ArticleModel> _likedArticles = [];
  PaginationInfo? _likedPagination;
  bool _loadingLiked = false;
  String? _likedError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
    _loadLikedArticles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getPublicProfile(widget.userId);
      setState(() {
        _profile = profile;
        _loadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _profileError = e.toString();
        _loadingProfile = false;
      });
    }
  }

  Future<void> _loadLikedArticles({int page = 1}) async {
    if (_loadingLiked) return;

    setState(() {
      _loadingLiked = true;
      if (page == 1) _likedError = null;
    });

    try {
      final (articles, pagination) = await _interactionService.getUserLikedArticles(
        userId: widget.userId,
        page: page,
        limit: 20,
      );
      setState(() {
        if (page == 1) {
          _likedArticles = articles;
        } else {
          _likedArticles.addAll(articles);
        }
        _likedPagination = pagination;
      });
    } catch (e) {
      setState(() => _likedError = e.toString());
    } finally {
      setState(() => _loadingLiked = false);
    }
  }

  void _loadMoreLiked() {
    if (_likedPagination?.hasNextPage == true && !_loadingLiked) {
      _loadLikedArticles(page: _likedPagination!.page + 1);
    }
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Use fallback content if profile failed but we have search result data
    final hasFallback = widget.searchResult != null && _profileError != null;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _profileError != null && !hasFallback
              ? _buildErrorState()
              : hasFallback
                  ? _buildFallbackContent()
                  : _buildContent(),
    );
  }

  Widget _buildFallbackContent() {
    final sr = widget.searchResult!;
    
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          backgroundColor: Colors.black,
          expandedHeight: 280,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                      backgroundImage: sr.avatarUrl != null
                          ? NetworkImage(sr.avatarUrl!)
                          : null,
                      child: sr.avatarUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white54)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Display name
                    Text(
                      sr.displayNameOrUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${sr.username}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Join date
                    Text(
                      _formatJoinDate(sr.createdAt),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    // Bio
                    if (sr.profile?.bio != null && sr.profile!.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        sr.profile!.bio!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.orange,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Liked'),
              Tab(text: 'Interests'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLikedTab(),
          _buildInterestsTab(null),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'User not found',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileError!,
                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          backgroundColor: Colors.black,
          expandedHeight: 280,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white12,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white54)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Display name
                    Text(
                      profile.nameOrUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${profile.user.username}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Join date
                    Text(
                      _formatJoinDate(profile.user.createdAt),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    // Bio
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        profile.bio!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.orange,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Liked'),
              Tab(text: 'Interests'),
            ],
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLikedTab(),
          _buildInterestsTab(),
        ],
      ),
    );
  }

  Widget _buildLikedTab() {
    if (_loadingLiked && _likedArticles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (_likedError != null && _likedArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _likedError!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadLikedArticles(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_likedArticles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'No liked articles yet',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          _loadMoreLiked();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _likedArticles.length + (_loadingLiked ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _likedArticles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
            );
          }
          return _ArticleListTile(article: _likedArticles[index]);
        },
      ),
    );
  }

  Widget _buildInterestsTab([List<String>? overrideInterests]) {
    final interests = overrideInterests ?? _profile?.interests ?? [];

    if (interests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.interests, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'No interests listed',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: interests.map((interest) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.orange.withOpacity(0.3)),
            ),
            child: Text(
              interest,
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ArticleListTile extends StatelessWidget {
  final ArticleModel article;

  const _ArticleListTile({required this.article});

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open: ${article.title}')),
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
                        width: 60,
                        height: 60,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.favorite, size: 12, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          '${article.likeCount}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 60,
        height: 60,
        color: Colors.white12,
        child: const Icon(Icons.article, color: Colors.white24, size: 24),
      );
}
