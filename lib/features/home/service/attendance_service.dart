import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syathiby/features/profile/service/user_service.dart';

class AttendanceService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? "";
  final UserService _userService = UserService();
  Future<HttpResponseModel> getStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = await _userService.getAuthTokenFromSP();
      final url = Uri.parse('$_baseUrl/attendance/status');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      });

      LoggerUtil.debug('Raw response getstatus: ${response.body}');
      var data = jsonDecode(response.body);

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: data['data'],
          message: data['message']);
    } catch (e) {
      LoggerUtil.error('Get status error:', e);
      throw e;
    }
  }

  Future<HttpResponseModel> checkIn(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await _userService.getAuthTokenFromSP();
    final url = Uri.parse('$_baseUrl/attendance/check-in');

    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      }, body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString()
      });

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: jsonDecode(response.body)['data'],
          message: jsonDecode(response.body)['message']);
    } catch (e) {
      return HttpResponseModel(statusCode: 500, message: e.toString());
    }
  }

  Future<HttpResponseModel> checkOut(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = await _userService.getAuthTokenFromSP();
    final url = Uri.parse('$_baseUrl/attendance/check-out');

    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      }, body: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString()
      });

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: jsonDecode(response.body)['data'],
          message: jsonDecode(response.body)['message']);
    } catch (e) {
      return HttpResponseModel(statusCode: 500, message: e.toString());
    }
  }
}
