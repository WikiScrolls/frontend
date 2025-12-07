class CategoryModel {
  final String id;
  final String name;
  final String? color;
  final String? description;
  final int articleCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.color,
    this.description,
    this.articleCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        color: json['color'],
        description: json['description'],
        articleCount: (json['articleCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'description': description,
        'articleCount': articleCount,
      };
}
