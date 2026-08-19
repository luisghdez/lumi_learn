import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_learn_app/utils/video_player_window.dart';

void main() {
  const window = VideoPlayerWindow(initializeRadius: 2, keepAliveRadius: 3);

  test('preloads only the current page and two adjacent pages', () {
    expect(
      [0, 1, 2, 3, 4]
          .where((index) => window.shouldInitialize(pageIndex: index, currentIndex: 2))
          .toList(),
      [0, 1, 2, 3, 4],
    );
    expect(window.shouldInitialize(pageIndex: 5, currentIndex: 2), isFalse);
  });

  test('releases controllers outside the keep-alive window', () {
    expect(window.shouldKeepAlive(pageIndex: 7, currentIndex: 4), isTrue);
    expect(window.shouldKeepAlive(pageIndex: 8, currentIndex: 4), isFalse);
  });
}
