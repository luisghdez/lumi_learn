enum MessageRole { user, assistant }

class Message {
  final String messageId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? sources;

  Message({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources,
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
      sources: json['sources'] != null
          ? List<Map<String, dynamic>>.from(json['sources'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (sources != null) 'sources': sources,
    };
  }
}

class ThreadMessagesResponse {
  final String threadId;
  final List<Message> messages;
  final bool hasMore;
  final String? nextCursor;
  final int? totalCount;

  ThreadMessagesResponse({
    required this.threadId,
    required this.messages,
    required this.hasMore,
    this.nextCursor,
    this.totalCount,
  });

  factory ThreadMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ThreadMessagesResponse(
      threadId: json['threadId'],
      messages: (json['messages'] as List)
          .map((messageJson) => Message.fromJson(messageJson))
          .toList(),
      hasMore: json['hasMore'] ?? false,
      nextCursor: json['nextCursor'],
      totalCount: json['totalCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'messages': messages.map((message) => message.toJson()).toList(),
      'hasMore': hasMore,
      if (nextCursor != null) 'nextCursor': nextCursor,
      if (totalCount != null) 'totalCount': totalCount,
    };
  }
}
