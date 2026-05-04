/// Feed filter mode (top pills on [FeedScreen]).
enum FeedScope {
  /// Default personalized feed.
  forYou,

  /// Posts from people you follow (client filter + optional API hint).
  friends,

  /// Posts tagged with [VideoController.feedSubject] (exact catalog string).
  subject,
}
