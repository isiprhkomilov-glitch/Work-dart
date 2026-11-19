import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/animals_repository.dart';
import '../../data/repositories/currency_repository.dart';
import '../../data/repositories/jokes_repository.dart';
import '../../data/repositories/quotes_repository.dart';
import '../../data/repositories/weather_repository.dart';
import '../config/api_config.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../services/favorites_service.dart';
import '../storage/app_storage.dart';

/// Глобальный контейнер зависимостей (пакет get_it).
final GetIt getIt = GetIt.instance;

/// Регистрация всех сервисов приложения.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt
    ..registerLazySingleton<AppStorage>(() => AppStorage(prefs))
    ..registerLazySingleton<FavoritesService>(() => FavoritesService(getIt()))
    ..registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(getIt()))
    ..registerLazySingleton<Dio>(_createDio)
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()))
    ..registerLazySingleton<JokesRepository>(() => JokesRepository(getIt()))
    ..registerLazySingleton<QuotesRepository>(() => QuotesRepository(getIt()))
    ..registerLazySingleton<AnimalsRepository>(() => AnimalsRepository(getIt()))
    ..registerLazySingleton<CurrencyRepository>(() => CurrencyRepository(getIt()))
    ..registerLazySingleton<WeatherRepository>(() => WeatherRepository(getIt()));
}

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: <String, dynamic>{'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    // 1) автоматически добавляет токен в заголовок запроса
    getIt<AuthInterceptor>(),
    // 2) красивое логирование запросов и ответов (пакет pretty_dio_logger)
    PrettyDioLogger(
      request: true,
      // заголовки и тело не печатаем, чтобы не засекречивать токен
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: true,
      compact: true,
    ),
  ]);

  return dio;
}
