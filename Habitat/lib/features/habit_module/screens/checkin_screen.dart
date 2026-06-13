import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:habitat/core/constants/app_colors.dart';
import 'package:habitat/core/constants/app_text_styles.dart';
import 'package:habitat/core/services/supabase_service.dart';
import 'package:habitat/features/auth/providers/auth_provider.dart';
import 'package:habitat/features/dashboard/providers/dashboard_provider.dart';
import 'package:habitat/features/habit_module/models/habit_module_model.dart';
import 'package:habitat/features/chat/models/message_model.dart';
import 'package:habitat/features/chat/widgets/chat_bubble.dart';
import 'package:habitat/features/chat/widgets/typing_indicator.dart';
import 'package:habitat/shared/widgets/app_scaffold.dart';
import 'package:habitat/shared/widgets/primary_button.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  final String moduleId;

  const CheckinScreen({
    super.key,
    required this.moduleId,
  });

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _messages = []; // Hold MessageModel objects

  bool _isTyping = false;
  bool _showResult = false;
  String _decision = ""; // 'close' | 'extend' | 'restart'
  String _resultMessage = "";

  @override
  void initState() {
    super.initState();
    _startCheckin();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _startCheckin() async {
    final habits = ref.read(dashboardProvider).habits.value ?? [];
    final habit = habits.firstWhere((h) => h.id == widget.moduleId);
    final authState = ref.read(authProvider);

    setState(() => _isTyping = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      setState(() {
        _messages.add(
          MessageModel(
            id: 'checkin_init',
            userId: authState.user!.id,
            role: 'assistant',
            content: "Welcome to your Day 21 check-in for '${habit.habitName}'! 🌟\n\nI want to assess if you have fully internalized this routine. How has it been going? Are you following it most days without relying on reminders?",
            createdAt: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    final authState = ref.read(authProvider);
    final habits = ref.read(dashboardProvider).habits.value ?? [];
    final habit = habits.firstWhere((h) => h.id == widget.moduleId);

    setState(() {
      _messages.add(
        MessageModel(
          id: 'checkin_user_${DateTime.now().millisecondsSinceEpoch}',
          userId: authState.user!.id,
          role: 'user',
          content: text,
          createdAt: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // Evaluate response
      final result = await SupabaseService.instance.sendCheckInMessage(habit.habitName, text);
      
      final decision = result['decision'] as String;
      final aiMessage = result['message'] as String;

      await SupabaseService.instance.saveCheckIn(
        widget.moduleId,
        authState.user!.id,
        21,
        text,
        decision,
        aiMessage,
      );

      // Refresh habits list to update status/phase
      await ref.read(dashboardProvider.notifier).refresh();

      if (mounted) {
        setState(() {
          _messages.add(
            MessageModel(
              id: 'checkin_ai_${DateTime.now().millisecondsSinceEpoch}',
              userId: authState.user!.id,
              role: 'assistant',
              content: aiMessage,
              createdAt: DateTime.now(),
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();

        // Stagger showing the final result screen overlay
        await Future.delayed(const Duration(milliseconds: 2000));
        if (mounted) {
          setState(() {
            _decision = decision;
            _resultMessage = aiMessage;
            _showResult = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTyping = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error evaluating checkin: $e")),
        );
      }
    }
  }

  Widget _buildResultOverlay(HabitModuleModel habit) {
    if (_decision == 'close') {
      // Habit Built Celebratory View
      return Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🏆',
              style: TextStyle(fontSize: 80),
            ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Habit Built!',
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.success, fontSize: 32),
            ).animate().slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              _resultMessage.isNotEmpty
                  ? _resultMessage
                  : "Congratulations! '${habit.habitName}' is now a part of who you are. Daily reminders have been disabled as you've reached autonomous mode.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Share Progress',
              icon: Icons.share_rounded,
              backgroundColor: AppColors.primaryWarm,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Success banner copied to clipboard!")),
                );
              },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Back to Home',
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      );
    } else if (_decision == 'restart') {
      // Habit Recalibrate / Restart View
      return Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🌱',
              style: TextStyle(fontSize: 80),
            ).animate().shake(duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              "Let's Adjust.",
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.primaryWarm, fontSize: 30),
            ),
            const SizedBox(height: 16),
            Text(
              _resultMessage.isNotEmpty
                  ? _resultMessage
                  : "We encountered some obstacles, and that's okay. Atomic habits are about tiny, easy gains. We've restarted the 25-day program with a modified difficulty to help you build consistency.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Start Fresh (Day 1)',
              backgroundColor: AppColors.primary,
              onPressed: () => context.go('/habit/${widget.moduleId}'),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Back to Home',
              backgroundColor: Colors.white,
              textColor: AppColors.textPrimary,
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      );
    } else {
      // Extend Habit by 7 Days View
      return Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔄',
              style: TextStyle(fontSize: 80),
            ).animate().rotate(duration: 800.ms),
            const SizedBox(height: 24),
            Text(
              "Keep Practicing!",
              style: AppTextStyles.screenTitle.copyWith(color: AppColors.textPrimary, fontSize: 30),
            ),
            const SizedBox(height: 16),
            Text(
              _resultMessage.isNotEmpty
                  ? _resultMessage
                  : "You are close to locking this routine down! To solidify your cue-routine-reward loop, we've extended this module by 7 days. Keep going!",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Continue Training',
              backgroundColor: AppColors.primary,
              onPressed: () => context.go('/habit/${widget.moduleId}'),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Back to Home',
              backgroundColor: Colors.white,
              textColor: AppColors.textPrimary,
              onPressed: () => context.go('/dashboard'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(dashboardProvider).habits.value ?? [];
    if (habits.isEmpty) {
      return AppScaffold(
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primary))),
      );
    }

    final habit = habits.firstWhere((h) => h.id == widget.moduleId);

    if (_showResult) {
      return Scaffold(
        body: _buildResultOverlay(habit),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Day 21 Check-in',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Title layout
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        '21-Day Evaluation 🌱',
                        style: AppTextStyles.screenTitle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tell your coach how your habit has been going. Try answering 'Yes, it is easy now' or 'No, I kept forgetting' to test AI decisions.",
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Dialog bubble history
                ..._messages.map((m) => ChatBubble(message: m)),
                
                if (_isTyping)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: TypingIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          
          // Chat Input Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.inputBg,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _inputController,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your update...',
                        hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _handleSend,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
