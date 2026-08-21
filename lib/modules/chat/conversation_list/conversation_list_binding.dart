import 'package:get/get.dart';
import 'conversation_list_controller.dart';

class ConversationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationListController>(() => ConversationListController());
  }
}
