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

  factory VideoPost.fromJson(Map<String, dynamic> json) {
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
    );
  }

  VideoPost copyWith({
    String? playbackUrl,
    String? subject,
    int? likeCount,
    int? commentCount,
    bool? likedByMe,
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
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String authorId;
  final String authorName;
  final String authorProfilePicture;
  final String text;
  final int likeCount;
  final String? createdAt;
  final String? updatedAt;

  factory VideoComment.fromJson(Map<String, dynamic> json) {
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
      createdAt: _nullableString(json['createdAt']),
      updatedAt: _nullableString(json['updatedAt']),
    );
  }
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

class CreateVideoUploadResponse {
  const CreateVideoUploadResponse({
    required this.video,
    required this.upload,
    required this.thumbnailUpload,
  });

  final VideoPost video;
  final SignedVideoUpload upload;
  final SignedVideoUpload? thumbnailUpload;

  factory CreateVideoUploadResponse.fromJson(Map<String, dynamic> json) {
    return CreateVideoUploadResponse(
      video: VideoPost.fromJson(_mapValue(json['video'])),
      upload: SignedVideoUpload.fromJson(_mapValue(json['upload'])),
      thumbnailUpload: json['thumbnailUpload'] == null
          ? null
          : SignedVideoUpload.fromJson(_mapValue(json['thumbnailUpload'])),
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
