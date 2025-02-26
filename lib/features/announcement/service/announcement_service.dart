import 'package:dio/dio.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import '../model/announcement_model.dart';

class AnnouncementService {
  final Dio _dio;

  AnnouncementService(this._dio);

  Future<List<Announcement>> getActiveAnnouncements() async {
    try {
      // Debug URL
      LoggerUtil.debug(
          'Fetching announcements from: ${_dio.options.baseUrl}/announcements/active');

      final token = await SharedPreferencesService.instance
          .getData<String>(PreferenceKey.authToken);

      if (token == null) {
        throw Exception('Unauthorized: No token found');
      }

      final response = await _dio.get(
        '/announcements/active',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      // Debug response
      LoggerUtil.debug('Announcement response: ${response.data}');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> announcementData = response.data['data'] as List;
        return announcementData
            .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Token expired or invalid');
      }
      LoggerUtil.error('Error fetching announcements', e);
      throw Exception('Failed to load announcements');
    } catch (e) {
      LoggerUtil.error('Error loading announcements', e);
      throw Exception('Unexpected error loading announcements');
    }
  }
}
