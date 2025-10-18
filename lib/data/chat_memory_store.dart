import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.text == text &&
        other.isUser == isUser &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, text, isUser, timestamp);
}

class ChatMemoryStore extends ChangeNotifier {
  final Map<String, List<ChatMessage>> _conversations =
      <String, List<ChatMessage>>{};

  UnmodifiableListView<ChatMessage> messagesFor(String profileId) {
    final messages = _conversations[profileId];
    if (messages == null) {
      return UnmodifiableListView(const <ChatMessage>[]);
    }
    return UnmodifiableListView(messages);
  }

  void ensureConversation(String profileId, {String? profileName}) {
    if (_conversations.containsKey(profileId)) {
      return;
    }
    final nameFragment = profileName ?? 'this match';
    _conversations[profileId] = <ChatMessage>[
      ChatMessage(
        id: 'seed-${DateTime.now().microsecondsSinceEpoch}',
        text: 'Say hi to $nameFragment to get the conversation going.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
    notifyListeners();
  }

  void sendUserMessage(String profileId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final List<ChatMessage> conversation =
        _conversations.putIfAbsent(profileId, () => <ChatMessage>[]);
    conversation.add(ChatMessage(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
