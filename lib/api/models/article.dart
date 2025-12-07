import 'category.dart';

class ArticleModel {
  final String id;
  final String title;
  final String? wikipediaId;     // Wikipedia Page ID
  final String? wikipediaUrl;
  final String? imageUrl;
  final String? content;          // Raw Wikipedia content
  final String? aiSummary;        // AI-generated summary
  final String? audioUrl;
  final List<String> tags;
  final DateTime? publishedDate;
  final DateTime? createdAt;
  final bool isActive;
  final bool isProcessed;
  final int viewCount;
  final int likeCount;
  final int saveCount;
  final String? categoryId;
  final CategoryModel? category;

  /// Returns the best available text content (prefers aiSummary, falls back to content)
  String? get displayContent => aiSummary ?? content;

  const ArticleModel({
    required this.id,
    required this.title,
    this.wikipediaId,
    this.wikipediaUrl,
    this.imageUrl,
    this.content,
    this.aiSummary,
    this.audioUrl,
    this.tags = const [],
    this.publishedDate,
    this.createdAt,
    this.isActive = true,
    this.isProcessed = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.saveCount = 0,
    this.categoryId,
    this.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        wikipediaId: json['wikipediaId']?.toString(),
        wikipediaUrl: json['wikipediaUrl'],
        imageUrl: json['imageUrl'],
        content: json['content'],
        aiSummary: json['aiSummary'] ?? json['body'],
        audioUrl: json['audioUrl'],
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        publishedDate: json['publishedDate'] != null
            ? DateTime.tryParse(json['publishedDate'].toString())
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        isActive: json['isActive'] == true,
        isProcessed: json['isProcessed'] == true,
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        saveCount: (json['saveCount'] as num?)?.toInt() ?? 0,
        categoryId: json['categoryId']?.toString(),
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'wikipediaId': wikipediaId,
        'wikipediaUrl': wikipediaUrl,
        'imageUrl': imageUrl,
        'content': content,
        'aiSummary': aiSummary,
        'audioUrl': audioUrl,
        'tags': tags,
        'publishedDate': publishedDate?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'isActive': isActive,
        'isProcessed': isProcessed,
        'viewCount': viewCount,
        'likeCount': likeCount,
        'saveCount': saveCount,
        'categoryId': categoryId,
        'category': category?.toJson(),
      };

  ArticleModel copyWith({
    String? id,
    String? title,
    String? wikipediaId,
    String? wikipediaUrl,
    String? imageUrl,
    String? content,
    String? aiSummary,
    String? audioUrl,
    List<String>? tags,
    DateTime? publishedDate,
    DateTime? createdAt,
    bool? isActive,
    bool? isProcessed,
    int? viewCount,
    int? likeCount,
    int? saveCount,
    String? categoryId,
    CategoryModel? category,
  }) =>
      ArticleModel(
        id: id ?? this.id,
        title: title ?? this.title,
        wikipediaId: wikipediaId ?? this.wikipediaId,
        wikipediaUrl: wikipediaUrl ?? this.wikipediaUrl,
        imageUrl: imageUrl ?? this.imageUrl,
        content: content ?? this.content,
        aiSummary: aiSummary ?? this.aiSummary,
        audioUrl: audioUrl ?? this.audioUrl,
        tags: tags ?? this.tags,
        publishedDate: publishedDate ?? this.publishedDate,
        createdAt: createdAt ?? this.createdAt,
        isActive: isActive ?? this.isActive,
        isProcessed: isProcessed ?? this.isProcessed,
        viewCount: viewCount ?? this.viewCount,
        likeCount: likeCount ?? this.likeCount,
        saveCount: saveCount ?? this.saveCount,
        categoryId: categoryId ?? this.categoryId,
        category: category ?? this.category,
      );
}
