import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_avatar.dart';
import 'chat_detail_controller.dart';
import 'widgets/attachment_sheet.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/edit_message_dialog.dart';

class ChatDetailView extends GetView<ChatDetailController> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final participant = controller.conversation.participant;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 44,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CustomAvatar(
              imageUrl: participant.avatarUrl,
              name: participant.name,
              radius: 18,
              isOnline: participant.isOnline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    participant.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(() {
                    if (controller.isTyping.value) {
                      return Text(
                        'typing...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return Text(
                      participant.isOnline ? 'Online' : 'Offline',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: participant.isOnline ? AppColors.onlineGreen : AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Storefront / Shop Icon
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Color(0xFF334155),
                size: 20,
              ),
            ),
            tooltip: 'Store Profile',
            onPressed: () {
              Get.snackbar(
                'Store Profile',
                'Viewing ${participant.name}\'s shop profile',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          // Call Icon (Blue)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone,
                color: Color(0xFF1D4ED8),
                size: 20,
              ),
            ),
            tooltip: 'Call',
            onPressed: () {
              Get.snackbar(
                'Voice Call',
                'Calling ${participant.name}...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            // Messages List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (controller.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomAvatar(
                          imageUrl: participant.avatarUrl,
                          name: participant.name,
                          radius: 36,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Say hello to ${participant.name} 👋',
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Send a message to start the chat',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final isMe = msg.senderId == controller.currentUserId;

                    return ChatBubble(
                      message: msg,
                      isMe: isMe,
                      participantAvatar: participant.avatarUrl,
                      participantName: participant.name,
                      onLongPress: () {
                        EditMessageDialog.showOptions(
                          context: context,
                          message: msg,
                          isMe: isMe,
                          onEdit: (newText) => controller.editMessage(msg.id, newText),
                          onDelete: (delForEveryone) => controller.deleteMessage(msg.id, delForEveryone),
                        );
                      },
                    );
                  },
                );
              }),
            ),

            // Input Bar
            Obx(
              () => ChatInputBar(
                textController: controller.textController,
                pendingAttachments: controller.pendingAttachments,
                isSending: controller.isSending.value,
                onSend: controller.sendMessage,
                onRemoveAttachment: controller.removePendingAttachment,
                onAttachmentTap: () => _showAttachmentModal(context),
                onEmojiTap: () {
                  controller.textController.text += ' 😊';
                  controller.textController.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.textController.text.length),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentModal(BuildContext context) {
    Get.bottomSheet(
      AttachmentSheet(
        onPickImage: () => controller.pickImage(ImageSource.gallery),
        onPickCamera: () => controller.pickImage(ImageSource.camera),
        onPickDocument: () => controller.pickDocument(),
        onPickAudio: () => controller.pickAudio(),
      ),
    );
  }
}
