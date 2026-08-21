import 'package:chat_app/core/network/mock_backend_service.dart';
import 'package:chat_app/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DateFormatter Tests', () {
    test('formatChatListDate returns expected string format', () {
      final date = DateTime(2025, 6, 17, 15, 50);
      final formatted = DateFormatter.formatChatListDate(date);
      expect(formatted, contains('17'));
      expect(formatted, contains('june'));
      expect(formatted, contains('2025'));
      expect(formatted, contains('3:50 pm'));
    });

    test('formatMessageTimestamp returns expected string format', () {
      final date = DateTime(2025, 6, 14, 16, 10);
      final formatted = DateFormatter.formatMessageTimestamp(date);
      expect(formatted, contains('14/06/2025'));
      expect(formatted, contains('|'));
      expect(formatted, contains('16:10'));
    });
  });

  group('MockBackendService & Repositories Tests', () {
    late MockBackendService mockBackend;

    setUp(() {
      mockBackend = MockBackendService();
    });

    test('getConversations loads initial seed conversations matching UI', () async {
      final convs = await mockBackend.getConversations();
      expect(convs.isNotEmpty, true);
      expect(convs.first.participant.name, 'Marvin McKinney');
    });

    test('sendMessage adds message and updates conversation', () async {
      final convs = await mockBackend.getConversations();
      final convId = convs.first.id;

      final msg = await mockBackend.sendMessage(
        convId,
        text: 'Unit test message',
      );

      expect(msg.text, 'Unit test message');
      expect(msg.conversationId, convId);

      final messages = await mockBackend.getMessages(convId);
      expect(messages.any((m) => m.id == msg.id), true);
    });

    test('editMessage updates text and marks edited', () async {
      final convs = await mockBackend.getConversations();
      final convId = convs.first.id;
      final msg = await mockBackend.sendMessage(convId, text: 'Original text');

      final updated = await mockBackend.editMessage(msg.id, 'Edited text');
      expect(updated.text, 'Edited text');
      expect(updated.isEdited, true);
    });

    test('deleteMessage for everyone marks message as deleted', () async {
      final convs = await mockBackend.getConversations();
      final convId = convs.first.id;
      final msg = await mockBackend.sendMessage(convId, text: 'Delete me');

      await mockBackend.deleteMessage(msg.id, deleteForEveryone: true);
      final messages = await mockBackend.getMessages(convId);
      final deleted = messages.firstWhere((m) => m.id == msg.id);
      expect(deleted.isDeleted, true);
      expect(deleted.isDeletedForEveryone, true);
    });

    test('searchUsers returns matched users', () async {
      final results = await mockBackend.searchUsers('Darlene');
      expect(results.length, 1);
      expect(results.first.name, 'Darlene Robertson');
    });
  });
}
