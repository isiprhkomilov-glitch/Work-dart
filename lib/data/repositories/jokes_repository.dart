import '../../core/network/api_client.dart';
import '../models/joke.dart';

/// Работа с эндпоинтом /v1/jokes.
class JokesRepository {
  JokesRepository(this._client);

  final ApiClient _client;

  static const List<String> categories = <String>[
    '',
    'programming',
    'pun',
    'dark',
    'yoMama',
    'knock-knock',
    'christmas',
  ];

  static const List<String> types = <String>['', 'single', 'twopart'];

  Future<List<Joke>> fetchJokes({String? category, String? type}) {
    return _client.getList<Joke>(
      '/v1/jokes',
      query: cleanQuery(<String, dynamic>{'category': category, 'type': type}),
      fromJson: Joke.fromJson,
    );
  }
}
