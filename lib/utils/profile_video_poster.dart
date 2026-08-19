/// Chooses an image that can be loaded directly by a profile grid tile.
///
/// Never fall back to the video URL here: extracting a remote video frame for
/// every tile opens unnecessary media requests and competes with playback.
String? profileVideoPosterUrl({
  required String? thumbnailUrl,
  required String? firstSlideUrl,
}) {
  final thumbnail = thumbnailUrl?.trim();
  if (thumbnail != null && thumbnail.isNotEmpty) return thumbnail;

  final slide = firstSlideUrl?.trim();
  if (slide != null && slide.isNotEmpty) return slide;

  return null;
}
