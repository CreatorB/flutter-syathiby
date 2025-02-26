import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/announcement/cubit/announcement_cubit.dart';
import 'package:syathiby/features/announcement/service/announcement_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Cubits/Blocs
  sl.registerFactory(() => AnnouncementCubit(sl()));

  // Services
  sl.registerLazySingleton<AnnouncementService>(
      () => AnnouncementService(sl()));

  // External
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Add timeout
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // Add interceptor for debugging
dio.interceptors.add(InterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        LoggerUtil.error('Unauthorized', error);
      }
      return handler.next(error);
    },
  ));

  return dio;
  });
}
