import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Create Account', style: AppTextStyles.titleMedium),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('Get Started 🚀', style: AppTextStyles.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Create your account to start messaging and sharing.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: controller.nameController,
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.iconGrey),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: controller.emailController,
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.iconGrey),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!GetUtils.isEmail(val.trim())) return 'Please enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password (min 6 characters)',
                    obscureText: controller.obscurePassword.value,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.iconGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.iconGrey,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter a password';
                      if (val.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => CustomButton(
                    text: 'Sign Up',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.signup,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTextStyles.bodyMedium),
                    GestureDetector(
                      onTap: controller.goToLogin,
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
