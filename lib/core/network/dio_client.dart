import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../utils/app_logger.dart';

@lazySingleton
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Expendly-App/1.1.1',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.d('🌐 [DIO Request] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d(
            '✅ [DIO Response] ${response.statusCode} from ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          AppLogger.w(
            '❌ [DIO Error] ${e.message} for ${e.requestOptions.uri}',
          );
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
