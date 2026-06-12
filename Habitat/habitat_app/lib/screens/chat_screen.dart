import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../features/chat/providers/chat_provider.dart';
import '../core/services/module_generator_service.dart';
import '../features/habit_module/providers/habit_provider.dart';
import '../features/chat/models/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Habit Coach'),
        actions: [
          if (messages.isNotEmpty)
            TextButton(
              onPressed: () async {
                // Disable button by showing a loading indicator
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating habit module...')));
                final msgs = messages.map((m) => m.toJson()).toList();
                final module = await ModuleGeneratorService.generateFromMessages(msgs);
                if (module != null) {
                  ref.read(habitProvider.notifier).addModule(module);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit module generated')));
                  GoRouter.of(context).go('/habit/${module.id}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate habit module.')));
                }
              },
              child: const Text('Finish'),
            )
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final MessageModel m = messages[index];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: isUser ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(m.content, style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary)),
                  ),
                );
              },
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.inputBg, borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Type your message...'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  await ref.read(chatProvider.notifier).sendUserMessage(text);
                  _controller.clear();
                },
                mini: true,
                child: const Icon(Icons.send),
                backgroundColor: AppColors.primary,
              )
            ]),
          )
        ],
      ),
    );
  }
}
