class NcertBook {
  final String text;
  final String code;
  final String chapters;
  final String className;
  final String subject;

  NcertBook({
    required this.text,
    required this.code,
    required this.chapters,
    required this.className,
    required this.subject,
  });

  factory NcertBook.fromJson(Map<String, dynamic> json, String className, String subject) {
    return NcertBook(
      text: json['text'] ?? 'Untitled Book',
      code: json['code'] ?? '',
      chapters: json['chapters']?.toString() ?? '1-10',
      className: className,
      subject: subject,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'code': code,
      'chapters': chapters,
      'className': className,
      'subject': subject,
    };
  }

  bool get hasPrelims {
    return chapters.startsWith('0');
  }

  int get maxChapterNumber {
    if (chapters.contains('-')) {
      final parts = chapters.split('-');
      final endNum = int.tryParse(parts.last.trim());
      if (endNum != null && endNum > 0) return endNum;
    }
    final singleNum = int.tryParse(chapters.trim());
    if (singleNum != null && singleNum > 0) return singleNum;
    return 10;
  }
}