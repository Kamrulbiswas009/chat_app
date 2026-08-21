import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../chat/conversation_list/conversation_list_view.dart';
import '../profile/profile_view.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildPlaceholderTab(
        title: 'Home',
        icon: Icons.home_outlined,
        description: 'Explore trending items, promotions, and updates.',
      ),
      _buildPlaceholderTab(
        title: 'Categories',
        icon: Icons.grid_view_rounded,
        description: 'Browse products and services across multiple categories.',
      ),
      const ConversationListView(showBackButton: false),
      _buildPlaceholderTab(
        title: 'Cart',
        icon: Icons.shopping_cart_outlined,
        description: 'Your selected order items and checkout bag.',
      ),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFF0F1F3), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.navActive,
            unselectedItemColor: AppColors.navInactive,
            selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              color: AppColors.navActive,
            ),
            unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 11.5,
              color: AppColors.navInactive,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.home_rounded, size: 24),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.grid_view_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.grid_view_rounded, size: 22),
                ),
                label: 'category',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 23),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.chat_bubble_rounded, size: 23),
                ),
                label: 'Messenger',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.shopping_cart_outlined, size: 23),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.shopping_cart_rounded, size: 23),
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.person_outline_rounded, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.person_rounded, size: 24),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.titleMedium),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
