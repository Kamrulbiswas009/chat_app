import '../../core/network/api_exceptions.dart';
import '../../core/network/api_result.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

class UserRepository {
  final UserProvider _userProvider;

  UserRepository({UserProvider? userProvider})
      : _userProvider = userProvider ?? UserProvider();

  Future<ApiResult<List<UserModel>>> getUsers({
    int page = 1,
    int limit = 50,
    String? search,
    bool excludeSelf = true,
  }) async {
    try {
      final list = await _userProvider.getUsers(
        page: page,
        limit: limit,
        search: search,
        excludeSelf: excludeSelf,
      );
      return Success(list);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<UserModel>> getUserById(String id) async {
    try {
      final user = await _userProvider.getUserById(id);
      return Success(user);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<UserModel>>> searchUsers(String query, {int limit = 30}) async {
    try {
      final list = await _userProvider.searchUsers(query, limit: limit);
      return Success(list);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<UserModel>> updateProfile({String? name, String? bio, String? avatar}) async {
    try {
      final user = await _userProvider.updateProfile(name: name, bio: bio, avatar: avatar);
      return Success(user);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<String>> uploadAvatar(String filePath) async {
    try {
      final url = await _userProvider.uploadAvatar(filePath);
      return Success(url);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }
}
