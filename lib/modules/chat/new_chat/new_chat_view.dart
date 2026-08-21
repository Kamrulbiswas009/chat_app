import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_avatar.dart';
import 'new_chat_controller.dart';

class NewChatView extends StatelessWidget {
  const NewChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewChatController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Conversation', style: AppTextStyles.titleMedium),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search user bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.searchUsers,
                        style: AppTextStyles.bodyMedium,
                        decoration: const InputDecoration(
                          hintText: 'Search name or email...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (controller.filteredUsers.isEmpty) {
                  return Center(
                    child: Text('No users found', style: AppTextStyles.bodyMedium),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: controller.filteredUsers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return InkWell(
                      onTap: () => controller.startConversation(user),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF0F1F3)),
                        ),
                        child: Row(
                          children: [
                            CustomAvatar(
                              imageUrl: user.avatarUrl,
                              name: user.name,
                              radius: 22,
                              isOnline: user.isOnline,
                              showOnlineBadge: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: AppTextStyles.titleSmall.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user.bio ?? user.email,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
