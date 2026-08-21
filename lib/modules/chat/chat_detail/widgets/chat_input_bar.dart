import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../data/models/attachment_model.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final VoidCallback onSend;
  final VoidCallback onAttachmentTap;
  final VoidCallback onEmojiTap;
  final List<AttachmentModel> pendingAttachments;
  final Function(int) onRemoveAttachment;
  final bool isSending;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.onSend,
    required this.onAttachmentTap,
    required this.onEmojiTap,
    this.pendingAttachments = const [],
    required this.onRemoveAttachment,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 4
            : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF0F1F3), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pending attachments preview
          if (pendingAttachments.isNotEmpty) ...[
            SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pendingAttachments.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final att = pendingAttachments[index];
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              att.type == 'image' ? Icons.image : Icons.file_present,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              att.fileName ?? 'File',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => onRemoveAttachment(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.errorRed,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Attachment (+) Button
              InkWell(
                onTap: onAttachmentTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFDCDFE5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF555B68),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Middle Message Input Pill
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Send  quick message...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xFFA0A5B0),
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => onSend(),
                        ),
                      ),
                      // Emoji Icon
                      GestureDetector(
                        onTap: onEmojiTap,
                        child: const Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                          color: Color(0xFF757A82),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Right Send Button (Coral circle with paperplane)
              GestureDetector(
                onTap: isSending ? null : onSend,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
