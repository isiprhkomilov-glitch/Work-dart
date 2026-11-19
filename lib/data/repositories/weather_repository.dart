import '../../core/network/api_client.dart';
import '../models/weather.dart';

/// Город с координатами: /v1/weather принимает lat/lon,
/// а поиск по названию города доступен только по подписке.
class City {
  const City(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;

  String get coordinates =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
}

/// Работа с эндпоинтом /v1/weather.
class WeatherRepository {
  WeatherRepository(this._client);

  final ApiClient _client;

  static const List<City> cities = <City>[
    City('Москва', 55.7558, 37.6173),
    City('Санкт-Петербург', 59.9391, 30.3159),
    City('Казань', 55.7963, 49.1064),
    City('Екатеринбург', 56.8389, 60.6057),
    City('Новосибирск', 55.0084, 82.9357),
    City('Сочи', 43.5855, 39.7231),
    City('Владивосток', 43.1155, 131.8855),
    City('Мурманск', 68.9585, 33.0827),
    City('Лондон', 51.5074, -0.1278),
    City('Париж', 48.8566, 2.3522),
    City('Берлин', 52.52, 13.405),
    City('Нью-Йорк', 40.7128, -74.006),
    City('Токио', 35.6762, 139.6503),
    City('Дубай', 25.2048, 55.2708),
  ];

  Future<Weather> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final data = await _client.getObject(
      '/v1/weather',
      query: <String, dynamic>{'lat': latitude, 'lon': longitude},
    );
    return Weather.fromJson(data);
  }
}
