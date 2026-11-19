import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../models/currency_rate.dart';

/// Работа с эндпоинтом /v1/exchangerate.
class CurrencyRepository {
  CurrencyRepository(this._client);

  final ApiClient _client;

  Future<CurrencyRate> fetchRate({required String base, required String target}) async {
    final data = await _client.getObject(
      '/v1/exchangerate',
      query: <String, dynamic>{'pair': '${base}_$target'},
    );
    return CurrencyRate.fromJson(data);
  }

  /// Курсы валют относительно выбранной базовой валюты.
  /// Ошибка по одному курсу не прерывает загрузку остальных.
  Future<List<CurrencyRate>> fetchRates({
    required String base,
    required List<String> targets,
  }) async {
    final results = <CurrencyRate>[];
    Object? firstError;

    await Future.wait(targets.map((String target) async {
      try {
        results.add(await fetchRate(base: base, target: target));
      } catch (error) {
        firstError ??= error;
      }
    }));

    if (results.isEmpty) {
      final error = firstError;
      if (error is ApiException) throw error;
      throw ApiException('Не удалось получить курсы валют');
    }

    results.sort((a, b) => a.target.compareTo(b.target));
    return results;
  }
}
