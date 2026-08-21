import '../../core/network/api_exceptions.dart';
import '../../core/network/api_result.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/attachment_model.dart';
import '../providers/chat_provider.dart';

class ChatRepository {
  final ChatProvider _chatProvider;

  ChatRepository({ChatProvider? chatProvider})
      : _chatProvider = chatProvider ?? ChatProvider();

  Future<ApiResult<List<ConversationModel>>> getConversations() async {
    try {
      final list = await _chatProvider.getConversations();
      return Success(list);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<ConversationModel>> createOrGetConversation(String targetUserId) async {
    try {
      final conv = await _chatProvider.createOrGetConversation(targetUserId);
      return Success(conv);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<ConversationModel>> getConversationDetails(String conversationId) async {
    try {
      final conv = await _chatProvider.getConversationDetails(conversationId);
      return Success(conv);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<List<MessageModel>>> getMessages(String conversationId, {int page = 1, int limit = 30, String? before}) async {
    try {
      final messages = await _chatProvider.getMessages(conversationId, page: page, limit: limit, before: before);
      return Success(messages);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<MessageModel>> sendMessage(
    String conversationId, {
    required String text,
    List<AttachmentModel> attachments = const [],
  }) async {
    try {
      final msg = await _chatProvider.sendMessage(
        conversationId,
        text: text,
        attachments: attachments,
      );
      return Success(msg);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<MessageModel>> editMessage(String messageId, String newText) async {
    try {
      final msg = await _chatProvider.editMessage(messageId, newText);
      return Success(msg);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<bool>> deleteMessage(String messageId, {bool deleteForEveryone = false}) async {
    try {
      await _chatProvider.deleteMessage(messageId, deleteForEveryone: deleteForEveryone);
      return const Success(true);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }

  Future<ApiResult<AttachmentModel>> uploadAttachment({
    required String filePath,
    required String type,
    String? fileName,
  }) async {
    try {
      final attachment = await _chatProvider.uploadAttachment(
        filePath: filePath,
        type: type,
        fileName: fileName,
      );
      return Success(attachment);
    } catch (e) {
      if (e is ApiException) return Failure(e.message, statusCode: e.statusCode);
      return Failure(e.toString());
    }
  }
}
