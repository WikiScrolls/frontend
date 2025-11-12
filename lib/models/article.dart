class Article {
  final String id;
  final String title;
  final String summary;
  final String imageUrl;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final int saveCount;
  final String category;
  final String categoryColor;
  final bool isLiked;
  final bool isSaved;

  Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.tags,
    required this.likeCount,
    required this.commentCount,
    required this.saveCount,
    required this.category,
    required this.categoryColor,
    this.isLiked = false,
    this.isSaved = false,
  });

  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? imageUrl,
    List<String>? tags,
    int? likeCount,
    int? commentCount,
    int? saveCount,
    String? category,
    String? categoryColor,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      saveCount: saveCount ?? this.saveCount,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
