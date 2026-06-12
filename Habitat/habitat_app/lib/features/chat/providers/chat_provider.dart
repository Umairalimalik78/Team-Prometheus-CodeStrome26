import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../../../core/services/supabase_service.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<MessageModel>>((ref) => ChatNotifier());

class ChatNotifier extends StateNotifier<List<MessageModel>> {
  ChatNotifier() : super([]);

  String _makeId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> sendUserMessage(String content) async {
    final msg = MessageModel(id: _makeId(), role: 'user', content: content);
    state = [...state, msg];
    // If Supabase is configured, call the Edge Function groq-intake
    try {
      final payload = {
        'messages': state.map((m) => m.toJson()).toList(),
      };
      final result = await SupabaseService.callFunction('groq-intake', payload);
      // Expecting either { reply: { content: '...' } } or a simple JSON
      String replyText = '';
      if (result != null) {
        if (result is Map && result['reply'] != null) {
          final reply = result['reply'];
          if (reply is Map && reply['content'] != null) replyText = reply['content'].toString();
          else if (reply is String) replyText = reply;
        } else if (result is Map && result['content'] != null) {
          replyText = result['content'].toString();
        }
      }

      if (replyText.isEmpty) {
        // Fallback demo reply
        await Future.delayed(const Duration(milliseconds: 500));
        replyText = 'Thanks — I heard: "$content". (Demo reply)';
      }
      final assistant = MessageModel(id: _makeId(), role: 'assistant', content: replyText);
      state = [...state, assistant];

      // Persist messages to Supabase chat_messages table if possible
      await SupabaseService.insertRow('chat_messages', {'id': assistant.id, 'role': assistant.role, 'content': assistant.content, 'created_at': assistant.createdAt.toIso8601String()});
    } catch (e) {
      // On any error, fallback to local demo reply
      await Future.delayed(const Duration(milliseconds: 700));
      final assistant = MessageModel(id: _makeId(), role: 'assistant', content: 'Thanks — I heard: "$content". (Demo reply)');
      state = [...state, assistant];
    }
  }
}
