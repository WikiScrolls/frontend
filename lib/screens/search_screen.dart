import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/search_service.dart';
import '../api/models/article.dart';
import '../api/models/user_search_result.dart';
import '../api/models/pagination.dart';
import 'user_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchType initialType;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialType = SearchType.articles,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum SearchType { articles, users }

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchService = SearchService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late TabController _tabController;
  SearchType _searchType = SearchType.articles;

  // Articles search state
  List<ArticleModel> _articles = [];
  PaginationInfo? _articlesPagination;
  bool _loadingArticles = false;
  String? _articlesError;

  // Users search state
  List<UserSearchResult> _users = [];
  PaginationInfo? _usersPagination;
  bool _loadingUsers = false;
  String? _usersError;

  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialType == SearchType.users ? 1 : 0,
    );
    _tabController.addListener(_onTabChanged);
    _searchType = widget.initialType;

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _searchType = _tabController.index == 0 ? SearchType.articles : SearchType.users;
    });
    // Re-search if we have a query and haven't searched this type yet
    if (_lastQuery.isNotEmpty) {
      if (_searchType == SearchType.articles && _articles.isEmpty && !_loadingArticles) {
        _searchArticles(_lastQuery);
      } else if (_searchType == SearchType.users && _users.isEmpty && !_loadingUsers) {
        _searchUsers(_lastQuery);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    _lastQuery = query.trim();
    
    setState(() {
      _articles = [];
      _users = [];
      _articlesPagination = null;
      _usersPagination = null;
      _articlesError = null;
      _usersError = null;
    });

    if (_searchType == SearchType.articles) {
      _searchArticles(_lastQuery);
    } else {
      _searchUsers(_lastQuery);
    }
  }

  Future<void> _searchArticles(String query, {int page = 1}) async {
    if (_loadingArticles) return;

    setState(() {
      _loadingArticles = true;
      if (page == 1) _articlesError = null;
    });

    try {
      final (articles, pagination) = await _searchService.searchArticles(
        query: query,
        page: page,
        limit: 20,
      );
      setState(() {
        if (page == 1) {
          _articles = articles;
        } else {
          _articles.addAll(articles);
        }
        _articlesPagination = pagination;
      });
    } catch (e) {
      setState(() => _articlesError = e.toString());
    } finally {
      setState(() => _loadingArticles = false);
    }
  }

  Future<void> _searchUsers(String query, {int page = 1}) async {
    if (_loadingUsers) return;

    setState(() {
      _loadingUsers = true;
      if (page == 1) _usersError = null;
    });

    try {
      final (users, pagination) = await _searchService.searchUsers(
        query: query,
        page: page,
        limit: 20,
      );
      setState(() {
        if (page == 1) {
          _users = users;
        } else {
          _users.addAll(users);
        }
        _usersPagination = pagination;
      });
    } catch (e) {
      setState(() => _usersError = e.toString());
    } finally {
      setState(() => _loadingUsers = false);
    }
  }

  void _loadMore() {
    if (_searchType == SearchType.articles) {
      if (_articlesPagination?.hasNextPage == true && !_loadingArticles) {
        _searchArticles(_lastQuery, page: _articlesPagination!.page + 1);
      }
    } else {
      if (_usersPagination?.hasNextPage == true && !_loadingUsers) {
        _searchUsers(_lastQuery, page: _usersPagination!.page + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: widget.initialQuery == null,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: _searchType == SearchType.articles
                ? 'Search articles...'
                : 'Search users...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _articles = [];
                        _users = [];
                        _lastQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'Articles'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildArticlesTab(),
          _buildUsersTab(),
        ],
      ),
    );
  }

  Widget _buildArticlesTab() {
    if (_loadingArticles && _articles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (_articlesError != null && _articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_articlesError',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchArticles(_lastQuery),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'No articles found for "$_lastQuery"',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'Search for articles',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _articles.length + (_loadingArticles ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _articles.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          );
        }
        return _ArticleSearchCard(article: _articles[index]);
      },
    );
  }

  Widget _buildUsersTab() {
    if (_loadingUsers && _users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (_usersError != null && _users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_usersError',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _searchUsers(_lastQuery),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_search, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            Text(
              'No users found for "$_lastQuery"',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: Colors.white54, size: 64),
            SizedBox(height: 16),
            Text(
              'Search for users',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _users.length + (_loadingUsers ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          );
        }
        return _UserSearchCard(
          user: _users[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: _users[index].id),
            ),
          ),
        );
      },
    );
  }
}

class _ArticleSearchCard extends StatelessWidget {
  final ArticleModel article;

  const _ArticleSearchCard({required this.article});

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
          // TODO: Navigate to article detail or show in feed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open article: ${article.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: article.imageUrl != null
                    ? Image.network(
                        article.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (article.displayContent != null)
                      Text(
                        article.displayContent!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (article.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _parseColor(article.category!.color),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              article.category!.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Icon(Icons.favorite, size: 14, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          '${article.likeCount}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.visibility, size: 14, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          '${article.viewCount}',
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

  Widget _placeholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.white12,
      child: const Icon(Icons.article, color: Colors.white24, size: 32),
    );
  }

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

class _UserSearchCard extends StatelessWidget {
  final UserSearchResult user;
  final VoidCallback? onTap;

  const _UserSearchCard({required this.user, this.onTap});

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white12,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white54, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayNameOrUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    if (user.profile?.bio != null && user.profile!.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          user.profile!.bio!,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
