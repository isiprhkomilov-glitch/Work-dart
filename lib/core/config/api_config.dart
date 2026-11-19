/// Параметры подключения к API Ninjas (https://api-ninjas.com).
class ApiConfig {
  ApiConfig._();

  /// Базовый адрес REST API.
  static const String baseUrl = 'https://api.api-ninjas.com';

  /// Ссылка на сайт сервиса (для экрана настроек и ошибок).
  static const String siteUrl = 'https://api-ninjas.com';

  /// Токен (API-ключ) по умолчанию. Его можно заменить на экране «Настройки».
  static const String defaultToken = 'QNSkvYPJyksj5XPatGLxRki40JxJAMfOcrcJzQsD';

  /// Имя заголовка, в котором API ожидает токен.
  static const String tokenHeader = 'X-Api-Key';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
