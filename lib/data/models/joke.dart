/// Шутка из /v1/jokes.
class Joke {
  const Joke({required this.text});

  final String text;

  factory Joke.fromJson(Map<String, dynamic> json) => Joke(
        text: (json['joke'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'joke': text};
}
