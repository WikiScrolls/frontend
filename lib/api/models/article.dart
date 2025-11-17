class ArticleModel {
  final String id;
  final String title;
  final String? content;
  final String? thumbnail;
  final int likeCount;
  final DateTime? createdAt;

  const ArticleModel({
    required this.id,
    required this.title,
    this.content,
    this.thumbnail,
    this.likeCount = 0,
    this.createdAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? '',
        content: json['content'] ?? json['body'],
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        thumbnail: json['thumbnail'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'likeCount': likeCount,
        'thumbnail': thumbnail,
        'createdAt': createdAt?.toIso8601String(),
      };
}