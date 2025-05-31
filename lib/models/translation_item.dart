class TranslationItem {
  final String id;
  final String original;
  final String translated;
  final String fromLang;
  final String toLang;
  final DateTime timestamp;

  TranslationItem({
    String? id,
    required this.original,
    required this.translated,
    this.fromLang = 'en',
    this.toLang = 'fr',
    DateTime? timestamp,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  factory TranslationItem.fromJson(Map<String, dynamic> json) {
    return TranslationItem(
      id: json['id'] as String?,
      original: json['original'] as String,
      translated: json['translated'] as String,
      fromLang: json['fromLang'] as String? ?? 'en',
      toLang: json['toLang'] as String? ?? 'fr',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original': original,
      'translated': translated,
      'fromLang': fromLang,
      'toLang': toLang,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}