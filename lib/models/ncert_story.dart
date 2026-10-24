class NcertStory {
  final String id;
  final String title;
  final String snippet;
  final String source;
  final String link;
  final String publishedAt;
  final int timestamp;
  final String category;
  final List<int> gradientColors;
  final String? imageUrl;
  final bool isRead;

  const NcertStory({
    required this.id,
    required this.title,
    required this.snippet,
    required this.source,
    required this.link,
    required this.publishedAt,
    this.timestamp = 0,
    required this.category,
    required this.gradientColors,
    this.imageUrl,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'snippet': snippet,
        'source': source,
        'link': link,
        'publishedAt': publishedAt,
        'timestamp': timestamp,
        'category': category,
        'gradientColors': gradientColors,
        'imageUrl': imageUrl,
        'isRead': isRead,
      };

  factory NcertStory.fromJson(Map<String, dynamic> json) => NcertStory(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
        source: json['source'] as String? ?? 'NCERT News',
        link: json['link'] as String? ?? '',
        publishedAt: json['publishedAt'] as String? ?? 'Today',
        timestamp: json['timestamp'] as int? ?? 0,
        category: json['category'] as String? ?? 'Education',
        gradientColors: (json['gradientColors'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            const [0xFF1E293B, 0xFF1E293B],
        imageUrl: json['imageUrl'] as String?,
        isRead: json['isRead'] as bool? ?? false,
      );

  NcertStory copyWith({
    String? id,
    String? title,
    String? snippet,
    String? source,
    String? link,
    String? publishedAt,
    int? timestamp,
    String? category,
    List<int>? gradientColors,
    String? imageUrl,
    bool? isRead,
  }) {
    return NcertStory(
      id: id ?? this.id,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      source: source ?? this.source,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      gradientColors: gradientColors ?? this.gradientColors,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }
}
