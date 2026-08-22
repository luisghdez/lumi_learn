import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';

void main() {
  test('accepts a lightweight profile-grid video without a playback URL', () {
    final video = VideoPost.fromJson({
      'id': 'video-1',
      'ownerId': 'owner-1',
      'ownerName': 'Ada',
      'ownerProfilePicture': 'default',
      'caption': 'A clip',
      'subject': 'Physics',
      'storagePath': 'videos/owner-1/video-1/original.mp4',
      'thumbnailUrl': 'https://cdn.example.com/poster.jpg',
      'mimeType': 'video/mp4',
      'status': 'ready',
      'visibility': 'public',
      'likeCount': 12,
      'viewCount': 34,
      'commentCount': 5,
      'contentKind': 'video',
    });

    expect(video.playbackUrl, isNull);
    expect(video.thumbnailUrl, 'https://cdn.example.com/poster.jpg');
    expect(video.likeCount, 12);
    expect(video.subject, 'Physics');
  });
}
