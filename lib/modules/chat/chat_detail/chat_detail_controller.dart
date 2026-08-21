import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/socket_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/models/attachment_model.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatDetailController extends GetxController {
  final ChatRepository _chatRepo = ChatRepository();
  final StorageService _storage = StorageService.to;
  final SocketService socketService = SocketService.to;
  final ImagePicker _imagePicker = ImagePicker();

  late ConversationModel conversation;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<AttachmentModel> pendingAttachments = <AttachmentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isTyping = false.obs;
  final RxString typingStatusText = ''.obs;

  StreamSubscription? _msgSub;
  StreamSubscription? _editSub;
  StreamSubscription? _deleteSub;
  StreamSubscription? _typingSub;
  Timer? _typingDebounceTimer;

  String get currentUserId => _storage.currentUser.value?.id ?? 'usr_me_001';

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ConversationModel) {
      conversation = Get.arguments as ConversationModel;
      fetchMessages();
      _initSocketListeners();
    }
  }

  void _initSocketListeners() {
    // 1. Join Conversation Room
    socketService.joinConversation(conversation.id);

    // 2. Receive Real-Time Messages (new_message)
    _msgSub = socketService.onNewMessage.listen((newMsg) {
      if (newMsg.conversationId == conversation.id) {
        final existingIndex = messages.indexWhere((m) => m.id == newMsg.id);
        if (existingIndex == -1) {
          messages.add(newMsg);
          _scrollToBottom();
        }
      }
    });

    // 3. Receive Message Edited (message_edited)
    _editSub = socketService.onMessageEdited.listen((editedMsg) {
      final index = messages.indexWhere((m) => m.id == editedMsg.id);
      if (index != -1) {
        messages[index] = editedMsg;
      }
    });

    // 4. Receive Message Deleted (message_deleted)
    _deleteSub = socketService.onMessageDeleted.listen((data) {
      final messageId = data['messageId']?.toString();
      final type = data['type']?.toString();

      if (messageId != null) {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          if (type == 'EVERYONE') {
            messages[index] = messages[index].copyWith(
              text: 'This message was deleted',
              isDeleted: true,
              isDeletedForEveryone: true,
              attachments: [],
            );
          } else {
            messages.removeAt(index);
          }
        }
      }
    });

    // 5. Typing Indicators (user_typing)
    _typingSub = socketService.onUserTyping.listen((data) {
      final convId = data['conversationId']?.toString();
      final userId = data['userId']?.toString();
      final userIsTyping = data['isTyping'] == true;
      final userName = data['userName']?.toString() ?? conversation.participant.name;

      if (convId == conversation.id && userId != currentUserId) {
        isTyping.value = userIsTyping;
        typingStatusText.value = userIsTyping ? '$userName is typing...' : '';
      }
    });

    // Setup input text change listener for emitting typing
    textController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    if (textController.text.isNotEmpty) {
      socketService.sendTypingStatus(
        conversationId: conversation.id,
        isTyping: true,
      );

      _typingDebounceTimer?.cancel();
      _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
        socketService.sendTypingStatus(
          conversationId: conversation.id,
          isTyping: false,
        );
      });
    }
  }

  @override
  void onClose() {
    socketService.sendTypingStatus(
      conversationId: conversation.id,
      isTyping: false,
    );
    socketService.leaveConversation(conversation.id);

    _msgSub?.cancel();
    _editSub?.cancel();
    _deleteSub?.cancel();
    _typingSub?.cancel();
    _typingDebounceTimer?.cancel();
    textController.removeListener(_onInputChanged);
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    final result = await _chatRepo.getMessages(conversation.id);
    isLoading.value = false;

    if (result is Success<List<MessageModel>>) {
      messages.assignAll(result.data);
      _scrollToBottom();
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty && pendingAttachments.isEmpty) return;

    final attachmentsToSend = List<AttachmentModel>.from(pendingAttachments);
    textController.clear();
    pendingAttachments.clear();

    // Stop typing
    socketService.sendTypingStatus(conversationId: conversation.id, isTyping: false);

    isSending.value = true;

    // Send via Socket.IO if text-only and connected, or via REST API with multipart if attachments exist
    if (attachmentsToSend.isEmpty && socketService.isConnected.value) {
      socketService.sendTextMessage(
        conversationId: conversation.id,
        content: text,
      );
    }

    final result = await _chatRepo.sendMessage(
      conversation.id,
      text: text,
      attachments: attachmentsToSend,
    );
    isSending.value = false;

    if (result is Success<MessageModel>) {
      if (!messages.any((m) => m.id == result.data.id)) {
        messages.add(result.data);
      }
      _scrollToBottom();

      if (_storage.useMockBackend.value) {
        _simulateBotReply(text);
      }
    }
  }

  void _simulateBotReply(String userMessage) {
    Future.delayed(const Duration(milliseconds: 1200), () async {
      final replies = [
        "Sounds good! Let's proceed with that.",
        "Got it! Thanks for the update.",
        "Could you send me more details about the timeline?",
        "Perfect! I will review the specifications.",
        "Thank you! Let me check on the inventory right away.",
      ];
      final randomReply = replies[(DateTime.now().millisecond) % replies.length];

      final autoMsg = MessageModel(
        id: 'msg_reply_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversation.id,
        senderId: conversation.participant.id,
        senderName: conversation.participant.name,
        senderAvatar: conversation.participant.avatarUrl,
        text: randomReply,
        createdAt: DateTime.now(),
      );

      messages.add(autoMsg);
      _scrollToBottom();
    });
  }

  Future<void> editMessage(String messageId, String newText) async {
    // Emit via Socket.IO
    socketService.editMessage(messageId: messageId, content: newText);

    // Call REST endpoint
    final result = await _chatRepo.editMessage(messageId, newText);
    if (result is Success<MessageModel>) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = result.data;
      }
    }
  }

  Future<void> deleteMessage(String messageId, bool deleteForEveryone) async {
    final type = deleteForEveryone ? 'EVERYONE' : 'ME';

    // Emit via Socket.IO
    socketService.deleteMessage(messageId: messageId, type: type);

    // Call REST endpoint
    final result = await _chatRepo.deleteMessage(messageId, deleteForEveryone: deleteForEveryone);
    if (result is Success) {
      if (deleteForEveryone) {
        final index = messages.indexWhere((m) => m.id == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            text: 'This message was deleted',
            isDeleted: true,
            isDeletedForEveryone: true,
            attachments: [],
          );
        }
      } else {
        messages.removeWhere((m) => m.id == messageId);
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    Get.back();
    try {
      final XFile? file = await _imagePicker.pickImage(source: source);
      if (file != null) {
        final uploadResult = await _chatRepo.uploadAttachment(
          filePath: file.path,
          type: 'image',
          fileName: file.name,
        );
        if (uploadResult is Success<AttachmentModel>) {
          pendingAttachments.add(uploadResult.data);
        }
      }
    } catch (e) {
      Get.snackbar('Picker error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickDocument() async {
    Get.back();
    try {
      final result = await FilePicker.pickFiles();
      if (result.isNotEmpty) {
        final file = result.first;
        if (file.path != null) {
          final uploadResult = await _chatRepo.uploadAttachment(
            filePath: file.path!,
            type: 'file',
            fileName: file.name,
          );
          if (uploadResult is Success<AttachmentModel>) {
            pendingAttachments.add(uploadResult.data);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Picker error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> pickAudio() async {
    Get.back();
    final uploadResult = await _chatRepo.uploadAttachment(
      filePath: 'audio.mp3',
      type: 'audio',
      fileName: 'Voice_Note.mp3',
    );
    if (uploadResult is Success<AttachmentModel>) {
      pendingAttachments.add(uploadResult.data);
    }
  }

  void removePendingAttachment(int index) {
    if (index >= 0 && index < pendingAttachments.length) {
      pendingAttachments.removeAt(index);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
