import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../../core/network/api_exception.dart';
import '../../data/models/weather.dart';
import '../../data/repositories/weather_repository.dart';
import '../widgets/common_views.dart';

/// Раздел «Погода»: прогноз по выбранному городу (или по координатам).
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherRepository _repository = getIt<WeatherRepository>();

  City _city = WeatherRepository.cities.first;
  Weather? _weather;
  bool _loading = false;
  String? _error;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final weather = await _repository.fetchWeather(
        latitude: _city.latitude,
        longitude: _city.longitude,
      );
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Неизвестная ошибка: $error';
      });
    }
  }

  Future<void> _loadByCoordinates() async {
    final lat = double.tryParse(_latController.text.replaceAll(',', '.'));
    final lon = double.tryParse(_lonController.text.replaceAll(',', '.'));
    if (lat == null || lon == null || lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректные координаты')),
      );
      return;
    }
    setState(() {
      _city = City('Координаты $lat, $lon', lat, lon);
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DropdownButtonFormField<City>(
                  key: ValueKey<String>(_city.name),
                  initialValue: _city,
                  decoration: const InputDecoration(labelText: 'Город'),
                  items: <DropdownMenuItem<City>>[
                    for (final city in WeatherRepository.cities)
                      DropdownMenuItem<City>(value: city, child: Text(city.name)),
                  ],
                  onChanged: (City? value) {
                    if (value == null) return;
                    setState(() => _city = value);
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Обновить',
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _latController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Широта (lat)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lonController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Долгота (lon)'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: _loading ? null : _loadByCoordinates,
                child: const Text('Показать'),
              ),
            ],
          ),
        ),
        if (_weather != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Координаты: ${_city.coordinates}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 4),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading && _weather == null) return const LoadingView();
    if (_error != null && _weather == null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    final weather = _weather;
    if (weather == null) {
      return const EmptyView(
        message: 'Данные о погоде не загружены',
        icon: Icons.wb_sunny_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  if (weather.iconUrl.isNotEmpty)
                    Image.network(
                      weather.iconUrl,
                      width: 96,
                      height: 96,
                      errorBuilder: (BuildContext context, Object error,
                              StackTrace? stack) =>
                          Icon(
                        weather.isDay
                            ? Icons.wb_sunny_rounded
                            : Icons.nightlight_round,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    Icon(
                      weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${weather.temperature.round()} °C',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(
                    weather.description.isEmpty
                        ? _city.name
                        : weather.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _city.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: <Widget>[
              _InfoTile(
                icon: Icons.thermostat_rounded,
                label: 'Ощущается как',
                value: '${weather.feelsLike.round()} °C',
              ),
              _InfoTile(
                icon: Icons.water_drop_rounded,
                label: 'Влажность',
                value: '${weather.humidity.round()} %',
              ),
              _InfoTile(
                icon: Icons.air_rounded,
                label: 'Ветер',
                value: '${weather.windSpeed.toStringAsFixed(1)} м/с, '
                    '${_direction(weather.windDegrees)}',
              ),
              _InfoTile(
                icon: Icons.cloud_rounded,
                label: 'Облачность',
                value: '${weather.cloudPct} %',
              ),
              _InfoTile(
                icon: Icons.arrow_upward_rounded,
                label: 'Максимум',
                value: '${weather.maxTemp.round()} °C',
              ),
              _InfoTile(
                icon: Icons.arrow_downward_rounded,
                label: 'Минимум',
                value: '${weather.minTemp.round()} °C',
              ),
              _InfoTile(
                icon: Icons.wb_twilight_rounded,
                label: 'Восход',
                value: _time(weather.sunrise),
              ),
              _InfoTile(
                icon: Icons.nights_stay_rounded,
                label: 'Закат',
                value: _time(weather.sunset),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Данные: API Ninjas /v1/weather (по координатам).',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _time(DateTime? value) {
    if (value == null) return '—';
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}';
  }

  String _direction(int degrees) {
    const names = <String>[
      'С', 'СВ', 'В', 'ЮВ', 'Ю', 'ЮЗ', 'З', 'СЗ',
    ];
    final index = ((degrees % 360) / 45).round() % names.length;
    return names[index];
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(label, style: theme.textTheme.bodySmall),
                Text(
                  value,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
