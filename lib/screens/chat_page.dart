import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/chat_memory_store.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.profileId,
    this.profileName,
  });

  final String profileId;
  final String? profileName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final TextEditingController _textController = TextEditingController();
  late final ScrollController _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleDraftChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ChatMemoryStore>().ensureConversation(widget.profileId,
          profileName: widget.profileName);
    });
  }

  @override
  void dispose() {
    _textController
      ..removeListener(_handleDraftChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleDraftChanged() {
    final bool next = _textController.text.trim().isNotEmpty;
    if (next != _canSend) {
      setState(() => _canSend = next);
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    context.read<ChatMemoryStore>().sendUserMessage(widget.profileId, text);
    _textController.clear();
    _handleDraftChanged();
    if (!kIsWeb) {
      await HapticFeedback.selectionClick();
    }
    await Future<void>.delayed(const Duration(milliseconds: 16));
    if (!mounted) {
      return;
    }
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText =
        widget.profileName == null ? 'Chat' : 'Chat with ${widget.profileName}';
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Column(
        children: [
          Expanded(
            child: Selector<ChatMemoryStore, List<ChatMessage>>(
              selector: (context, store) => List<ChatMessage>.unmodifiable(
                  store.messagesFor(widget.profileId)),
              shouldRebuild: (previous, next) => !listEquals(previous, next),
              builder: (context, messages, _) {
                if (messages.isEmpty) {
                  return const _EmptyChatPlaceholder();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final bool isLast = index == messages.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 4 : 12),
                      child: Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: _ChatBubble(message: message),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          _ComposeBar(
            controller: _textController,
            canSend: _canSend,
            onSend: _sendMessage,
            background: theme.colorScheme.surface,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUser = message.isUser;
    final ColorScheme colors = theme.colorScheme;
    final Color background =
        isUser ? colors.primaryContainer : colors.surfaceContainerHighest;
    final Color foreground =
        isUser ? colors.onPrimaryContainer : colors.onSurface;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16).copyWith(
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            ),
          ),
          child: Text(
            message.text,
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
          ),
        ),
      ],
    );
  }
}

class _ComposeBar extends StatelessWidget {
  const _ComposeBar({
    required this.controller,
    required this.canSend,
    required this.onSend,
    required this.background,
  });

  final TextEditingController controller;
  final bool canSend;
  final Future<void> Function() onSend;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        color: background,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('chat-input-field'),
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Send a message...',
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Send',
              onPressed: canSend ? onSend : null,
              icon: Icon(Icons.send_rounded, color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Messages you send here stay on this device for now.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
