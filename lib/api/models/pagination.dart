class PaginationInfo {
  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 10,
        totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'totalItems': totalItems,
        'totalPages': totalPages,
      };
}
