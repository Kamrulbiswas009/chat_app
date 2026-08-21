import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final StorageService _storage = StorageService.to;
  final AuthRepository _authRepo = AuthRepository();

  @override
  void onInit() {
    super.onInit();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final token = _storage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      // User is already logged in, fetch profile and enter dashboard
      final result = await _authRepo.getMe();
      if (result.isSuccess) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        // Token expired/invalid, take user to login
        Get.offAllNamed(AppRoutes.login);
      }
    } else {
      // New user or logged out -> Take directly to Sign In / Sign Up
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
