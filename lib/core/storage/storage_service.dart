import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../constants/api_constants.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late SharedPreferences _prefs;

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyBaseUrl = 'base_url';
  static const String _keyUseMockBackend = 'use_mock_backend';

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  // Default to FALSE: Always use real backend API
  final RxBool useMockBackend = false.obs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    final userJson = _prefs.getString(_keyCurrentUser);
    if (userJson != null) {
      try {
        currentUser.value = UserModel.fromJson(jsonDecode(userJson));
        isAuthenticated.value = getAccessToken() != null;
      } catch (e) {
        currentUser.value = null;
        isAuthenticated.value = false;
      }
    }

    useMockBackend.value = _prefs.getBool(_keyUseMockBackend) ?? false;
    return this;
  }

  // Tokens
  String? getAccessToken() => _prefs.getString(_keyAccessToken);

  Future<void> setAccessToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_keyAccessToken);
    } else {
      await _prefs.setString(_keyAccessToken, token);
    }
    isAuthenticated.value = token != null;
  }

  String? getRefreshToken() => _prefs.getString(_keyRefreshToken);

  Future<void> setRefreshToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_keyRefreshToken);
    } else {
      await _prefs.setString(_keyRefreshToken, token);
    }
  }

  // User Profile
  Future<void> saveCurrentUser(UserModel user) async {
    currentUser.value = user;
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toJson()));
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyAccessToken);
    await _prefs.remove(_keyRefreshToken);
    await _prefs.remove(_keyCurrentUser);
    currentUser.value = null;
    isAuthenticated.value = false;
  }

  // Base URL configuration
  String getBaseUrl() => _prefs.getString(_keyBaseUrl) ?? ApiConstants.defaultBaseUrl;

  Future<void> setBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  // Mock Backend Toggle
  Future<void> setUseMockBackend(bool value) async {
    useMockBackend.value = value;
    await _prefs.setBool(_keyUseMockBackend, value);
  }
}
