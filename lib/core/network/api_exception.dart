import 'package:dio/dio.dart';

/// Единый тип ошибок, который понимает экран приложения.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response != null) {
      final status = response.statusCode;
      final serverMessage = _serverMessage(response.data);
      if (status == 400) {
        return ApiException(serverMessage ?? 'Некорректные параметры запроса',
            statusCode: 400);
      }
      if (status == 401 || status == 403) {
        return ApiException(
          serverMessage ?? 'Доступ запрещён. Проверьте API-ключ в настройках',
          statusCode: status,
        );
      }
      if (status == 404) {
        return ApiException(serverMessage ?? 'Данные не найдены',
            statusCode: 404);
      }
      if (status == 429) {
        return ApiException('Превышен лимит запросов. Повторите попытку позже',
            statusCode: 429);
      }
      if (status != null && status >= 500) {
        return ApiException('Ошибка сервера ($status). Повторите позже',
            statusCode: status);
      }
      return ApiException(serverMessage ?? 'Ошибка запроса', statusCode: status);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return ApiException(
            'Не удалось подключиться к серверу: превышено время ожидания');
      case DioExceptionType.receiveTimeout:
        return ApiException('Сервер слишком долго отвечает');
      case DioExceptionType.badCertificate:
        return ApiException('Ошибка TLS-соединения');
      case DioExceptionType.connectionError:
        return ApiException('Нет соединения с интернетом');
      case DioExceptionType.cancel:
        return ApiException('Запрос отменён');
      case DioExceptionType.badResponse:
        return ApiException('Сервер вернул некорректный ответ');
      case DioExceptionType.transformTimeout:
        return ApiException('Ошибка преобразования ответа сервера');
      case DioExceptionType.unknown:
        return ApiException(error.message ?? 'Неизвестная ошибка сети');
    }
  }

  static String? _serverMessage(dynamic data) {
    if (data is Map && data['error'] is String) {
      final raw = (data['error'] as String).trim();
      if (raw.isEmpty) return null;
      if (raw.contains('premium')) {
        return 'Параметр доступен только по подписке Premium: $raw';
      }
      return raw;
    }
    if (data is String && data.trim().isNotEmpty && !data.trim().startsWith('<')) {
      return data.trim();
    }
    return null;
  }

  @override
  String toString() => message;
}
