import '../../core/network/api_exceptions.dart';
import '../../core/network/api_result.dart';
import '../../core/storage/storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _authProvider;
  final StorageService _storage = StorageService.to;

  AuthRepository({AuthProvider? authProvider})
      : _authProvider = authProvider ?? AuthProvider();

  Future<ApiResult<AuthResponseModel>> login(String email, String password) async {
    try {
      final res = await _authProvider.login(email, password);
      await _storage.setAccessToken(res.accessToken);
      if (res.refreshToken != null) {
        await _storage.setRefreshToken(res.refreshToken);
      }
      await _storage.saveCurrentUser(res.user);
      return Success(res);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''));
    }
  }

  Future<ApiResult<AuthResponseModel>> signup(String name, String email, String password) async {
    try {
      final res = await _authProvider.signup(name, email, password);
      if (res.accessToken.isNotEmpty) {
        await _storage.setAccessToken(res.accessToken);
        if (res.refreshToken != null) {
          await _storage.setRefreshToken(res.refreshToken);
        }
        await _storage.saveCurrentUser(res.user);
        return Success(res);
      } else {
        return await login(email, password);
      }
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } finally {
      await _storage.clearAuth();
    }
  }

  Future<ApiResult<UserModel>> getMe() async {
    try {
      final user = await _authProvider.getMe();
      await _storage.saveCurrentUser(user);
      return Success(user);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString().replaceAll('ApiException: ', '').replaceAll('Exception: ', ''));
    }
  }
}
