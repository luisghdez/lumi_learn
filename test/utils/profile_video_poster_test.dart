import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_learn_app/utils/profile_video_poster.dart';

void main() {
  test('prefers a video thumbnail over a slideshow image', () {
    expect(
      profileVideoPosterUrl(
        thumbnailUrl: 'https://cdn.example.com/poster.jpg',
        firstSlideUrl: 'https://cdn.example.com/slide.jpg',
      ),
      'https://cdn.example.com/poster.jpg',
    );
  });

  test('uses the first slide when a slideshow has no thumbnail', () {
    expect(
      profileVideoPosterUrl(
        thumbnailUrl: null,
        firstSlideUrl: 'https://cdn.example.com/slide.jpg',
      ),
      'https://cdn.example.com/slide.jpg',
    );
  });

  test('does not use a playback URL when no image poster exists', () {
    expect(
      profileVideoPosterUrl(thumbnailUrl: '  ', firstSlideUrl: null),
      isNull,
    );
  });
}
