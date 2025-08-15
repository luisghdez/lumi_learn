enum MessageRole { user, assistant }

class Message {
  final String messageId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      role: MessageRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ThreadMessagesResponse {
  final String threadId;
  final List<Message> messages;
  final bool hasMore;

  ThreadMessagesResponse({
    required this.threadId,
    required this.messages,
    required this.hasMore,
  });

  factory ThreadMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ThreadMessagesResponse(
      threadId: json['threadId'],
      messages: (json['messages'] as List)
          .map((messageJson) => Message.fromJson(messageJson))
          .toList(),
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'messages': messages.map((message) => message.toJson()).toList(),
      'hasMore': hasMore,
    };
  }
}
