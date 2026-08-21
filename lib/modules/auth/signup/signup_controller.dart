import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_result.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/repositories/auth_repository.dart';

class SignupController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    final result = await _authRepo.signup(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    isLoading.value = false;

    if (result is Success<AuthResponseModel>) {
      Get.offAllNamed(AppRoutes.dashboard);
    } else if (result is Failure<AuthResponseModel>) {
      Get.snackbar(
        'Signup Failed',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void goToLogin() {
    Get.back();
  }
}
