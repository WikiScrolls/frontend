import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../api/article_service.dart';
import '../api/pagerank_service.dart';
import '../api/models/article.dart';
import '../state/interaction_state.dart';
import '../state/auth_state.dart';

/// Full-screen article detail view
/// Used when opening an article from search results
class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _isReadMoreLoading = false;
  String? _extendedSummary;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Fetch interaction status for this article
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InteractionState>().fetchInteraction(widget.article.id);
    });
  }

  Future<void> _handleReadMore() async {
    if (_isReadMoreLoading) return;

    if (_isExpanded) {
      setState(() => _isExpanded = false);
      return;
    }

    if (_extendedSummary != null) {
      setState(() => _isExpanded = true);
      return;
    }

    setState(() => _isReadMoreLoading = true);

    try {
      final articleService = ArticleService();
      final pageRankService = PageRankService();
      final authState = context.read<AuthState>();
      final userId = authState.user?.id;

      // Use wikipediaId for the MF recommender API
      final wikipediaId = widget.article.wikipediaId ?? widget.article.id;
      final summary = await articleService.getReadMore(wikipediaId);

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
    final imageUrl = article.imageUrl ??
        "https://picsum.photos/seed/${article.title.hashCode}/900/1600";

    final interactionState = context.watch<InteractionState>();
    final isLiked = interactionState.isLiked(article.id);
    final isSaved = interactionState.isSaved(article.id);
    final isLikePending = interactionState.isLikePending(article.id);
    final isSavePending = interactionState.isSavePending(article.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image
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

          // Dark overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Content (expandable)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _isExpanded && _extendedSummary != null
                              ? _extendedSummary!
                              : (article.displayContent ?? ""),
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                            fontSize: 16,
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
                                color: Colors.white.withValues(alpha: 0.15),
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

                    // Bottom action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Like button
                        _ActionButton(
                          icon: isLiked ? Icons.favorite : Icons.favorite_border,
                          label: 'Like',
                          color: isLiked ? Colors.red : Colors.white,
                          isLoading: isLikePending,
                          onPressed: () {
                            context.read<InteractionState>().toggleLike(article.id);
                          },
                        ),
                        const SizedBox(width: 24),
                        // Read More button
                        _ActionButton(
                          icon: _isExpanded ? Icons.expand_less : Icons.auto_stories,
                          label: _isExpanded ? 'Less' : 'Read More',
                          color: _isExpanded ? AppColors.orange : Colors.white,
                          isLoading: _isReadMoreLoading,
                          onPressed: _handleReadMore,
                        ),
                        const SizedBox(width: 24),
                        // Save button
                        _ActionButton(
                          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                          label: 'Save',
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoading
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
