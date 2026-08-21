import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/mock_backend_service.dart';
import '../../core/storage/storage_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/attachment_model.dart';

class ChatProvider {
  final ApiClient _apiClient = ApiClient.to;
  final MockBackendService _mockBackend = MockBackendService();
  final StorageService _storage = StorageService.to;

  Future<List<ConversationModel>> getConversations() async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getConversations();
    }
    try {
      final response = await _apiClient.dio.get(ApiConstants.conversations);
      final List list = response.data is List ? response.data : (response.data['data'] ?? []);
      return list.map((item) => ConversationModel.fromJson(item)).toList();
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<ConversationModel> createOrGetConversation(String targetUserId) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getOrCreateConversation(targetUserId);
    }
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.conversations,
        data: {'recipientId': targetUserId},
      );
      final data = response.data is Map<String, dynamic> ? response.data : response.data['data'];
      return ConversationModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<ConversationModel> getConversationDetails(String id) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getConversationById(id);
    }
    try {
      final response = await _apiClient.dio.get(ApiConstants.conversationDetail(id));
      final data = response.data is Map<String, dynamic> ? response.data : response.data['data'];
      return ConversationModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<List<MessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 30,
    String? before,
  }) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.getMessages(conversationId, page: page, limit: limit);
    }
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (before != null) queryParams['before'] = before;

      final response = await _apiClient.dio.get(
        ApiConstants.conversationMessages(conversationId),
        queryParameters: queryParams,
      );
      final List list = response.data is List ? response.data : (response.data['data'] ?? []);
      return list.map((item) => MessageModel.fromJson(item)).toList();
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<MessageModel> sendMessage(
    String conversationId, {
    required String text,
    List<AttachmentModel> attachments = const [],
  }) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.sendMessage(conversationId, text: text, attachments: attachments);
    }
    try {
      String msgType = 'TEXT';
      String? attachmentUrl;

      if (attachments.isNotEmpty) {
        final att = attachments.first;
        attachmentUrl = att.url;
        if (att.type == 'image') {
          msgType = 'IMAGE';
        } else if (att.type == 'video') {
          msgType = 'VIDEO';
        } else if (att.type == 'audio') {
          msgType = 'AUDIO';
        } else {
          msgType = 'FILE';
        }
      }

      final payload = <String, dynamic>{
        'content': text,
        'type': msgType,
      };
      if (attachmentUrl != null) payload['attachmentUrl'] = attachmentUrl;

      final response = await _apiClient.dio.post(
        ApiConstants.conversationMessages(conversationId),
        data: payload,
      );
      final data = response.data is Map<String, dynamic> ? response.data : response.data['data'];
      return MessageModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<MessageModel> editMessage(String messageId, String newText) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.editMessage(messageId, newText);
    }
    try {
      final response = await _apiClient.dio.patch(
        ApiConstants.messageDetail(messageId),
        data: {'content': newText},
      );
      final data = response.data is Map<String, dynamic> ? response.data : response.data['data'];
      return MessageModel.fromJson(data);
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> deleteMessage(String messageId, {bool deleteForEveryone = false}) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.deleteMessage(messageId, deleteForEveryone: deleteForEveryone);
    }
    try {
      await _apiClient.dio.delete(
        ApiConstants.messageDetail(messageId),
        queryParameters: {'type': deleteForEveryone ? 'EVERYONE' : 'ME'},
      );
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<AttachmentModel> uploadAttachment({
    required String filePath,
    required String type,
    String? fileName,
  }) async {
    if (_storage.useMockBackend.value) {
      return _mockBackend.uploadAttachment(
        filePath: filePath,
        type: type,
        fileName: fileName,
      );
    }
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _apiClient.dio.post(
        ApiConstants.upload,
        data: formData,
      );
      return AttachmentModel(
        id: response.data['id']?.toString() ?? 'att_${DateTime.now().millisecondsSinceEpoch}',
        url: response.data['url'] ?? response.data['attachmentUrl'] ?? response.data['secure_url'] ?? '',
        type: type,
        fileName: fileName,
      );
    } catch (e) {
      throw _apiClient.handleError(e);
    }
  }
}
