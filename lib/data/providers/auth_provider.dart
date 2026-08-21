import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/mock_backend_service.dart';
import '../../core/storage/storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthProvider {
  final ApiClient _apiClient = ApiClient.to;
  final MockBackendService _mockBackend = MockBackendService();
  final StorageService _storage = StorageService.to;

  Future<AuthResponseModel> login(String email, String password) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.login(email, password);
    }
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data is Map<String, dynamic> ? response.data : {'data': response.data};
      return AuthResponseModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<AuthResponseModel> signup(String name, String email, String password, {String? bio, String? avatar}) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.signup(name, email, password);
    }
    try {
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      };
      if (bio != null && bio.isNotEmpty) payload['bio'] = bio;
      if (avatar != null && avatar.isNotEmpty) payload['avatar'] = avatar;

      final response = await _apiClient.dio.post(
        ApiConstants.signup,
        data: payload,
      );
      final data = response.data is Map<String, dynamic> ? response.data : {'data': response.data};
      return AuthResponseModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> logout() async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.logout();
    }
    try {
      await _apiClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Best effort logout
    }
  }

  Future<UserModel> getMe() async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getMe();
    }
    try {
      final response = await _apiClient.dio.get(ApiConstants.me);
      final data = response.data is Map<String, dynamic> ? response.data : response.data['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<String> refreshToken(String refreshToken) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.refreshToken();
    }
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return response.data['accessToken'] ?? response.data['access_token'] ?? response.data['token'];
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }
}
