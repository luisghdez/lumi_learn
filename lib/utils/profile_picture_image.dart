import 'package:flutter/painting.dart';

/// Avatar image for `profilePicture` / `ownerProfilePicture` API fields:
/// `http(s)` URL, `default` / empty → stock asset, otherwise `assets/pfp/pfp{id}.png`.
ImageProvider profilePictureProvider(String raw) {
  final s = raw.trim();
  if (s.isEmpty || s == 'default') {
    return const AssetImage('assets/pfp/pfp28.png');
  }
  final lower = s.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return NetworkImage(s);
  }
  return AssetImage('assets/pfp/pfp$s.png');
}
