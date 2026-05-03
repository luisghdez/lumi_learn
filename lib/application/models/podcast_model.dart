// lib/application/models/podcast_model.dart

class PodcastMetadata {
  final String title;
  final String createdAt;
  final int totalSegments;
  final int durationSeconds;
  final String tone;
  final List<String> hosts;
  final List<String>? topics; // 🆕 NEW: List of all topics covered
  final String? description;  // 🆕 NEW: Description of the podcast

  PodcastMetadata({
    required this.title,
    required this.createdAt,
    required this.totalSegments,
    required this.durationSeconds,
    required this.tone,
    required this.hosts,
    this.topics,
    this.description,
  });

  factory PodcastMetadata.fromJson(Map<String, dynamic> json) {
    return PodcastMetadata(
      title: json['title'] ?? '',
      createdAt: json['createdAt'] ?? '',
      totalSegments: json['totalSegments'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      tone: json['tone'] ?? 'Conversational',
      hosts: (json['hosts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      topics: (json['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'createdAt': createdAt,
      'totalSegments': totalSegments,
      'durationSeconds': durationSeconds,
      'tone': tone,
      'hosts': hosts,
      if (topics != null) 'topics': topics,
      if (description != null) 'description': description,
    };
  }
}

class PodcastSegment {
  final String id;
  final int order;
  final int? duration;
  
  // 🆕 ENHANCED FIELDS
  final String? topic;              // Clear topic/lesson name
  final List<String>? examples;     // Real-world examples used
  final bool? isStandalone;         // Flag for standalone lessons
  
  List<PodcastLine> dialogue;

  PodcastSegment({
    required this.id,
    required this.order,
    this.duration,
    this.topic,
    this.examples,
    this.isStandalone,
    required this.dialogue,
  });

  factory PodcastSegment.fromJson(Map<String, dynamic> json) {
    return PodcastSegment(
      id: json['id'] ?? '',
      order: json['order'] ?? 0,
      duration: json['duration'] as int?,
      
      // 🆕 Parse new fields
      topic: json['topic'] as String?,
      examples: (json['examples'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      isStandalone: json['isStandalone'] as bool?,
      
      dialogue: (json['dialogue'] as List<dynamic>?)
              ?.map((e) => PodcastLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      if (duration != null) 'duration': duration,
      if (topic != null) 'topic': topic,
      if (examples != null) 'examples': examples,
      if (isStandalone != null) 'isStandalone': isStandalone,
      'dialogue': dialogue.map((e) => e.toJson()).toList(),
    };
  }

  // 🆕 Helper: Get display title (topic or fallback)
  String get displayTitle => topic ?? 'Segment $order';

  // 🆕 Helper: Check if segment has examples
  bool get hasExamples => examples != null && examples!.isNotEmpty;

  // 🆕 Helper: Get examples count
  int get examplesCount => examples?.length ?? 0;
}

class PodcastLine {
  final String id;
  final String speaker;
  final String text;
  final String? audioUrl;
  final int order;
  final bool? isInterrupt;
  final String? createdAt;

  PodcastLine({
    required this.id,
    required this.speaker,
    required this.text,
    this.audioUrl,
    required this.order,
    this.isInterrupt,
    this.createdAt,
  });

  factory PodcastLine.fromJson(Map<String, dynamic> json) {
    return PodcastLine(
      id: json['id'] ?? '',
      speaker: json['speaker'] ?? 'Host A',
      text: json['text'] ?? '',
      audioUrl: json['audioUrl'] as String?,
      order: json['order'] ?? 0,
      isInterrupt: json['isInterrupt'] as bool?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speaker': speaker,
      'text': text,
      if (audioUrl != null) 'audioUrl': audioUrl,
      'order': order,
      if (isInterrupt != null) 'isInterrupt': isInterrupt,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  // Helper: Check if this is a call-in response
  bool get isCallIn => isInterrupt == true;
}