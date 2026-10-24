class NcertNotice {
  final String id;
  final String title;
  final String category;
  final String pdfUrl;
  final String date;
  final String fileType;
  final bool isNew;

  const NcertNotice({
    required this.id,
    required this.title,
    required this.category,
    required this.pdfUrl,
    required this.date,
    this.fileType = 'PDF',
    this.isNew = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'pdfUrl': pdfUrl,
      'date': date,
      'fileType': fileType,
      'isNew': isNew,
    };
  }

  factory NcertNotice.fromJson(Map<String, dynamic> json) {
    return NcertNotice(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General Notice',
      pdfUrl: json['pdfUrl'] as String? ?? '',
      date: json['date'] as String? ?? 'Recent',
      fileType: json['fileType'] as String? ?? 'PDF',
      isNew: json['isNew'] as bool? ?? false,
    );
  }

  NcertNotice copyWith({
    String? id,
    String? title,
    String? category,
    String? pdfUrl,
    String? date,
    String? fileType,
    bool? isNew,
  }) {
    return NcertNotice(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      date: date ?? this.date,
      fileType: fileType ?? this.fileType,
      isNew: isNew ?? this.isNew,
    );
  }
}
