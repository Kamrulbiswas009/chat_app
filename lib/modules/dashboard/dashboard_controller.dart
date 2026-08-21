import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Index 2 is "Messenger" which is the main chat tab
  final RxInt currentIndex = 2.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
