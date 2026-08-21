import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/message_model.dart';

class EditMessageDialog {
  static void showOptions({
    required BuildContext context,
    required MessageModel message,
    required bool isMe,
    required Function(String) onEdit,
    required Function(bool deleteForEveryone) onDelete,
  }) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: AppColors.iconGrey),
              title: Text('Copy Text', style: AppTextStyles.bodyLarge),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.text));
                Get.back();
                Get.snackbar(
                  'Copied',
                  'Message copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            if (isMe && !message.isDeleted) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: Text('Edit Message', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Get.back();
                  _showEditDialog(message.text, onEdit);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
              title: Text('Delete Message', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.errorRed)),
              onTap: () {
                Get.back();
                _showDeleteDialog(isMe, onDelete);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static void _showEditDialog(String currentText, Function(String) onEdit) {
    final controller = TextEditingController(text: currentText);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Message', style: AppTextStyles.titleMedium),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter new message text',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onEdit(controller.text.trim());
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _showDeleteDialog(bool isMe, Function(bool) onDelete) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Message?', style: AppTextStyles.titleMedium),
        content: Text(
          isMe
              ? 'Do you want to delete this message for everyone or only for yourself?'
              : 'Do you want to remove this message from your chat?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          if (isMe)
            TextButton(
              onPressed: () {
                Get.back();
                onDelete(true);
              },
              child: Text('Delete for Everyone', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onDelete(false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete For Me', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
