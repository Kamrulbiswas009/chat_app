import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_avatar.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile & Settings', style: AppTextStyles.titleMedium),
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          final user = controller.user.value;
          if (controller.isLoading.value && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Avatar with edit button
                Center(
                  child: Stack(
                    children: [
                      CustomAvatar(
                        imageUrl: user?.avatarUrl,
                        name: user?.name ?? 'User',
                        radius: 46,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: controller.changeAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodyMedium,
                ),
                if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    user.bio!,
                    style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 28),

                // Settings Group: Profile Details
                _buildSettingsCard(
                  title: 'Account Settings',
                  items: [
                    _buildSettingsTile(
                      icon: Icons.person_outline,
                      title: 'Edit Profile Information',
                      subtitle: 'Change name and status/bio',
                      onTap: () => _showEditProfileDialog(context, user?.name ?? '', user?.bio ?? ''),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Settings Group: Backend & API Configuration
                _buildSettingsCard(
                  title: 'Backend & Network Flow',
                  items: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.hub_outlined, color: AppColors.primary),
                      ),
                      title: Text('Use Mock Backend Service', style: AppTextStyles.titleSmall.copyWith(fontSize: 15)),
                      subtitle: Text(
                        controller.storage.useMockBackend.value
                            ? 'Simulating backend responses locally'
                            : 'Using live HTTP REST API',
                        style: AppTextStyles.bodySmall,
                      ),
                      trailing: Switch(
                        value: controller.storage.useMockBackend.value,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => controller.toggleMockBackend(val),
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _buildSettingsTile(
                      icon: Icons.link_rounded,
                      title: 'API Server Base URL',
                      subtitle: controller.storage.getBaseUrl(),
                      onTap: () => _showBaseUrlDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Logout
                _buildSettingsCard(
                  title: 'Session',
                  items: [
                    _buildSettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      subtitle: 'Terminate session and clear tokens',
                      textColor: AppColors.errorRed,
                      iconColor: AppColors.errorRed,
                      onTap: controller.logout,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSettingsCard({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontSize: 15,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentBio) {
    final nameCtrl = TextEditingController(text: currentName);
    final bioCtrl = TextEditingController(text: currentBio);

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Profile Details', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(labelText: 'Bio / Status', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Get.back();
              controller.updateProfile(nameCtrl.text.trim(), bioCtrl.text.trim());
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBaseUrlDialog(BuildContext context) {
    final urlCtrl = TextEditingController(text: controller.storage.getBaseUrl());

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Set API Base URL', style: AppTextStyles.titleMedium),
        content: TextField(
          controller: urlCtrl,
          decoration: const InputDecoration(
            hintText: 'e.g. http://localhost:8000',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Get.back();
              controller.setCustomBaseUrl(urlCtrl.text.trim());
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
