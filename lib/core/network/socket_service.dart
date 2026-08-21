import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/storage_service.dart';
import '../../data/models/message_model.dart';

class SocketService extends GetxService {
  static SocketService get to => Get.find();

  io.Socket? _socket;
  final StorageService _storage = StorageService.to;

  final RxBool isConnected = false.obs;
  final RxString typingUserName = ''.obs;
  final RxBool isOtherUserTyping = false.obs;

  // Stream Controllers for Reactive UI
  final _messageController = StreamController<MessageModel>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final _editedController = StreamController<MessageModel>.broadcast();
  final _deletedController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<MessageModel> get onNewMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onUserTyping => _typingController.stream;
  Stream<MessageModel> get onMessageEdited => _editedController.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _deletedController.stream;
  Stream<Map<String, dynamic>> get onPresenceUpdate => _presenceController.stream;

  Future<SocketService> init() async {
    if (_storage.isAuthenticated.value) {
      connect();
    }
    _storage.isAuthenticated.listen((authenticated) {
      if (authenticated) {
        connect();
      } else {
        disconnect();
      }
    });
    return this;
  }

  void connect() {
    final token = _storage.getAccessToken();
    final serverUrl = _storage.getBaseUrl();

    if (_socket != null && _socket!.connected) return;

    try {
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token ?? ''})
            .setExtraHeaders({
              if (token != null) 'Authorization': 'Bearer $token',
            })
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(10)
            .build(),
      );

      _setupListeners();
      _socket!.connect();
    } catch (e) {
      debugPrint('⚠️ Socket Connection error: $e');
    }
  }

  void _setupListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      debugPrint('🟢 Connected to Chat Socket: ${_socket!.id}');
      isConnected.value = true;
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔴 Disconnected from Chat Socket');
      isConnected.value = false;
    });

    _socket!.onConnectError((err) {
      debugPrint('⚠️ Socket Connection Error: $err');
      isConnected.value = false;
    });

    // 1. Receive New Message (new_message)
    _socket!.on('new_message', (data) {
      debugPrint('📩 New message received via Socket: $data');
      if (data is Map<String, dynamic>) {
        _messageController.add(MessageModel.fromJson(data));
      }
    });

    // 2. Typing Indicator (user_typing)
    _socket!.on('user_typing', (data) {
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        final isTyping = map['isTyping'] == true;
        final userName = map['userName']?.toString() ?? '';
        isOtherUserTyping.value = isTyping;
        typingUserName.value = isTyping ? userName : '';
        _typingController.add(map);
      }
    });

    // 3. Message Edited (message_edited)
    _socket!.on('message_edited', (data) {
      debugPrint('✏️ Message edited via Socket: $data');
      if (data is Map<String, dynamic>) {
        _editedController.add(MessageModel.fromJson(data));
      }
    });

    // 4. Message Deleted (message_deleted)
    _socket!.on('message_deleted', (data) {
      debugPrint('🗑️ Message deleted via Socket: $data');
      if (data is Map) {
        _deletedController.add(Map<String, dynamic>.from(data));
      }
    });

    // 5. Presence Update (presence_update)
    _socket!.on('presence_update', (data) {
      debugPrint('👤 Presence update: $data');
      if (data is Map) {
        _presenceController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  // --- Emitters ---

  void joinConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join_conversation', {'conversationId': conversationId});
    }
  }

  void leaveConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave_conversation', {'conversationId': conversationId});
    }
  }

  void sendTextMessage({
    required String conversationId,
    required String content,
    Function(dynamic)? onAck,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emitWithAck(
        'send_message',
        {
          'conversationId': conversationId,
          'content': content,
          'type': 'TEXT',
        },
        ack: onAck,
      );
    }
  }

  void sendTypingStatus({
    required String conversationId,
    required bool isTyping,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing', {
        'conversationId': conversationId,
        'isTyping': isTyping,
      });
    }
  }

  void editMessage({
    required String messageId,
    required String content,
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('edit_message', {
        'messageId': messageId,
        'content': content,
      });
    }
  }

  void deleteMessage({
    required String messageId,
    required String type, // 'ME' or 'EVERYONE'
  }) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('delete_message', {
        'messageId': messageId,
        'type': type,
      });
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      isConnected.value = false;
    }
  }

  @override
  void onClose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _editedController.close();
    _deletedController.close();
    _presenceController.close();
    super.onClose();
  }
}
