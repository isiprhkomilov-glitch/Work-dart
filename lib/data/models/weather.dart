/// Погода из /v1/weather (запрос по координатам lat/lon).
class Weather {
  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.minTemp,
    required this.maxTemp,
    required this.windSpeed,
    required this.windDegrees,
    required this.cloudPct,
    required this.description,
    required this.iconUrl,
    required this.isDay,
    required this.sunrise,
    required this.sunset,
  });

  final double temperature;
  final double feelsLike;
  final double humidity;
  final double minTemp;
  final double maxTemp;
  final double windSpeed;
  final int windDegrees;
  final int cloudPct;
  final String description;
  final String iconUrl;
  final bool isDay;
  final DateTime? sunrise;
  final DateTime? sunset;

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        temperature: _num(json['temp']),
        feelsLike: _num(json['feels_like']),
        humidity: _num(json['humidity']),
        minTemp: _num(json['min_temp']),
        maxTemp: _num(json['max_temp']),
        windSpeed: _num(json['wind_speed']),
        windDegrees: _num(json['wind_degrees']).round(),
        cloudPct: _num(json['cloud_pct']).round(),
        description: (json['weather_description'] ?? json['weather'] ?? '').toString(),
        iconUrl: (json['weather_icon_png_url'] ?? '').toString(),
        isDay: json['is_day'] == true,
        sunrise: _epoch(json['sunrise']),
        sunset: _epoch(json['sunset']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'min_temp': minTemp,
        'max_temp': maxTemp,
        'wind_speed': windSpeed,
        'wind_degrees': windDegrees,
        'cloud_pct': cloudPct,
        'weather_description': description,
        'weather_icon_png_url': iconUrl,
        'is_day': isDay,
        'sunrise': sunrise?.millisecondsSinceEpoch,
        'sunset': sunset?.millisecondsSinceEpoch,
      };

  static double _num(dynamic value) => value is num ? value.toDouble() : 0;

  static DateTime? _epoch(dynamic value) =>
      value is num ? DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000) : null;
}
