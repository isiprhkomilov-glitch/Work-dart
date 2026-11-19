/// Цитата из /v1/quotes.
class Quote {
  const Quote({
    required this.text,
    required this.author,
    required this.category,
  });

  final String text;
  final String author;
  final String category;

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: (json['quote'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
        category: (json['category'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'quote': text,
        'author': author,
        'category': category,
      };
}
