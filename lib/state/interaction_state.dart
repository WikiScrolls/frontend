import 'package:flutter/foundation.dart';
import '../api/interaction_service.dart';
import '../api/pagerank_service.dart';
import '../api/models/interaction_check.dart';

/// State management for article interactions (like/save)
/// Supports optimistic updates for a snappy UI experience
class InteractionState extends ChangeNotifier {
  final InteractionService _service;
  final PageRankService _pageRankService;
  String? _userId; // Set this when user logs in

  InteractionState({InteractionService? service, PageRankService? pageRankService})
      : _service = service ?? InteractionService(),
        _pageRankService = pageRankService ?? PageRankService();

  /// Set the current user ID (needed for PageRank calls)
  void setUserId(String? userId) {
    _userId = userId;
  }

  // Cache of interaction states: articleId -> InteractionCheck
  final Map<String, InteractionCheck> _cache = {};

  // Set of article IDs currently being updated (to prevent duplicate requests)
  final Set<String> _pendingLikes = {};
  final Set<String> _pendingSaves = {};

  /// Get cached interaction status for an article
  InteractionCheck? getCached(String articleId) => _cache[articleId];

  /// Check if article is liked (from cache)
  bool isLiked(String articleId) => _cache[articleId]?.liked ?? false;

  /// Check if article is saved (from cache)
  bool isSaved(String articleId) => _cache[articleId]?.saved ?? false;

  /// Check if a like operation is pending
  bool isLikePending(String articleId) => _pendingLikes.contains(articleId);

  /// Check if a save operation is pending
  bool isSavePending(String articleId) => _pendingSaves.contains(articleId);

  /// Fetch interaction status from API and cache it
  Future<InteractionCheck> fetchInteraction(String articleId) async {
    try {
      final check = await _service.checkInteraction(articleId);
      _cache[articleId] = check;
      notifyListeners();
      return check;
    } catch (e) {
      if (kDebugMode) {
        print('[InteractionState] Error fetching interaction: $e');
      }
      rethrow;
    }
  }

  /// Batch fetch interactions for multiple articles
  Future<void> fetchInteractions(List<String> articleIds) async {
    for (final id in articleIds) {
      if (!_cache.containsKey(id)) {
        try {
          await fetchInteraction(id);
        } catch (e) {
          // Continue with other articles even if one fails
          if (kDebugMode) {
            print('[InteractionState] Error fetching interaction for $id: $e');
          }
        }
      }
    }
  }

  /// Toggle like status with optimistic update
  Future<void> toggleLike(String articleId) async {
    if (_pendingLikes.contains(articleId)) return; // Prevent duplicate requests

    final currentState = _cache[articleId] ?? const InteractionCheck(liked: false, saved: false);
    final newLiked = !currentState.liked;

    // Optimistic update
    _pendingLikes.add(articleId);
    _cache[articleId] = currentState.copyWith(liked: newLiked);
    notifyListeners();

    try {
      if (newLiked) {
        await _service.likeArticle(articleId);
        // Also record like in PageRank service for recommendation weights
        if (_userId != null) {
          // Fire and forget - don't await to keep UI responsive
          _pageRankService.recordLike(articleId: articleId, userId: _userId!);
        }
      } else {
        await _service.unlikeArticle(articleId);
      }
    } catch (e) {
      // Rollback on error
      _cache[articleId] = currentState;
      if (kDebugMode) {
        print('[InteractionState] Error toggling like: $e');
      }
      rethrow;
    } finally {
      _pendingLikes.remove(articleId);
      notifyListeners();
    }
  }

  /// Toggle save status with optimistic update
  Future<void> toggleSave(String articleId) async {
    if (_pendingSaves.contains(articleId)) return; // Prevent duplicate requests

    final currentState = _cache[articleId] ?? const InteractionCheck(liked: false, saved: false);
    final newSaved = !currentState.saved;

    // Optimistic update
    _pendingSaves.add(articleId);
    _cache[articleId] = currentState.copyWith(saved: newSaved);
    notifyListeners();

    try {
      if (newSaved) {
        await _service.saveArticle(articleId);
      } else {
        await _service.unsaveArticle(articleId);
      }
    } catch (e) {
      // Rollback on error
      _cache[articleId] = currentState;
      if (kDebugMode) {
        print('[InteractionState] Error toggling save: $e');
      }
      rethrow;
    } finally {
      _pendingSaves.remove(articleId);
      notifyListeners();
    }
  }

  /// Set interaction state directly (useful for pre-populating from API responses)
  void setInteraction(String articleId, {bool? liked, bool? saved}) {
    final current = _cache[articleId] ?? const InteractionCheck(liked: false, saved: false);
    _cache[articleId] = InteractionCheck(
      liked: liked ?? current.liked,
      saved: saved ?? current.saved,
    );
    notifyListeners();
  }

  /// Clear all cached interactions
  void clearCache() {
    _cache.clear();
    notifyListeners();
  }

  /// Remove a specific article from cache
  void removeFromCache(String articleId) {
    _cache.remove(articleId);
    notifyListeners();
  }
}
