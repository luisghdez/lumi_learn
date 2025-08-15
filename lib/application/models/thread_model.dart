class Thread {
  final String threadId;
  final String initialMessage;
  final DateTime lastMessageAt;
  final int messageCount;

  Thread({
    required this.threadId,
    required this.initialMessage,
    required this.lastMessageAt,
    required this.messageCount,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      threadId: json['threadId'],
      initialMessage: json['initialMessage'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      messageCount: json['messageCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'initialMessage': initialMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messageCount': messageCount,
    };
  }
}

class ThreadsResponse {
  final List<Thread> threads;
  final bool hasMore;

  ThreadsResponse({
    required this.threads,
    required this.hasMore,
  });

  factory ThreadsResponse.fromJson(Map<String, dynamic> json) {
    return ThreadsResponse(
      threads: (json['threads'] as List)
          .map((threadJson) => Thread.fromJson(threadJson))
          .toList(),
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threads': threads.map((thread) => thread.toJson()).toList(),
      'hasMore': hasMore,
    };
  }
}
