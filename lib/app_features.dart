/// Product features that are intentionally vaulted but kept ready to restore.
class AppFeatures {
  /// Enables entry points for creating a course from source material.
  ///
  /// Keep the underlying flow in place so the feature can be restored without
  /// rebuilding it. Each surface should use this flag rather than deleting the
  /// course-creation implementation.
  static const bool courseCreationEnabled = false;
}
