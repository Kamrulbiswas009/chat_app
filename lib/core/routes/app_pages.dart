import 'package:get/get.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/signup/signup_binding.dart';
import '../../modules/auth/signup/signup_view.dart';
import '../../modules/chat/chat_detail/chat_detail_binding.dart';
import '../../modules/chat/chat_detail/chat_detail_view.dart';
import '../../modules/chat/conversation_list/conversation_list_binding.dart';
import '../../modules/chat/conversation_list/conversation_list_view.dart';
import '../../modules/chat/new_chat/new_chat_view.dart';
import '../../modules/dashboard/dashboard_binding.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.chatList,
      page: () => const ConversationListView(),
      binding: ConversationListBinding(),
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailView(),
      binding: ChatDetailBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: AppRoutes.newChat,
      page: () => const NewChatView(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
