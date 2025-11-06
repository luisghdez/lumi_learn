// lib/models/podcast_models.dart

class PodcastLine {
  final String id;
  final String speaker; // "Host A" or "Host B"
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

  factory PodcastLine.fromJson(String id, Map<String, dynamic> json) {
    return PodcastLine(
      id: id,
      speaker: json['speaker'] ?? 'Host A',
      text: json['text'] ?? '',
      audioUrl: json['audioUrl'],
      order: json['order'] ?? 0,
      isInterrupt: json['isInterrupt'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'text': text,
      'audioUrl': audioUrl,
      'order': order,
      if (isInterrupt != null) 'isInterrupt': isInterrupt,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

class PodcastSegment {
  final String id;
  final int order;
  final int? duration;
  final List<PodcastLine> dialogue;

  PodcastSegment({
    required this.id,
    required this.order,
    this.duration,
    required this.dialogue,
  });

  factory PodcastSegment.fromJson(String id, Map<String, dynamic> json, List<PodcastLine> dialogue) {
    return PodcastSegment(
      id: id,
      order: json['order'] ?? 0,
      duration: json['duration'],
      dialogue: dialogue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'duration': duration,
    };
  }
}

class PodcastMetadata {
  final String title;
  final String createdAt;
  final int totalSegments;
  final int durationSeconds;
  final String tone;
  final List<String> hosts;

  PodcastMetadata({
    required this.title,
    required this.createdAt,
    required this.totalSegments,
    required this.durationSeconds,
    required this.tone,
    required this.hosts,
  });

  factory PodcastMetadata.fromJson(Map<String, dynamic> json) {
    return PodcastMetadata(
      title: json['title'] ?? '',
      createdAt: json['createdAt'] ?? '',
      totalSegments: json['totalSegments'] ?? 0,
      durationSeconds: json['durationSeconds'] ?? 0,
      tone: json['tone'] ?? '',
      hosts: List<String>.from(json['hosts'] ?? []),
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
    };
  }
}