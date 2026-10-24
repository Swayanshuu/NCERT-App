class NcertStory {
  final String id;
  final String title;
  final String snippet;
  final String source;
  final String link;
  final String publishedAt;
  final String category;
  final List<int> gradientColors;
  final bool isRead;

  const NcertStory({
    required this.id,
    required this.title,
    required this.snippet,
    required this.source,
    required this.link,
    required this.publishedAt,
    required this.category,
    required this.gradientColors,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'snippet': snippet,
        'source': source,
        'link': link,
        'publishedAt': publishedAt,
        'category': category,
        'gradientColors': gradientColors,
        'isRead': isRead,
      };

  factory NcertStory.fromJson(Map<String, dynamic> json) => NcertStory(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
        source: json['source'] as String? ?? 'NCERT News',
        link: json['link'] as String? ?? '',
        publishedAt: json['publishedAt'] as String? ?? 'Today',
        category: json['category'] as String? ?? 'Education',
        gradientColors: (json['gradientColors'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [0xFF1E1B4B, 0xFF0F172A],
        isRead: json['isRead'] as bool? ?? false,
      );

  NcertStory copyWith({
    String? id,
    String? title,
    String? snippet,
    String? source,
    String? link,
    String? publishedAt,
    String? category,
    List<int>? gradientColors,
    bool? isRead,
  }) {
    return NcertStory(
      id: id ?? this.id,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      source: source ?? this.source,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      gradientColors: gradientColors ?? this.gradientColors,
      isRead: isRead ?? this.isRead,
    );
  }
}
