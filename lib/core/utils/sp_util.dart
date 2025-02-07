import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:syathiby/core/constants/app_constants.dart';
import 'package:syathiby/features/profile/model/user_model.dart';

class Utils {
  // start SP utils
  static Future<void> setUser(UserModel data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(AppConstants.objUser, jsonString);
    print('cekProfile stored: $jsonString');
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(AppConstants.objUser);
    if (jsonString != null) {
      final userMap = jsonDecode(jsonString);
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  // Save a boolean value with the given key to SharedPreferences.
  static Future<bool> setSpBool(String key, bool value) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.setBool(key, value);
    } catch (e) {
      debugPrint("Error saving boolean: $e");
      return false;
    }
  }

  // Save an integer value with the given key to SharedPreferences.
  static Future<bool> setSpInt(String key, int value) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.setInt(key, value);
    } catch (e) {
      debugPrint("Error saving integer: $e");
      return false;
    }
  }

  // Save a double value with the given key to SharedPreferences.
  static Future<bool> setSpDouble(String key, double value) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.setDouble(key, value);
    } catch (e) {
      debugPrint("Error saving double: $e");
      return false;
    }
  }

  // Save a string value with the given key to SharedPreferences.
  static Future<bool> setSpString(String key, String value) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.setString(key, value);
    } catch (e) {
      debugPrint("Error saving string: $e");
      return false;
    }
  }

  // Save a list of strings with the given key to SharedPreferences.
  static Future<bool> setSpStringList(String key, List<String> value) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.setStringList(key, value);
    } catch (e) {
      debugPrint("Error saving string list: $e");
      return false;
    }
  }

  // Retrieve a boolean value with the given key from SharedPreferences.
  static Future<bool?> getSpBool(String key) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.getBool(key);
    } catch (e) {
      debugPrint("Error retrieving boolean: $e");
      return null;
    }
  }

  // Retrieve an integer value with the given key from SharedPreferences.
  static Future<int?> getSpInt(String key) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.getInt(key);
    } catch (e) {
      debugPrint("Error retrieving integer: $e");
      return null;
    }
  }

  // Retrieve a double value with the given key from SharedPreferences.
  static Future<double?> getSpDouble(String key) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.getDouble(key);
    } catch (e) {
      debugPrint("Error retrieving double: $e");
      return null;
    }
  }

  // Retrieve a string value with the given key from SharedPreferences.
  static Future<String?> getSpString(String key) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint("Error retrieving string: $e");
      return null;
    }
  }

  // Retrieve a list of strings with the given key from SharedPreferences.
  static Future<List<String>?> getSpStringList(String key) async {
    try {
      final prefs = await getPreferencesInstance();
      return prefs.getStringList(key);
    } catch (e) {
      debugPrint("Error retrieving string list: $e");
      return null;
    }
  }

  // get Loged in
  // static Future<bool> isUserLoggedIn() async {
  //   final prefs = await getPreferencesInstance();
  //   bool isLoggedIn = prefs.getBool(Const.IS_LOGED_IN) ?? false;
  //   return isLoggedIn;
  // }

  // Remove data associated with the given key from SharedPreferences.
  static Future<void> removeSp(String key) async {
    try {
      final prefs = await getPreferencesInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint("Error removing data: $e");
    }
  }

  // Clear all data from SharedPreferences.
  static Future<void> clearSp() async {
    try {
      final prefs = await getPreferencesInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint("Error clearing data: $e");
    }
  }

  // Get an instance of SharedPreferences.
  static Future<SharedPreferences> getPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }
  // end SP Utils
}