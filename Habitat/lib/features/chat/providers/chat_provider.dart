import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/features/chat/models/message_model.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading; // Bouncing typing indicator
  final bool isGeneratingPlan; // Generate plan screen loader
  final String? generatedModuleId; // Trigger navigation

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isGeneratingPlan = false,
    this.generatedModuleId,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isGeneratingPlan,
    String? generatedModuleId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isGeneratingPlan: isGeneratingPlan ?? this.isGeneratingPlan,
      generatedModuleId: generatedModuleId ?? this.generatedModuleId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref) : super(ChatState()) {
    _init();
  }

  void _init() async {
    final authState = _ref.read(authProvider);
    if (authState.user == null) return;
    
    // Add the first message from the AI Coach
    state = state.copyWith(isLoading: true);
    
    try {
      final initialMessage = await SupabaseService.instance.sendIntakeMessage([]);
      final aiMessage = MessageModel(
        id: 'msg_init',
        userId: authState.user!.id,
        role: 'assistant',
        content: initialMessage,
        createdAt: DateTime.now(),
      );
      state = ChatState(
        messages: [aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendMessage(String content) async {
    final authState = _ref.read(authProvider);
    if (authState.user == null || content.trim().isEmpty) return;

    final userMessage = MessageModel(
      id: 'msg_user_${DateTime.now().millisecondsSinceEpoch}',
      userId: authState.user!.id,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );

    // Update list with user message and show typing animation
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      // Get AI coach response
      final aiResponse = await SupabaseService.instance.sendIntakeMessage(state.messages);
      
      state = state.copyWith(isLoading: false);

      if (aiResponse == "INTERVIEW_COMPLETE") {
        // Trigger plan generator screen loader
        state = state.copyWith(isGeneratingPlan: true);
        
        // Call generator
        final HabitModuleModel generatedModule = await SupabaseService.instance.generateHabitModule(
          state.messages,
          authState.user!.id,
        );

        // Notify UI of the generated ID for navigation
        state = state.copyWith(
          isGeneratingPlan: false,
          generatedModuleId: generatedModule.id,
        );
      } else {
        final aiMessage = MessageModel(
          id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
          userId: authState.user!.id,
          role: 'assistant',
          content: aiResponse,
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          messages: [...state.messages, aiMessage],
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Add error message as system bubble
      final errMsg = MessageModel(
        id: 'msg_err',
        userId: authState.user!.id,
        role: 'assistant',
        content: "I encountered a connection error. Please try sending your response again.",
        createdAt: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, errMsg]);
    }
  }
}

// family-like dynamic instantiation is not strictly needed since we do it once per new habit chat
final chatNotifierProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
