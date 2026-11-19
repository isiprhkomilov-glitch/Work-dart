import 'dart:convert';

/// Запись в избранном: шутка или цитата.
class FavoriteEntry {
  const FavoriteEntry({
    required this.type,
    required this.text,
    this.author = '',
    this.category = '',
  });

  static const String jokeType = 'joke';
  static const String quoteType = 'quote';

  final String type;
  final String text;
  final String author;
  final String category;

  factory FavoriteEntry.fromJson(Map<String, dynamic> json) => FavoriteEntry(
        type: (json['type'] ?? jokeType).toString(),
        text: (json['text'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
        category: (json['category'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'text': text,
        'author': author,
        'category': category,
      };

  String encode() => jsonEncode(toJson());

  static FavoriteEntry? decode(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) return null;
      return FavoriteEntry.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }
}
