class Thread {
  final String threadId;
  final String initialMessage;
  final DateTime lastMessageAt;
  final int messageCount;
  final String? courseId;
  final String? courseTitle;

  Thread({
    required this.threadId,
    required this.initialMessage,
    required this.lastMessageAt,
    required this.messageCount,
    this.courseId,
    this.courseTitle,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      threadId: json['threadId'],
      initialMessage: json['initialMessage'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      messageCount: json['messageCount'],
      courseId: json['courseId'],
      courseTitle: json['courseTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'initialMessage': initialMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messageCount': messageCount,
      'courseId': courseId,
      'courseTitle': courseTitle,
    };
  }
}

class ThreadsResponse {
  final List<Thread> threads;
  final bool hasMore;
  final String? nextCursor;

  ThreadsResponse({
    required this.threads,
    required this.hasMore,
    this.nextCursor,
  });

  factory ThreadsResponse.fromJson(Map<String, dynamic> json) {
    return ThreadsResponse(
      threads: (json['threads'] as List)
          .map((threadJson) => Thread.fromJson(threadJson))
          .toList(),
      hasMore: json['hasMore'] ?? false,
      nextCursor: json['nextCursor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threads': threads.map((thread) => thread.toJson()).toList(),
      'hasMore': hasMore,
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }
}
