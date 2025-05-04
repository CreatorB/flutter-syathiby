import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syathiby/core/models/http_response_model.dart';

class LoginService {
  static Future<HttpResponseModel> login(String email, String password) async {
    final url = Uri.parse('/signin');
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final user = jsonData['data']['user'];
      final token = jsonData['data']['token'];
      final msg = jsonData['data']['message'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user['id'].toString());
      await prefs.setString('user_name', user['name']);
      await prefs.setString('user_email', user['email']);
      await prefs.setString('token', token);

      return HttpResponseModel(
        statusCode: response.statusCode,
        data: user,
        message: msg,
      );
    } else {
      return HttpResponseModel(
        statusCode: response.statusCode,
        message: jsonDecode(response.body)['message'],
      );
    }
  }
}