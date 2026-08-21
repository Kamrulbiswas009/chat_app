import 'dart:async';
import '../../data/models/user_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/attachment_model.dart';
import '../../data/models/auth_response_model.dart';

class MockBackendService {
  static final MockBackendService _instance = MockBackendService._internal();
  factory MockBackendService() => _instance;

  MockBackendService._internal() {
    _initSeedData();
  }

  late UserModel currentUser;
  final List<UserModel> users = [];
  final List<ConversationModel> conversations = [];
  final Map<String, List<MessageModel>> messagesByConversationId = {};

  void _initSeedData() {
    currentUser = UserModel(
      id: 'usr_me_001',
      name: 'Kamrul Biswas',
      email: 'kamrulbiswas81@gmail.com',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      bio: 'Flutter Developer & Tech Enthusiast',
      isOnline: true,
      createdAt: DateTime(2025, 1, 1),
    );

    final seedUsers = [
      UserModel(
        id: 'usr_001',
        name: 'Marvin McKinney',
        email: 'marvin@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        bio: 'Jazz singer and cultural icon. Known for her soulful melodies.',
        isOnline: true,
        lastSeenAt: DateTime.now(),
      ),
      UserModel(
        id: 'usr_002',
        name: 'Darlene Robertson',
        email: 'darlene@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        bio: 'Jazz singer and cultural icon. Known for her ...',
        isOnline: false,
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      UserModel(
        id: 'usr_003',
        name: 'Robert Fox',
        email: 'robert@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        bio: 'Jazz singer and cultural icon. Known for her ...',
        isOnline: true,
        lastSeenAt: DateTime.now(),
      ),
      UserModel(
        id: 'usr_004',
        name: 'Guy Hawkins',
        email: 'guy@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
        bio: 'Jazz singer and cultural icon. Known for her ...',
        isOnline: false,
        lastSeenAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      UserModel(
        id: 'usr_005',
        name: 'Ronald Richards',
        email: 'ronald@example.com',
        avatarUrl: null, // Test default avatar placeholder as in screenshot
        bio: 'Jazz singer and cultural icon. Known for her ...',
        isOnline: false,
        lastSeenAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserModel(
        id: 'usr_006',
        name: 'Leslie Alexander',
        email: 'leslie@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        bio: 'Jazz singer and cultural icon. Known for her ...',
        isOnline: true,
        lastSeenAt: DateTime.now(),
      ),
      UserModel(
        id: 'usr_007',
        name: 'Jacob Jones',
        email: 'jacob@example.com',
        avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
        bio: 'Jazz singer and cultural icon. Known for her ...',
        isOnline: false,
        lastSeenAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];

    users.clear();
    users.addAll(seedUsers);

    // Initial Messages for Marvin McKinney (matching screenshot 3)
    final marvinConvId = 'conv_001';
    final baseTime = DateTime(2025, 6, 17, 16, 10);
    
    final marvinMessages = [
      MessageModel(
        id: 'msg_001',
        conversationId: marvinConvId,
        senderId: seedUsers[0].id,
        senderName: seedUsers[0].name,
        senderAvatar: seedUsers[0].avatarUrl,
        text: "Hello, I'm interested in purchasing 500 units of your wireless earbuds.",
        createdAt: baseTime,
      ),
      MessageModel(
        id: 'msg_002',
        conversationId: marvinConvId,
        senderId: currentUser.id,
        senderName: currentUser.name,
        senderAvatar: currentUser.avatarUrl,
        text: "Hello, I'm interested in purchasing 500 units of your wireless earbuds.",
        createdAt: baseTime.add(const Duration(minutes: 2)),
      ),
      MessageModel(
        id: 'msg_003',
        conversationId: marvinConvId,
        senderId: seedUsers[0].id,
        senderName: seedUsers[0].name,
        senderAvatar: seedUsers[0].avatarUrl,
        text: "Hello, I'm interested in purchasing 500 units of your wireless earbuds.",
        createdAt: baseTime.add(const Duration(minutes: 5)),
      ),
    ];

    messagesByConversationId[marvinConvId] = marvinMessages;

    // Build conversation list matching screenshot 2
    conversations.clear();
    for (int i = 0; i < seedUsers.length; i++) {
      final user = seedUsers[i];
      final convId = i == 0 ? marvinConvId : 'conv_00${i + 1}';
      
      final lastMsg = (i == 0)
          ? marvinMessages.last
          : MessageModel(
              id: 'msg_init_${user.id}',
              conversationId: convId,
              senderId: user.id,
              senderName: user.name,
              senderAvatar: user.avatarUrl,
              text: 'Jazz singer and cultural icon. Known for her ...',
              createdAt: DateTime(2025, 6, 17, 15, 50),
            );

      if (i > 0) {
        messagesByConversationId[convId] = [lastMsg];
      }

      conversations.add(
        ConversationModel(
          id: convId,
          participant: user,
          lastMessage: lastMsg,
          unreadCount: i == 0 ? 2 : 0,
          updatedAt: lastMsg.createdAt,
          createdAt: DateTime(2025, 6, 10),
        ),
      );
    }
  }

  // --- Auth Endpoints ---
  Future<AuthResponseModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return AuthResponseModel(
      accessToken: 'mock_jwt_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_jwt_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      user: currentUser.copyWith(email: email),
    );
  }

  Future<AuthResponseModel> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newUser = currentUser.copyWith(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
    );
    currentUser = newUser;
    return AuthResponseModel(
      accessToken: 'mock_jwt_access_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_jwt_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      user: newUser,
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<UserModel> getMe() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return currentUser;
  }

  Future<String> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return 'mock_jwt_refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  // --- Chat Endpoints ---
  Future<List<ConversationModel>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 250));
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.from(conversations);
  }

  Future<ConversationModel> getOrCreateConversation(String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final existingIndex = conversations.indexWhere((c) => c.participant.id == targetUserId);
    if (existingIndex != -1) {
      return conversations[existingIndex];
    }

    final targetUser = users.firstWhere(
      (u) => u.id == targetUserId,
      orElse: () => UserModel(id: targetUserId, name: 'New Contact', email: ''),
    );

    final newConv = ConversationModel(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      participant: targetUser,
      lastMessage: null,
      unreadCount: 0,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    conversations.insert(0, newConv);
    messagesByConversationId[newConv.id] = [];
    return newConv;
  }

  Future<ConversationModel> getConversationById(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return conversations.firstWhere((c) => c.id == conversationId);
  }

  Future<List<MessageModel>> getMessages(String conversationId, {int page = 1, int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final list = messagesByConversationId[conversationId] ?? [];
    return List.from(list);
  }

  Future<MessageModel> sendMessage(
    String conversationId, {
    required String text,
    List<AttachmentModel> attachments = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newMsg = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: currentUser.id,
      senderName: currentUser.name,
      senderAvatar: currentUser.avatarUrl,
      text: text,
      attachments: attachments,
      createdAt: DateTime.now(),
    );

    messagesByConversationId.putIfAbsent(conversationId, () => []);
    messagesByConversationId[conversationId]!.add(newMsg);

    // Update conversation lastMessage
    final convIndex = conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex != -1) {
      conversations[convIndex] = conversations[convIndex].copyWith(
        lastMessage: newMsg,
        updatedAt: newMsg.createdAt,
      );
    }

    return newMsg;
  }

  Future<MessageModel> editMessage(String messageId, String newText) async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (var list in messagesByConversationId.values) {
      final index = list.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final updated = list[index].copyWith(
          text: newText,
          isEdited: true,
          updatedAt: DateTime.now(),
        );
        list[index] = updated;
        return updated;
      }
    }
    throw Exception('Message not found');
  }

  Future<void> deleteMessage(String messageId, {bool deleteForEveryone = false}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (var list in messagesByConversationId.values) {
      final index = list.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        if (deleteForEveryone) {
          list[index] = list[index].copyWith(
            text: 'This message was deleted',
            isDeleted: true,
            isDeletedForEveryone: true,
            attachments: [],
          );
        } else {
          list.removeAt(index);
        }
        return;
      }
    }
  }

  Future<AttachmentModel> uploadAttachment({
    required String filePath,
    required String type,
    String? fileName,
    int? fileSize,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return AttachmentModel(
      id: 'att_${DateTime.now().millisecondsSinceEpoch}',
      url: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600',
      type: type,
      fileName: fileName ?? 'attachment_${DateTime.now().millisecondsSinceEpoch}',
      fileSize: fileSize ?? 1024 * 150,
      mimeType: type == 'image' ? 'image/jpeg' : 'application/octet-stream',
    );
  }

  // --- Users Endpoints ---
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(users);
  }

  Future<UserModel> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return users.firstWhere((u) => u.id == id, orElse: () => currentUser);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.toLowerCase();
    return users
        .where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q))
        .toList();
  }

  Future<UserModel> updateProfile({String? name, String? bio}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    currentUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      bio: bio ?? currentUser.bio,
    );
    return currentUser;
  }

  Future<String> uploadAvatar(String filePath) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final newUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';
    currentUser = currentUser.copyWith(avatarUrl: newUrl);
    return newUrl;
  }
}
