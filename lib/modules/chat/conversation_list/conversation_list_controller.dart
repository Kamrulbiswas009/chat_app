import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/repositories/chat_repository.dart';

class ConversationListController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final SocketService _socketService = SocketService.to;

  final searchController = TextEditingController();
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxList<ConversationModel> filteredConversations = <ConversationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;

  StreamSubscription? _msgSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    _initSocketListener();
  }

  void _initSocketListener() {
    _msgSubscription = _socketService.onNewMessage.listen((msg) {
      final index = conversations.indexWhere((c) => c.id == msg.conversationId);
      if (index != -1) {
        final conv = conversations[index];
        final updatedConv = conv.copyWith(
          lastMessage: msg,
          updatedAt: msg.createdAt,
        );
        conversations.removeAt(index);
        conversations.insert(0, updatedConv);
        applySearch(searchController.text);
      } else {
        fetchConversations();
      }
    });
  }

  @override
  void onClose() {
    _msgSubscription?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    final result = await _chatRepo.getConversations();
    isLoading.value = false;

    if (result is Success<List<ConversationModel>>) {
      conversations.assignAll(result.data);
      applySearch(searchController.text);
    } else if (result is Failure<List<ConversationModel>>) {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void applySearch(String query) {
    if (query.trim().isEmpty) {
      isSearching.value = false;
      filteredConversations.assignAll(conversations);
    } else {
      isSearching.value = true;
      final q = query.toLowerCase();
      filteredConversations.assignAll(
        conversations.where((conv) {
          final nameMatch = conv.participant.name.toLowerCase().contains(q);
          final msgMatch = conv.lastMessage?.text.toLowerCase().contains(q) ?? false;
          return nameMatch || msgMatch;
        }).toList(),
      );
    }
  }

  void openChat(ConversationModel conversation) {
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: conversation,
    )?.then((_) => fetchConversations());
  }

  void openNewChat() {
    Get.toNamed(AppRoutes.newChat)?.then((_) => fetchConversations());
  }
}
