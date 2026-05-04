/// One image in a native slideshow post (`contentKind: slideshow`).
class VideoSlide {
  const VideoSlide({
    required this.url,
    required this.order,
    this.durationMs,
  });

  final String url;
  final int order;
  final int? durationMs;

  factory VideoSlide.fromJson(Map<String, dynamic> json) {
    return VideoSlide(
      url: _stringValue(json['url']),
      order: _intValue(json['order']),
      durationMs: _nullableInt(json['durationMs']),
    );
  }
}

class VideoPost {
  const VideoPost({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerProfilePicture,
    required this.caption,
    required this.subject,
    required this.storagePath,
    required this.playbackUrl,
    required this.thumbnailUrl,
    required this.mimeType,
    required this.sizeBytes,
    required this.durationMs,
    required this.status,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.createdAt,
    required this.updatedAt,
    this.contentKind = 'video',
    this.slides = const [],
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerProfilePicture;
  final String caption;
  final String subject;
  final String storagePath;
  final String? playbackUrl;
  final String? thumbnailUrl;
  final String mimeType;
  final int? sizeBytes;
  final int? durationMs;
  final String status;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final String? createdAt;
  final String? updatedAt;

  /// `video` (default) or `slideshow` (Option B — native multi-image feed).
  final String contentKind;
  final List<VideoSlide> slides;

  bool get isSlideshow =>
      contentKind == 'slideshow' && slides.isNotEmpty;

  factory VideoPost.fromJson(Map<String, dynamic> json) {
    final slideList = <VideoSlide>[];
    final rawSlides = json['slides'];
    if (rawSlides is List) {
      for (final e in rawSlides) {
        if (e is Map) {
          slideList.add(VideoSlide.fromJson(Map<String, dynamic>.from(e)));
        }
      }
      slideList.sort((a, b) => a.order.compareTo(b.order));
    }
    return VideoPost(
      id: _stringValue(json['id']),
      ownerId: _stringValue(json['ownerId']),
      ownerName: _stringValue(json['ownerName'], fallback: 'Unknown User'),
      ownerProfilePicture: _stringValue(
        json['ownerProfilePicture'],
        fallback: 'default',
      ),
      caption: _stringValue(json['caption']),
      subject: _stringValue(json['subject']),
      storagePath: _stringValue(json['storagePath']),
      playbackUrl: _nullableString(json['playbackUrl']),
      thumbnailUrl: _nullableString(json['thumbnailUrl']),
      mimeType: _stringValue(json['mimeType'], fallback: 'video/mp4'),
      sizeBytes: _nullableInt(json['sizeBytes']),
      durationMs: _nullableInt(json['durationMs']),
      status: _stringValue(json['status'], fallback: 'uploading'),
      visibility: _stringValue(json['visibility'], fallback: 'public'),
      likeCount: _intValue(json['likeCount']),
      commentCount: _intValue(json['commentCount']),
      likedByMe: json['likedByMe'] == true,
      createdAt: _nullableString(json['createdAt']),
      updatedAt: _nullableString(json['updatedAt']),
      contentKind: _stringValue(json['contentKind'], fallback: 'video'),
      slides: slideList,
    );
  }

  VideoPost copyWith({
    String? playbackUrl,
    String? subject,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
    String? contentKind,
    List<VideoSlide>? slides,
  }) {
    return VideoPost(
      id: id,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerProfilePicture: ownerProfilePicture,
      caption: caption,
      subject: subject ?? this.subject,
      storagePath: storagePath,
      playbackUrl: playbackUrl ?? this.playbackUrl,
      thumbnailUrl: thumbnailUrl,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      durationMs: durationMs,
      status: status,
      visibility: visibility,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
      updatedAt: updatedAt,
      contentKind: contentKind ?? this.contentKind,
      slides: slides ?? this.slides,
    );
  }
}

class VideoComment {
  const VideoComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorProfilePicture,
    required this.text,
    required this.likeCount,
    required this.likedByMe,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorProfilePicture;
  final String text;
  final int likeCount;
  /// Whether the authenticated user liked this comment (from API).
  final bool likedByMe;
  /// Null or empty = top-level comment; otherwise id of parent comment.
  final String? parentCommentId;
  final String? createdAt;
  final String? updatedAt;

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    final parent = _nullableString(json['parentCommentId']);
    return VideoComment(
      id: _stringValue(json['id']),
      authorId: _stringValue(json['authorId']),
      authorName: _stringValue(json['authorName'], fallback: 'Unknown User'),
      authorProfilePicture: _stringValue(
        json['authorProfilePicture'],
        fallback: 'default',
      ),
      text: _stringValue(json['text']),
      likeCount: _intValue(json['likeCount']),
      likedByMe: json['likedByMe'] == true,
      parentCommentId: parent != null && parent.isEmpty ? null : parent,
      createdAt: _nullableString(json['createdAt']),
      updatedAt: _nullableString(json['updatedAt']),
    );
  }

  VideoComment copyWith({
    String? authorName,
    String? authorProfilePicture,
    int? likeCount,
    bool? likedByMe,
  }) {
    return VideoComment(
      id: id,
      authorId: authorId,
      authorName: authorName ?? this.authorName,
      authorProfilePicture:
          authorProfilePicture ?? this.authorProfilePicture,
      text: text,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      parentCommentId: parentCommentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// One top-level comment plus every reply in that thread (nested, DFS order).
class VideoCommentThreadGroup {
  const VideoCommentThreadGroup({
    required this.root,
    required this.replies,
  });

  final VideoComment root;
  /// All descendants of [root], depth-first (sorted children at each level).
  final List<VideoComment> replies;
}

/// Builds one [VideoCommentThreadGroup] per root (newest roots first). Replies
/// stay nested under their root for collapsible UI. Orphans are roots.
List<VideoCommentThreadGroup> groupVideoCommentsForFeed(List<VideoComment> all) {
  if (all.isEmpty) return const [];
  final byId = {for (final c in all) c.id: c};
  final childrenOf = <String, List<VideoComment>>{};
  for (final c in all) {
    final p = c.parentCommentId;
    if (p != null && p.isNotEmpty && byId.containsKey(p)) {
      childrenOf.putIfAbsent(p, () => []).add(c);
    }
  }
  for (final list in childrenOf.values) {
    list.sort((a, b) => (a.createdAt ?? '').compareTo(b.createdAt ?? ''));
  }
  bool isRoot(VideoComment c) {
    final p = c.parentCommentId;
    return p == null || p.isEmpty || !byId.containsKey(p);
  }

  void appendSubtree(VideoComment parent, List<VideoComment> acc) {
    for (final ch in childrenOf[parent.id] ?? []) {
      acc.add(ch);
      appendSubtree(ch, acc);
    }
  }

  final roots = all.where(isRoot).toList()
    ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
  return [
    for (final r in roots)
      VideoCommentThreadGroup(
        root: r,
        replies: () {
          final acc = <VideoComment>[];
          appendSubtree(r, acc);
          return acc;
        }(),
      ),
  ];
}

class SignedVideoUpload {
  const SignedVideoUpload({
    required this.uploadUrl,
    required this.storagePath,
    required this.expiresAt,
  });

  final String uploadUrl;
  final String storagePath;
  final String expiresAt;

  factory SignedVideoUpload.fromJson(Map<String, dynamic> json) {
    return SignedVideoUpload(
      uploadUrl: _stringValue(json['uploadUrl']),
      storagePath: _stringValue(json['storagePath']),
      expiresAt: _stringValue(json['expiresAt']),
    );
  }
}

/// Presigned PUT slot for one slideshow image (order matches [Image] list).
class SlideUploadSlot {
  const SlideUploadSlot({
    required this.order,
    required this.uploadUrl,
    required this.storagePath,
    required this.expiresAt,
  });

  final int order;
  final String uploadUrl;
  final String storagePath;
  final String expiresAt;

  factory SlideUploadSlot.fromJson(Map<String, dynamic> json) {
    final orderRaw = json['order'] ?? json['index'];
    return SlideUploadSlot(
      order: orderRaw is int ? orderRaw : int.tryParse('$orderRaw') ?? 0,
      uploadUrl: _stringValue(json['uploadUrl']),
      storagePath: _stringValue(json['storagePath']),
      expiresAt: _stringValue(json['expiresAt']),
    );
  }
}

class CreateVideoUploadResponse {
  const CreateVideoUploadResponse({
    required this.video,
    this.upload,
    this.thumbnailUpload,
    this.slideUploads = const [],
  });

  final VideoPost video;
  final SignedVideoUpload? upload;
  final SignedVideoUpload? thumbnailUpload;
  final List<SlideUploadSlot> slideUploads;

  factory CreateVideoUploadResponse.fromJson(Map<String, dynamic> json) {
    final rawSlides = json['slideUploads'] as List<dynamic>?;
    final List<SlideUploadSlot> slots;
    if (rawSlides == null) {
      slots = const [];
    } else {
      slots = rawSlides
          .map((e) => SlideUploadSlot.fromJson(_mapValue(e)))
          .toList();
      slots.sort((a, b) => a.order.compareTo(b.order));
    }

    return CreateVideoUploadResponse(
      video: VideoPost.fromJson(_mapValue(json['video'])),
      upload: json['upload'] == null
          ? null
          : SignedVideoUpload.fromJson(_mapValue(json['upload'])),
      thumbnailUpload: json['thumbnailUpload'] == null
          ? null
          : SignedVideoUpload.fromJson(_mapValue(json['thumbnailUpload'])),
      slideUploads: slots,
    );
  }
}

String _stringValue(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _nullableString(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int _intValue(Object? value) => _nullableInt(value) ?? 0;

int? _nullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

Map<String, dynamic> _mapValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}
