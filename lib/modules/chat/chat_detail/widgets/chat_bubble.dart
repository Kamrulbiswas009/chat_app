import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../data/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String? participantAvatar;
  final String participantName;
  final VoidCallback? onLongPress;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.participantAvatar,
    required this.participantName,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormatter.formatMessageTimestamp(message.createdAt);

    if (isMe) {
      return _buildOutgoingMessage(context, formattedTime);
    } else {
      return _buildIncomingMessage(context, formattedTime);
    }
  }

  Widget _buildIncomingMessage(BuildContext context, String formattedTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CustomAvatar(
            imageUrl: participantAvatar,
            name: participantName,
            radius: 20,
          ),
          const SizedBox(width: 12),

          // Message Bubble & Timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.incomingBubbleBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFECEEF2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.attachments.isNotEmpty) ...[
                          _buildAttachmentsList(context),
                          if (message.text.isNotEmpty) const SizedBox(height: 8),
                        ],
                        if (message.text.isNotEmpty)
                          Text(
                            message.text,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontSize: 14.5,
                              color: message.isDeleted
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited) ...[
                        Text(
                          '(edited) ',
                          style: AppTextStyles.timestamp.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      Text(
                        formattedTime,
                        style: AppTextStyles.timestamp.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF9EA3AE),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingMessage(BuildContext context, String formattedTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: GestureDetector(
                onLongPress: onLongPress,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.outgoingBubbleBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFECEEF2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.attachments.isNotEmpty) ...[
                        _buildAttachmentsList(context),
                        if (message.text.isNotEmpty) const SizedBox(height: 8),
                      ],
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 14.5,
                            color: message.isDeleted
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited) ...[
                Text(
                  '(edited) ',
                  style: AppTextStyles.timestamp.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                ),
              ],
              Text(
                formattedTime,
                style: AppTextStyles.timestamp.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF9EA3AE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsList(BuildContext context) {
    return Column(
      children: message.attachments.map((att) {
        if (att.type == 'image') {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: att.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
              placeholder: (context, url) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
              ),
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  att.type == 'video'
                      ? Icons.videocam
                      : att.type == 'audio'
                          ? Icons.audiotrack
                          : Icons.insert_drive_file,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    att.fileName ?? 'Attachment (${att.type})',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }
      }).toList(),
    );
  }
}
