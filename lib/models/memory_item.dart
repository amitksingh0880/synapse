import '../core/constants/app_constants.dart';

class MemoryItem {
  final String id;
  final String keyQuery;
  final String content;
  final MemoryCategory category;
  final String? localPhotoPath;
  final DateTime createdAt;
  final List<String> tags;

  MemoryItem({
    required this.id,
    required this.keyQuery,
    required this.content,
    required this.category,
    this.localPhotoPath,
    required this.createdAt,
    List<String>? tags,
  }) : tags = tags ?? [];

  /// Fuzzy semantic query matching for instant retrieval
  bool matchesQuery(String query) {
    final cleanQuery = query.toLowerCase().trim();
    final cleanKey = keyQuery.toLowerCase();
    final cleanContent = content.toLowerCase();

    // Check direct substring
    if (cleanKey.contains(cleanQuery) || cleanContent.contains(cleanQuery)) {
      return true;
    }

    // Check tags
    if (tags.any((tag) => cleanQuery.contains(tag.toLowerCase()))) {
      return true;
    }

    // Keyword overlap
    final queryTokens = cleanQuery
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2)
        .toList();

    for (final token in queryTokens) {
      if (cleanKey.contains(token) || cleanContent.contains(token)) {
        return true;
      }
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyQuery': keyQuery,
      'content': content,
      'category': category.name,
      'localPhotoPath': localPhotoPath,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'] as String,
      keyQuery: json['keyQuery'] as String,
      content: json['content'] as String,
      category: MemoryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MemoryCategory.general,
      ),
      localPhotoPath: json['localPhotoPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
