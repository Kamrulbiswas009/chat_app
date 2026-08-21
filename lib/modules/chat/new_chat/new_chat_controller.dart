import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_result.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';

class NewChatController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final ChatRepository _chatRepo = ChatRepository();

  final searchController = TextEditingController();
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    final result = await _userRepo.getUsers();
    isLoading.value = false;

    if (result is Success<List<UserModel>>) {
      users.assignAll(result.data);
      filteredUsers.assignAll(result.data);
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      filteredUsers.assignAll(users);
      return;
    }
    final result = await _userRepo.searchUsers(query.trim());
    if (result is Success<List<UserModel>>) {
      filteredUsers.assignAll(result.data);
    }
  }

  Future<void> startConversation(UserModel targetUser) async {
    final result = await _chatRepo.createOrGetConversation(targetUser.id);
    if (result is Success<ConversationModel>) {
      Get.offNamed(AppRoutes.chatDetail, arguments: result.data);
    }
  }
}
