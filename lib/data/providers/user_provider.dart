import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/mock_backend_service.dart';
import '../../core/storage/storage_service.dart';
import '../models/user_model.dart';

class UserProvider {
  final ApiClient _apiClient = ApiClient.to;
  final MockBackendService _mockBackend = MockBackendService();
  final StorageService _storage = StorageService.to;

  Future<List<UserModel>> getUsers({
    int page = 1,
    int limit = 50,
    String? search,
    bool excludeSelf = true,
  }) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getUsers();
    }
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'excludeSelf': excludeSelf,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _apiClient.dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
      );

      dynamic rawData = response.data;
      if (rawData is Map) {
        if (rawData['data'] != null) {
          rawData = rawData['data'];
        }
      }

      List list = [];
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map) {
        if (rawData['users'] is List) {
          list = rawData['users'];
        } else if (rawData['data'] is List) {
          list = rawData['data'];
        }
      }

      return list.map((item) => UserModel.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<UserModel> getUserById(String id) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getUserById(id);
    }
    try {
      final response = await _apiClient.dio.get(ApiConstants.userDetail(id));
      final dynamic raw = response.data;
      final data = (raw is Map && raw['data'] != null) ? raw['data'] : raw;
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<UserModel>> searchUsers(String query, {int limit = 30}) async {
    return getUsers(search: query, excludeSelf: true, limit: limit);
  }

  Future<UserModel> updateProfile({String? name, String? bio, String? avatar}) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.updateProfile(name: name, bio: bio);
    }
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (bio != null) payload['bio'] = bio;
      if (avatar != null) payload['avatar'] = avatar;

      final response = await _apiClient.dio.patch(
        ApiConstants.userProfile,
        data: payload,
      );
      final data = response.data is Map<String, dynamic> ? response.data : response.data['data'];
      return UserModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.uploadAvatar(filePath);
    }
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.userAvatar,
        data: formData,
      );
      return response.data['avatarUrl'] ?? response.data['avatar'] ?? response.data['url'] ?? response.data['avatar_url'];
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }
}
