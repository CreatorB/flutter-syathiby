import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:convert';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syathiby/features/profile/service/user_service.dart';

class AttendanceService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? "";
  final UserService _userService = UserService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = {
      'ipAddress': '',
      'macAddress': '',
      'platform': Platform.operatingSystem,
      'platformVersion': '',
      'deviceModel': '',
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo['platformVersion'] = androidInfo.version.release;
        deviceInfo['deviceModel'] = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo['platformVersion'] = iosInfo.systemVersion;
        deviceInfo['deviceModel'] = iosInfo.model;
      } else if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceInfo['platform'] = 'Web';
        deviceInfo['platformVersion'] = webInfo.appVersion ?? '';
        deviceInfo['deviceModel'] = webInfo.userAgent ?? '';
      }
    } catch (e) {
      LoggerUtil.error('Device info error:', e);
    }

    return deviceInfo;
  }

  Future<String?> _getIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      final data = json.decode(response.body);
      return data['ip'];
    } catch (e) {
      LoggerUtil.error('IP fetch error:', e);
      return null;
    }
  }

  Future<HttpResponseModel> getStatus() async {
    try {
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
    String? token = await _userService.getAuthTokenFromSP();
    final url = Uri.parse('$_baseUrl/attendance/check-in');

    try {
      // Collect device and network information
      final deviceInfo = await _getDeviceInfo();
      final ipAddress = await _getIpAddress();

      // Add IP address to device info if available
      if (ipAddress != null) {
        deviceInfo['ipAddress'] = ipAddress;
      }
      // MAC Address (if possible)
      try {
        final ipLocal = await _networkInfo.getWifiIP();
        final wifiName = await _networkInfo.getWifiName();
        deviceInfo['macAddress'] = wifiName ?? ipLocal ?? 'unavailable';
      } catch (error) {
        LoggerUtil.error('Error getting network info:', error);
        deviceInfo['macAddress'] = 'unavailable';
      }

      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'device_info': deviceInfo.entries.map((entry) {
              return '${entry.key}: ${entry.value}';
            }).join(', ')
          }));

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ??
            'Verify checking here failed');
      }

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: jsonDecode(response.body)['data'],
          message: jsonDecode(response.body)['message']);
    } catch (e) {
      // return HttpResponseModel(statusCode: 500, message: e.toString());
      throw Exception(e);
    }
  }

  Future<HttpResponseModel> checkOut(double latitude, double longitude) async {
    String? token = await _userService.getAuthTokenFromSP();
    final url = Uri.parse('$_baseUrl/attendance/check-out');

    try {
      // Collect device and network information
      final deviceInfo = await _getDeviceInfo();
      final ipAddress = await _getIpAddress();

      // Add IP address to device info if available
      if (ipAddress != null) {
        deviceInfo['ipAddress'] = ipAddress;
      }
      // MAC Address (if possible)
      try {
        final ipLocal = await _networkInfo.getWifiIP();
        final wifiName = await _networkInfo.getWifiName();
        deviceInfo['macAddress'] = wifiName ?? ipLocal ?? 'unavailable';
      } catch (error) {
        LoggerUtil.error('Error getting network info:', error);
        deviceInfo['macAddress'] = 'unavailable';
      }

      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'device_info': deviceInfo.entries.map((entry) {
              return '${entry.key}: ${entry.value}';
            }).join(', ')
          }));

      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['message'] ??
            'Verify checking here failed');
      }

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: jsonDecode(response.body)['data'],
          message: jsonDecode(response.body)['message']);
    } catch (e) {
      // return HttpResponseModel(statusCode: 500, message: e.toString());
      throw Exception(e);
    }
  }
}
