import 'dart:io';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/app_storage.dart';

/// Interceptor, который автоматически добавляет токен (API-ключ)
/// в заголовок каждого запроса.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);

  final AppStorage _storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.token;
    if (token.isNotEmpty) {
      options.headers[ApiConfig.tokenHeader] = token;
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
