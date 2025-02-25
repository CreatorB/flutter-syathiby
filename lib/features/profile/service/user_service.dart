import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:syathiby/core/interfaces/user_interface.dart';
import 'package:syathiby/core/models/http_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/profile/model/user_model.dart';

class UserService extends UserInterface {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? "";
  final dio = Dio();

  @override
  Future<HttpResponseModel> login(
      {required String email, required String password}) async {
    try {
      LoggerUtil.debug('Starting login request for email: $email');
      var url = Uri.parse('$_baseUrl/signin');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      LoggerUtil.debug('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        LoggerUtil.debug('Decoded success: ${decodedResponse['success']}');
        LoggerUtil.debug('Token: ${decodedResponse['data']['token']}');

        if (decodedResponse['success'] == true) {
          return HttpResponseModel(
            statusCode: response.statusCode,
            data: decodedResponse["data"],
            message: decodedResponse["message"],
          );
        }
      }

      return HttpResponseModel(
        statusCode: response.statusCode,
        message: jsonDecode(response.body)["message"],
      );
    } catch (e, stackTrace) {
      LoggerUtil.error('Login error', e, stackTrace);
      return HttpResponseModel(
        statusCode: 500,
        message: 'Connection error: $e',
      );
    }
  }

  Future<HttpResponseModel> getUserData({required String token}) async {
    try {
      var url = Uri.parse('$_baseUrl/me');
      LoggerUtil.debug('Checking user data with token: $token');

      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      LoggerUtil.debug('getUserData response: ${response.statusCode}');
      LoggerUtil.debug('getUserData body: ${response.body}');

      if (response.statusCode == 200) {
        var decoded = jsonDecode(response.body);
        return HttpResponseModel(
            statusCode: 200,
            data: decoded['data'],
            message: decoded['message']);
      }

      return HttpResponseModel(
          statusCode: response.statusCode, message: 'Failed to get user data');
    } catch (e) {
      LoggerUtil.error('Error getting user data', e);
      return HttpResponseModel(statusCode: 500, message: e.toString());
    }
  }

  @override
  Future<HttpResponseModel<dynamic>> create({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$_baseUrl/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      return HttpResponseModel(
        statusCode: response.statusCode ?? 500,
        message: response.data['message'] ?? '',
        data: response.data['data'],
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return HttpResponseModel(
          statusCode: e.response?.statusCode ?? 500,
          message: e.response?.data['message'] ?? 'Server error',
          data: e.response?.data['data'],
        );
      }
      return HttpResponseModel(
        statusCode: 500,
        message: 'Connection error',
        data: null,
      );
    }
  }

  @override
  Future<HttpResponseModel> delete({required String id}) async {
    try {
      var url = Uri.parse('$_baseUrl/users/$id');
      var response = await http.delete(url);

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: jsonDecode(response.body)["data"],
        message: jsonDecode(response.body)["message"],
      );
    } catch (e) {
      return HttpResponseModel(
        message: 'An error occurred: $e',
      );
    }
  }

  @override
  Future<HttpResponseModel> getById({required String id}) async {
    try {
      var url = Uri.parse('$_baseUrl/users/$id');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: jsonDecode(response.body)["data"],
        message: jsonDecode(response.body)["message"],
      );
    } catch (e) {
      return HttpResponseModel(
        message: 'An error occurred: $e',
      );
    }
  }

  @override
  Future<HttpResponseModel> update({required UserModel userModel}) async {
    try {
      var url = Uri.parse('$_baseUrl/users/${userModel.id}');
      var response = await http.put(
        url,
        body: jsonEncode({
          'name': userModel.name,
          'email': userModel.email,
          'photo_url': userModel.photoUrl,
          'gender': userModel.gender,
        }),
      );

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: jsonDecode(response.body)["data"],
        message: jsonDecode(response.body)["message"],
      );
    } catch (e) {
      return HttpResponseModel(
        message: 'An error occurred: $e',
      );
    }
  }

  @override
  Future<HttpResponseModel> validate({required String token}) async {
    try {
      var url = Uri.parse('$_baseUrl/validate');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: jsonDecode(response.body)["data"],
        message: jsonDecode(response.body)["message"],
      );
    } catch (e) {
      return HttpResponseModel(
        message: 'An error occurred: $e',
      );
    }
  }

  Future<void> saveAuthTokenToSP(String authToken) async {
    LoggerUtil.debug('Saving token: $authToken');
    await SharedPreferencesService.instance
        .setData(PreferenceKey.authToken, authToken);
    LoggerUtil.debug('Token saved: $authToken');
  }

  Future<String?> getAuthTokenFromSP() async {
    final token = SharedPreferencesService.instance
        .getData<String>(PreferenceKey.authToken);
    LoggerUtil.debug('Retrieved token: $token');
    return token;
  }

  Future<void> deleteAuthTokenFromSP() async {
    await SharedPreferencesService.instance.removeData(PreferenceKey.authToken);
  }

  @override
  Future<HttpResponseModel> check({required String email}) async {
    try {
      var url = Uri.parse('$_baseUrl/users/check/$email');
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: jsonDecode(response.body)["data"],
        message: jsonDecode(response.body)["message"],
      );
    } catch (e) {
      return HttpResponseModel(
        message: 'An error occurred: $e',
      );
    }
  }

  @override
  Future<HttpResponseModel> updatePassword(
      {required String userId, required String password}) async {
    try {
      var url = Uri.parse('$_baseUrl/users/$userId');
      var response = await http.put(
        url,
        body: jsonEncode({
          'password': password,
        }),
      );

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: jsonDecode(response.body)["data"],
        message: jsonDecode(response.body)["message"],
      );
    } catch (e) {
      return HttpResponseModel(
        message: 'An error occurred: $e',
      );
    }
  }
}
