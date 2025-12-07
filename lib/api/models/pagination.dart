class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  /// Alias for backward compatibility
  int get totalItems => total;

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
        page: (json['page'] as num?)?.toInt() ?? 1,
        limit: (json['limit'] as num?)?.toInt() ?? 20,
        total: (json['total'] as num?)?.toInt() ?? (json['totalItems'] as num?)?.toInt() ?? 0,
        totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      };

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
