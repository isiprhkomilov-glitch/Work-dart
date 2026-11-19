import '../../core/network/api_client.dart';
import '../models/quote.dart';

/// Работа с эндпоинтом /v1/quotes.
class QuotesRepository {
  QuotesRepository(this._client);

  final ApiClient _client;

  Future<List<Quote>> fetchQuotes() {
    return _client.getList<Quote>('/v1/quotes', fromJson: Quote.fromJson);
  }
}
