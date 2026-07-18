import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'auth_interceptor.dart';

/// Thin wrapper around a configured [Dio] instance for backend requests.
class ApiClient {
  ApiClient({required AuthInterceptor authInterceptor})
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
          ),
        )..interceptors.add(authInterceptor);

  final Dio dio;
}
