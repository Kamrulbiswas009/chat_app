import 'user_model.dart';
import 'message_model.dart';
import '../../core/storage/storage_service.dart';

class ConversationModel {
  final String id;
  final UserModel participant;
  final MessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final DateTime? createdAt;

  ConversationModel({
    required this.id,
    required this.participant,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final currentUserId = StorageService.to.currentUser.value?.id;

    UserModel user;
    if (json['recipient'] != null && json['recipient'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['recipient']);
    } else if (json['participant'] != null && json['participant'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['participant']);
    } else if (json['otherUser'] != null && json['otherUser'] is Map<String, dynamic>) {
      user = UserModel.fromJson(json['otherUser']);
    } else if (json['users'] != null && json['users'] is List && (json['users'] as List).isNotEmpty) {
      final userList = (json['users'] as List).map((u) => UserModel.fromJson(u)).toList();
      user = userList.firstWhere(
        (u) => u.id != currentUserId,
        orElse: () => userList.first,
      );
    } else if (json['participants'] != null && json['participants'] is List && (json['participants'] as List).isNotEmpty) {
      final userList = (json['participants'] as List).map((u) => UserModel.fromJson(u is Map && u['user'] != null ? u['user'] : u)).toList();
      user = userList.firstWhere(
        (u) => u.id != currentUserId,
        orElse: () => userList.first,
      );
    } else {
      user = UserModel(
        id: json['recipientId']?.toString() ?? json['participant_id']?.toString() ?? json['other_user_id']?.toString() ?? '',
        name: json['recipientName'] ?? json['participant_name'] ?? json['other_user_name'] ?? 'User',
        email: json['participant_email'] ?? '',
        avatarUrl: json['participant_avatar'] ?? json['avatar_url'] ?? json['avatar'],
        bio: json['participant_bio'] ?? json['bio'],
      );
    }

    MessageModel? lastMsg;
    if (json['lastMessage'] != null && json['lastMessage'] is Map<String, dynamic>) {
      lastMsg = MessageModel.fromJson(json['lastMessage']);
    } else if (json['last_message'] != null && json['last_message'] is Map<String, dynamic>) {
      lastMsg = MessageModel.fromJson(json['last_message']);
    } else if (json['messages'] != null && json['messages'] is List && (json['messages'] as List).isNotEmpty) {
      final msgList = (json['messages'] as List);
      lastMsg = MessageModel.fromJson(msgList.last);
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      participant: user,
      lastMessage: lastMsg,
      unreadCount: json['unread_count'] is int ? json['unread_count'] : (json['unreadCount'] is int ? json['unreadCount'] : 0),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : (json['updated_at'] != null 
              ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
              : (lastMsg?.createdAt ?? DateTime.now())),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant': participant.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  ConversationModel copyWith({
    String? id,
    UserModel? participant,
    MessageModel? lastMessage,
    int? unreadCount,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
