import 'package:get/get.dart';
import '../chat/conversation_list/conversation_list_controller.dart';
import '../profile/profile_controller.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ConversationListController>(() => ConversationListController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
