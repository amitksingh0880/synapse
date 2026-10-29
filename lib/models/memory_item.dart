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

  /// Common stop words to avoid false-positive semantic matches
  static const Set<String> _stopWords = {
    'what', 'where', 'when', 'which', 'who', 'whom', 'how', 'why',
    'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did',
    'a', 'an', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while',
    'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into',
    'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from',
    'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 'again',
    'further', 'then', 'once', 'here', 'there', 'all', 'any', 'both',
    'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor',
    'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very',
    'can', 'will', 'just', 'should', 'now', 'my', 'your', 'his', 'her',
    'its', 'our', 'their', 'this', 'that', 'these', 'those'
  };

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
    if (tags.any((tag) {
      final t = tag.toLowerCase().trim();
      return t.isNotEmpty && cleanQuery.contains(t);
    })) {
      return true;
    }

    // Keyword overlap (ignoring punctuation and stop words)
    final queryTokens = cleanQuery
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length > 2 && !_stopWords.contains(t))
        .toList();

    if (queryTokens.isEmpty) return false;

    final keyTokens = cleanKey
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .toSet();
    final contentTokens = cleanContent
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .toSet();

    for (final token in queryTokens) {
      if (keyTokens.contains(token) || contentTokens.contains(token)) {
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
