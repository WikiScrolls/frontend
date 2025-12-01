import 'api_client.dart';

// Placeholder comment service - backend doesn't have comment endpoints yet
class CommentService {
  final ApiClient _client;
  CommentService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // Get comments for an article
  Future<List<Map<String, dynamic>>> getComments(String articleId) async {
    // TODO: Implement when backend has comment endpoints
    // For now, return empty list
    return [];
  }

  // Create a comment
  Future<Map<String, dynamic>> createComment({
    required String articleId,
    required String content,
  }) async {
    // TODO: Implement when backend has comment endpoints
    throw UnimplementedError('Comments feature coming soon');
  }

  // Delete a comment
  Future<void> deleteComment(String commentId) async {
    // TODO: Implement when backend has comment endpoints
    throw UnimplementedError('Comments feature coming soon');
  }

  // Get my comments
  Future<List<Map<String, dynamic>>> getMyComments() async {
    // TODO: Implement when backend has comment endpoints
    return [];
  }
}
