import 'package:flutter/material.dart';

import '../../core/config/api_config.dart';
import '../../core/di/locator.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/repositories/jokes_repository.dart';
import '../widgets/common_views.dart';

/// Экран «Настройки»: API-ключ (токен) и проверка подключения.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onTokenSaved});

  /// Вызывается после сохранения токена (чтобы обновить заголовок меню).
  final VoidCallback onTokenSaved;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppStorage _storage = getIt<AppStorage>();
  final JokesRepository _repository = getIt<JokesRepository>();
  final TextEditingController _controller = TextEditingController();

  bool _checking = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    _controller.text = _storage.token;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _storage.setToken(_controller.text);
    widget.onTokenSaved();
    if (!mounted) return;
    setState(() => _status = 'Токен сохранён');
    setState(() => _statusOk = true);
    FocusScope.of(context).unfocus();
  }

  Future<void> _reset() async {
    await _storage.setToken(ApiConfig.defaultToken);
    _controller.text = ApiConfig.defaultToken;
    widget.onTokenSaved();
    if (!mounted) return;
    setState(() {
      _status = 'Возвращён токен по умолчанию';
      _statusOk = true;
    });
  }

  Future<void> _checkConnection() async {
    setState(() {
      _checking = true;
      _status = null;
    });
    try {
      final jokes = await _repository.fetchJokes();
      if (!mounted) return;
      setState(() {
        _checking = false;
        _statusOk = true;
        _status = jokes.isEmpty
            ? 'Подключение работает'
            : 'Подключение работает: получено шуток — ${jokes.length}';
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _statusOk = false;
        _status = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _statusOk = false;
        _status = 'Неизвестная ошибка: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('API-ключ (токен)', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Ключ подставляется автоматически в заголовок X-Api-Key '
          'каждого запроса (класс AuthInterceptor).',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Токен API Ninjas',
            hintText: 'Вставьте ключ с сайта api-ninjas.com',
            prefixIcon: Icon(Icons.key_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Сохранить'),
            ),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('Сбросить'),
            ),
            FilledButton.tonalIcon(
              onPressed: _checking ? null : _checkConnection,
              icon: _checking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.wifi_tethering_rounded),
              label: const Text('Проверить подключение'),
            ),
          ],
        ),
        if (_status != null) ...<Widget>[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_statusOk
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error)
                  .withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  _statusOk ? Icons.check_circle_rounded : Icons.error_rounded,
                  size: 20,
                  color: _statusOk
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(_status!)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text('Информация', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.dns_rounded),
                title: const Text('Сервер'),
                subtitle: const Text(ApiConfig.baseUrl),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Сайт и документация'),
                subtitle: const Text(ApiConfig.siteUrl),
              ),
              ListTile(
                leading: const Icon(Icons.hub_rounded),
                title: const Text('Пакеты'),
                subtitle: const Text(
                  'dio, pretty_dio_logger, get_it, shared_preferences',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        HintCard(
          child: Text(
            'Приложение состоит из 7 разделов: Шутки, Цитаты, Животные, '
            'Курсы валют, Погода, Избранное и Настройки. '
            'Все запросы идут через Dio с двумя интерцепторами: '
            'AuthInterceptor (токен) и PrettyDioLogger (логи).',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
