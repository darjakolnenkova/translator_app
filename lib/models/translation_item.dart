class TranslationItem {
  final String original;
  final String translated;
  final String fromLang;  // добавлено
  final String toLang;    // добавлено
  final DateTime timestamp;
  bool isFavorite;

  TranslationItem({
    required this.original,
    required this.translated,
    required this.fromLang,
    required this.toLang,
    required this.timestamp,
    this.isFavorite = false,
  });

  factory TranslationItem.fromJson(Map<String, dynamic> json) => TranslationItem(
    original: json['original'],
    translated: json['translated'],
    fromLang: json['fromLang'],
    toLang: json['toLang'],
    timestamp: DateTime.parse(json['timestamp']),
    isFavorite: json['isFavorite'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'original': original,
    'translated': translated,
    'fromLang': fromLang,
    'toLang': toLang,
    'timestamp': timestamp.toIso8601String(),
    'isFavorite': isFavorite,
  };
}
