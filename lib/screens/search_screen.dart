import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/search_service.dart';
import '../api/models/article.dart';
import '../api/models/user.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchService = SearchService();
  late TabController _tabController;
  
  List<ArticleModel> _articleResults = [];
  List<UserModel> _userResults = [];
  bool _loading = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _articleResults = [];
        _userResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final articles = await _searchService.searchArticles(query);
      final users = await _searchService.searchUsers(query);
      
      setState(() {
        _articleResults = articles;
        _userResults = users;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search articles and users...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: _performSearch,
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: 'Articles (${_articleResults.length})'),
            Tab(text: 'Users (${_userResults.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      Text('Error: $_error', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                )
              : !_hasSearched
                  ? _buildInitialState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildArticleResults(),
                        _buildUserResults(),
                      ],
                    ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search, color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text(
            'Search for articles and users',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleResults() {
    if (_articleResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.article_outlined, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text('No articles found', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _articleResults.length,
      itemBuilder: (context, index) {
        final article = _articleResults[index];
        return _ArticleSearchCard(article: article);
      },
    );
  }

  Widget _buildUserResults() {
    if (_userResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text('No users found', style: TextStyle(color: Colors.white54)),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Try searching for your username or try searching for articles!',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        return _UserSearchCard(user: user);
      },
    );
  }
}

class _ArticleSearchCard extends StatelessWidget {
  final ArticleModel article;
  const _ArticleSearchCard({required this.article});

  @override
  Widget build(BuildContext context) {
    final imageUrl = "https://picsum.photos/seed/${article.title.hashCode}/400/250";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (article.content != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    article.content!.length > 120
                        ? '${article.content!.substring(0, 120)}...'
                        : article.content!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text('${article.likeCount}', style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserSearchCard extends StatelessWidget {
  final UserModel user;
  const _UserSearchCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.orange.withOpacity(0.2),
          child: Text(
            user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.username, style: const TextStyle(color: Colors.white)),
        subtitle: Text(user.email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Follow feature coming soon')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: const Text('Follow'),
        ),
      ),
    );
  }
}
