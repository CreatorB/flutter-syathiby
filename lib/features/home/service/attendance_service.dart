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
      'ipAddress': 'Fetching...',
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

    // Get public IP address - this is required for IP validation
    final ipAddress = await _getIpAddress();
    deviceInfo['ipAddress'] = ipAddress ?? 'Failed to get IP';

    // Try to get network details
    try {
      final ipLocal = await _networkInfo.getWifiIP();
      final wifiName = await _networkInfo.getWifiName();
      deviceInfo['macAddress'] = wifiName ?? ipLocal ?? 'unavailable';
    } catch (error) {
      LoggerUtil.error('Error getting network info:', error);
      deviceInfo['macAddress'] = 'unavailable';
    }

    // Log the device info we collected
    LoggerUtil.debug('Device info collected: $deviceInfo');

    return deviceInfo;
  }

  Future<String?> _getIpAddress() async {
    try {
      // Try multiple services in case one fails
      String? ipAddress;

      // First try ipify.org
      try {
        final response = await http
            .get(Uri.parse('https://api.ipify.org?format=json'), headers: {
          'Accept': 'application/json'
        }).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          ipAddress = data['ip'];
          LoggerUtil.debug('IP from ipify: $ipAddress');
          return ipAddress;
        }
      } catch (e) {
        LoggerUtil.error('ipify.org fetch error:', e);
      }

      // Fallback to ipinfo.io
      try {
        final response = await http.get(Uri.parse('https://ipinfo.io/json'),
            headers: {
              'Accept': 'application/json'
            }).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          ipAddress = data['ip'];
          LoggerUtil.debug('IP from ipinfo: $ipAddress');
          return ipAddress;
        }
      } catch (e) {
        LoggerUtil.error('ipinfo.io fetch error:', e);
      }

      // Final fallback
      try {
        final response = await http.get(Uri.parse('https://api.myip.com'),
            headers: {
              'Accept': 'application/json'
            }).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          ipAddress = data['ip'];
          LoggerUtil.debug('IP from myip: $ipAddress');
          return ipAddress;
        }
      } catch (e) {
        LoggerUtil.error('api.myip.com fetch error:', e);
      }

      return null;
    } catch (e) {
      LoggerUtil.error('All IP fetch methods failed:', e);
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
      final deviceInfoStr = deviceInfo.entries.map((entry) {
        return '${entry.key}: ${entry.value}';
      }).join(', ');
      LoggerUtil.debug('Sending device info: $deviceInfoStr');

      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'device_info': deviceInfoStr
          }));
      LoggerUtil.debug('Check-in response status: ${response.statusCode}');
      LoggerUtil.debug('Check-in response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorMsg = jsonDecode(response.body)['message'] ??
            'Verify checking here failed';
        throw Exception(errorMsg);
      }

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: jsonDecode(response.body)['data'],
          message: jsonDecode(response.body)['message']);
    } catch (e) {
      LoggerUtil.error('Check-in error:', e);
      throw Exception(e.toString());
    }
  }

  Future<HttpResponseModel> checkOut(double latitude, double longitude) async {
    String? token = await _userService.getAuthTokenFromSP();
    final url = Uri.parse('$_baseUrl/attendance/check-out');

    try {
      // Collect device and network information
      final deviceInfo = await _getDeviceInfo();

      // Format device info as string for API
      final deviceInfoStr = deviceInfo.entries.map((entry) {
        return '${entry.key}: ${entry.value}';
      }).join(', ');

      LoggerUtil.debug('Sending device info: $deviceInfoStr');

      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
          body: json.encode({
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
            'device_info': deviceInfoStr
          }));

      LoggerUtil.debug('Check-out response status: ${response.statusCode}');
      LoggerUtil.debug('Check-out response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorMsg = jsonDecode(response.body)['message'] ??
            'Verify checking here failed';
        throw Exception(errorMsg);
      }

      return HttpResponseModel(
          statusCode: response.statusCode,
          data: jsonDecode(response.body)['data'],
          message: jsonDecode(response.body)['message']);
    } catch (e) {
      LoggerUtil.error('Check-in error:', e);
      throw Exception(e.toString());
    }
  }
}
