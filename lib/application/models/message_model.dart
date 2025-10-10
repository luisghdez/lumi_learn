enum MessageRole { user, assistant }

class MessageImage {
  final String fileId;
  final String fileUrl;
  final String originalName;
  final String mimeType;

  MessageImage({
    required this.fileId,
    required this.fileUrl,
    required this.originalName,
    required this.mimeType,
  });

  factory MessageImage.fromJson(Map<String, dynamic> json) {
    return MessageImage(
      fileId: json['fileId'] ?? json['fileName'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      originalName: json['originalName'] ?? '',
      mimeType: json['mimeType'] ?? 'image/png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileUrl': fileUrl,
      'originalName': originalName,
      'mimeType': mimeType,
    };
  }
}

class Message {
  final String messageId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final List<Map<String, dynamic>>? sources;
  final bool isStreaming; // Add this
  final MessageImage? image; // Add image support

  Message({
    required this.messageId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sources,
    this.isStreaming = false,
    this.image,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Check if imageUrl exists in the message document
    MessageImage? messageImage;
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      messageImage = MessageImage(
        fileId: json['fileId'] ?? json['fileName'] ?? 'unknown',
        fileUrl: json['imageUrl'],
        originalName: json['originalName'] ?? json['fileName'] ?? 'image.png',
        mimeType: json['mimeType'] ?? 'image/png',
      );
    } else if (json['image'] != null) {
      // Fallback to nested image object structure
      messageImage = MessageImage.fromJson(json['image']);
    }

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
      image: messageImage,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'messageId': messageId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (sources != null) 'sources': sources,
    };

    // Add image data in the format expected by backend
    if (image != null) {
      json['imageUrl'] = image!.fileUrl;
      json['fileId'] = image!.fileId;
      json['originalName'] = image!.originalName;
      json['mimeType'] = image!.mimeType;
      // Also include nested image object for compatibility
      json['image'] = image!.toJson();
    }

    return json;
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
