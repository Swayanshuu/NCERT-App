class PdfBookmark {
  final String id;
  final String bookCode;
  final String bookTitle;
  final String chapterTitle;
  final int pageNumber;
  final String? pdfUrl;
  final String? pdfFilePath;
  final DateTime bookmarkedAt;

  PdfBookmark({
    required this.id,
    required this.bookCode,
    required this.bookTitle,
    required this.chapterTitle,
    required this.pageNumber,
    this.pdfUrl,
    this.pdfFilePath,
    required this.bookmarkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookCode': bookCode,
      'bookTitle': bookTitle,
      'chapterTitle': chapterTitle,
      'pageNumber': pageNumber,
      'pdfUrl': pdfUrl,
      'pdfFilePath': pdfFilePath,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }

  factory PdfBookmark.fromJson(Map<String, dynamic> json) {
    return PdfBookmark(
      id: json['id'] ?? '',
      bookCode: json['bookCode'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      chapterTitle: json['chapterTitle'] ?? '',
      pageNumber: json['pageNumber'] ?? 1,
      pdfUrl: json['pdfUrl'],
      pdfFilePath: json['pdfFilePath'],
      bookmarkedAt: DateTime.tryParse(json['bookmarkedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
