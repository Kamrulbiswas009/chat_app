import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool isOnline;
  final bool showOnlineBadge;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.isOnline = false,
    this.showOnlineBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarContent;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      avatarContent = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      avatarContent = _buildPlaceholder();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: avatarContent,
          ),
        ),
        if (showOnlineBadge && isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: AppColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: const Color(0xFFD6E2EA),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: name.isNotEmpty
            ? Text(
                name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: const Color(0xFF4A708B),
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.8,
                ),
              )
            : Icon(
                Icons.person,
                color: const Color(0xFF6B8E9E),
                size: radius * 1.1,
              ),
      ),
    );
  }
}
