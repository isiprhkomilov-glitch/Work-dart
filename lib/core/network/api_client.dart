import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Тонкая обёртка над [Dio]: типизированные запросы и единая обработка ошибок.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(path, queryParameters: query);
      final data = response.data;
      if (data == null) return <T>[];
      return data
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
      final data = response.data;
      if (data == null) {
        throw ApiException('Сервер вернул пустой ответ');
      }
      return data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

/// Убирает пустые значения из query-параметров.
Map<String, dynamic>? cleanQuery(Map<String, dynamic>? params) {
  if (params == null) return null;
  final result = <String, dynamic>{
    for (final entry in params.entries)
      if (entry.value != null &&
          (entry.value is! String || (entry.value as String).trim().isNotEmpty))
        entry.key: entry.value is String ? (entry.value as String).trim() : entry.value,
  };
  return result.isEmpty ? null : result;
}
