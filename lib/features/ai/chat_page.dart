import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state.dart';
import '../../core/theme.dart';
import '../../core/widgets/glass.dart';
import '../../models/models.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final v = text ?? _input.text;
    if (v.trim().isEmpty) return;
    _input.clear();
    ref.read(chatProvider.notifier).send(v);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(trProvider);
    final chat = ref.watch(chatProvider);
    final bottomBarSpace =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 12.0 : 100.0;

    ref.listen<ChatState>(chatProvider, (prev, next) => _scrollToEnd());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 12, 8),
          child: PageHeader(
            title: t('ai'),
            actions: [
              if (chat.messages.isNotEmpty)
                IconButton(
                  tooltip: t('clear_chat'),
                  onPressed: () => ref.read(chatProvider.notifier).clear(),
                  icon: const Icon(Icons.delete_sweep_rounded),
                ),
            ],
          ),
        ),
        Expanded(
          child: chat.messages.isEmpty && !chat.loading
              ? _Welcome(onPick: _send)
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  itemCount: chat.messages.length + (chat.loading ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == chat.messages.length) return const _ThinkingBubble();
                    return _Bubble(msg: chat.messages[i]);
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, bottomBarSpace),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GlassTextField(
                  controller: _input,
                  hint: t('type_message'),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                ),
              ),
              const SizedBox(width: 10),
              PressableScale(
                onTap: chat.loading ? null : _send,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [kViolet, kCyan]),
                    boxShadow: [
                      BoxShadow(
                        color: withA(kViolet, 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Welcome extends ConsumerWidget {
  final ValueChanged<String> onPick;
  const _Welcome({required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(trProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        GlassCard(
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t('chat_welcome'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        for (final k in const ['suggest_1', 'suggest_2', 'suggest_3'])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () => onPick(t(k)),
              child: Row(
                children: [
                  Expanded(child: Text(t(k))),
                  const Icon(Icons.arrow_outward_rounded, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMsg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    final maxW = MediaQuery.of(context).size.width * 0.8;

    final Widget bubble = isUser
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [kViolet, kCyan]),
            ),
            child: SelectableText(
              msg.content,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          )
        : GlassCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: SelectableText(msg.content, style: const TextStyle(height: 1.5)),
          );

    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxW), child: bubble),
      ),
    );
  }
}

class _ThinkingBubble extends ConsumerStatefulWidget {
  const _ThinkingBubble();

  @override
  ConsumerState<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends ConsumerState<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(trProvider);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t('thinking'), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) => Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: withA(
                            kViolet,
                            0.25 + 0.75 * ((_c.value * 3 - i).clamp(0.0, 1.0)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
