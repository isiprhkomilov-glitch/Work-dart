import '../../core/network/api_client.dart';
import '../models/animal_fact.dart';

/// Работа с эндпоинтом /v1/animals.
class AnimalsRepository {
  AnimalsRepository(this._client);

  final ApiClient _client;

  Future<List<AnimalFact>> fetchAnimals({required String name}) {
    return _client.getList<AnimalFact>(
      '/v1/animals',
      query: cleanQuery(<String, dynamic>{'name': name}),
      fromJson: AnimalFact.fromJson,
    );
  }
}
