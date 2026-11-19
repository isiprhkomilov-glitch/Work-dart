import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

/// Локальное хранение данных приложения: токен (API-ключ) и избранное.
class AppStorage {
  AppStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String tokenKey = 'api_token';
  static const String _favoritesKey = 'favorites';

  /// Токен, который подставляется в каждый сетевой запрос.
  /// Если пользователь не задавал свой ключ — используется ключ по умолчанию.
  String get token {
    final saved = _prefs.getString(tokenKey);
    if (saved == null || saved.trim().isEmpty) return ApiConfig.defaultToken;
    return saved.trim();
  }

  bool get hasCustomToken => _prefs.getString(tokenKey)?.isNotEmpty ?? false;

  Future<void> setToken(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      await _prefs.remove(tokenKey);
    } else {
      await _prefs.setString(tokenKey, trimmed);
    }
  }

  /// Маскированный ключ для отображения в интерфейсе.
  String get maskedToken {
    final value = token;
    if (value.length <= 8) return value;
    return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
  }

  Set<String> get favorites =>
      (_prefs.getStringList(_favoritesKey) ?? const <String>[]).toSet();

  Future<void> setFavorites(Set<String> items) =>
      _prefs.setStringList(_favoritesKey, items.toList());

  Future<bool> toggleFavorite(String encoded) async {
    final current = favorites;
    final removed = current.remove(encoded);
    if (!removed) current.add(encoded);
    await setFavorites(current);
    return current.contains(encoded);
  }
}
