import 'package:wikiscrolls_frontend/api/models/article.dart';
import 'package:wikiscrolls_frontend/api/models/user.dart';
import 'package:wikiscrolls_frontend/api/models/pagination.dart';

/// Factory class for creating mock data objects for testing
class MockDataFactory {
  /// Creates a mock ArticleModel with default or custom values
  static ArticleModel createArticle({
    String? id,
    String? title,
    String? content,
    int? likeCount,
    DateTime? createdAt,
  }) {
    return ArticleModel(
      id: id ?? 'article-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Test Article',
      content: content ?? 'Test content for article',
      likeCount: likeCount ?? 0,
      createdAt: createdAt ?? DateTime.now(),
    );
  }

  /// Creates a list of mock ArticleModels
  static List<ArticleModel> createArticles(int count) {
    return List.generate(
      count,
      (index) => createArticle(
        id: 'article-$index',
        title: 'Test Article $index',
        content: 'Content for article $index',
        likeCount: index * 10,
      ),
    );
  }

  /// Creates a mock UserModel with default or custom values
  static UserModel createUser({
    String? id,
    String? username,
    String? email,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? 'user-${DateTime.now().millisecondsSinceEpoch}',
      username: username ?? 'testuser',
      email: email ?? 'test@example.com',
      isAdmin: isAdmin ?? false,
    );
  }

  /// Creates an admin UserModel
  static UserModel createAdminUser({
    String? id,
    String? username,
    String? email,
  }) {
    return createUser(
      id: id,
      username: username ?? 'adminuser',
      email: email ?? 'admin@example.com',
      isAdmin: true,
    );
  }

  /// Creates a mock PaginationInfo with default or custom values
  static PaginationInfo createPagination({
    int? page,
    int? limit,
    int? totalItems,
    int? totalPages,
  }) {
    final itemCount = totalItems ?? 100;
    final itemsPerPage = limit ?? 10;
    
    return PaginationInfo(
      page: page ?? 1,
      limit: itemsPerPage,
      totalItems: itemCount,
      totalPages: totalPages ?? (itemCount / itemsPerPage).ceil(),
    );
  }

  /// Creates a mock API response map for successful operations
  static Map<String, dynamic> createSuccessResponse({
    required Map<String, dynamic> data,
    String? message,
  }) {
    return {
      'success': true,
      'data': data,
      if (message != null) 'message': message,
    };
  }

  /// Creates a mock API response map for error operations
  static Map<String, dynamic> createErrorResponse({
    required String message,
    List<Map<String, String>>? errors,
  }) {
    return {
      'success': false,
      'message': message,
      if (errors != null) 'errors': errors,
    };
  }

  /// Creates validation error response
  static Map<String, dynamic> createValidationErrorResponse(
    List<String> errorMessages,
  ) {
    return {
      'success': false,
      'errors': errorMessages.map((msg) => {'message': msg}).toList(),
    };
  }
}
