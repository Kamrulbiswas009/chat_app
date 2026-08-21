import 'attachment_model.dart';

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String text;
  final List<AttachmentModel> attachments;
  final bool isEdited;
  final bool isDeleted;
  final bool isDeletedForEveryone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.text,
    this.attachments = const [],
    this.isEdited = false,
    this.isDeleted = false,
    this.isDeletedForEveryone = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    var attachmentsList = <AttachmentModel>[];
    if (json['attachments'] != null && json['attachments'] is List) {
      attachmentsList = (json['attachments'] as List)
          .map((item) => AttachmentModel.fromJson(item))
          .toList();
    } else if (json['attachmentUrl'] != null && json['attachmentUrl'].toString().isNotEmpty) {
      final type = (json['type']?.toString().toLowerCase() ?? 'image');
      attachmentsList.add(
        AttachmentModel(
          id: 'att_${json['id']}',
          url: json['attachmentUrl'].toString(),
          type: type,
        ),
      );
    }

    String? sName = json['sender_name'] ?? json['senderName'];
    String? sAvatar = json['sender_avatar'] ?? json['senderAvatar'] ?? json['avatar'];
    String sId = json['sender_id']?.toString() ?? json['senderId']?.toString() ?? '';

    if (json['sender'] != null && json['sender'] is Map<String, dynamic>) {
      final s = json['sender'] as Map<String, dynamic>;
      sId = s['id']?.toString() ?? sId;
      sName = s['name']?.toString() ?? sName;
      sAvatar = s['avatar']?.toString() ?? s['avatarUrl']?.toString() ?? sAvatar;
    }

    final isDelForEveryone = json['is_deleted_for_everyone'] == true || 
                             json['isDeletedForEveryone'] == true;

    return MessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? json['conversationId']?.toString() ?? '',
      senderId: sId,
      senderName: sName,
      senderAvatar: sAvatar,
      text: isDelForEveryone ? 'This message was deleted' : (json['text']?.toString() ?? json['content']?.toString() ?? ''),
      attachments: isDelForEveryone ? [] : attachmentsList,
      isEdited: json['is_edited'] == true || json['isEdited'] == true,
      isDeleted: json['is_deleted'] == true || json['isDeleted'] == true || isDelForEveryone,
      isDeletedForEveryone: isDelForEveryone,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null 
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : (json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'text': text,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'is_deleted_for_everyone': isDeletedForEveryone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? text,
    List<AttachmentModel>? attachments,
    bool? isEdited,
    bool? isDeleted,
    bool? isDeletedForEveryone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
