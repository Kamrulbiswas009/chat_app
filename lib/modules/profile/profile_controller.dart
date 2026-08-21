import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();
  final StorageService storage = StorageService.to;
  final ImagePicker _imagePicker = ImagePicker();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = storage.currentUser.value;
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    final result = await _authRepo.getMe();
    isLoading.value = false;

    if (result is Success<UserModel>) {
      user.value = result.data;
    }
  }

  Future<void> updateProfile(String name, String bio) async {
    isUpdating.value = true;
    final result = await _userRepo.updateProfile(name: name, bio: bio);
    isUpdating.value = false;

    if (result is Success<UserModel>) {
      user.value = result.data;
      storage.saveCurrentUser(result.data);
      Get.snackbar('Success', 'Profile updated successfully', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> changeAvatar() async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        isUpdating.value = true;
        final result = await _userRepo.uploadAvatar(file.path);
        isUpdating.value = false;

        if (result is Success<String>) {
          if (user.value != null) {
            final updated = user.value!.copyWith(avatarUrl: result.data);
            user.value = updated;
            storage.saveCurrentUser(updated);
          }
          Get.snackbar('Success', 'Avatar updated', snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      isUpdating.value = false;
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleMockBackend(bool value) async {
    await storage.setUseMockBackend(value);
    Get.snackbar(
      'Mode Switched',
      value ? 'Using in-memory Mock Backend' : 'Using Live Server: ${storage.getBaseUrl()}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> setCustomBaseUrl(String newUrl) async {
    if (newUrl.trim().isNotEmpty) {
      ApiClient.to.updateBaseUrl(newUrl.trim());
      Get.snackbar('Base URL Updated', newUrl.trim(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
