import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AttachmentSheet extends StatelessWidget {
  final VoidCallback onPickImage;
  final VoidCallback onPickCamera;
  final VoidCallback onPickDocument;
  final VoidCallback onPickAudio;

  const AttachmentSheet({
    super.key,
    required this.onPickImage,
    required this.onPickCamera,
    required this.onPickDocument,
    required this.onPickAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share Content',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: const Color(0xFF6366F1),
                onTap: onPickImage,
              ),
              _buildOption(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: const Color(0xFFEC4899),
                onTap: onPickCamera,
              ),
              _buildOption(
                icon: Icons.insert_drive_file_rounded,
                label: 'Document',
                color: const Color(0xFF3B82F6),
                onTap: onPickDocument,
              ),
              _buildOption(
                icon: Icons.mic_rounded,
                label: 'Audio',
                color: const Color(0xFF10B981),
                onTap: onPickAudio,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
