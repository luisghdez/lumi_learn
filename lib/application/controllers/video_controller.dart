import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/models/feed_scope.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';

class VideoController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _api = ApiService();

  final RxList<VideoPost> videos = <VideoPost>[].obs;
  final RxMap<String, List<VideoPost>> userVideosByUserId =
      <String, List<VideoPost>>{}.obs;
  final RxMap<String, List<VideoComment>> commentsByVideoId =
      <String, List<VideoComment>>{}.obs;
  final RxMap<String, bool> loadingCommentsByVideoId = <String, bool>{}.obs;
  final RxMap<String, bool> loadingUserVideosByUserId = <String, bool>{}.obs;

  final RxBool isLoadingFeed = false.obs;
  final RxBool isRefreshingFeed = false.obs;
  final RxBool isUploading = false.obs;
  final RxBool isPreparingVideoPost = false.obs;
  final RxString uploadStatus = ''.obs;
  final RxString feedError = ''.obs;

  /// Top-of-feed filter (For you / Friends / Subject).
  final Rx<FeedScope> feedScope = FeedScope.forYou.obs;

  /// When [feedScope] is [FeedScope.subject], exact label from [allSubjects].
  final RxString feedSubject = ''.obs;

  /// Set after [openSharedVideoFromDeepLink]; [FeedScreen] scrolls to this id.
  final RxnString pendingScrollFeedToVideoId = RxnString();

  String? _nextFeedCursor;
  final Map<String, String?> _userVideoCursorsByUserId = {};
  final Map<String, String?> _commentCursorsByVideoId = {};

  String? get currentUserId => authController.firebaseUser.value?.uid;
  bool get hasMoreFeed => _nextFeedCursor != null;
  bool get hasPendingVideoPost =>
      isPreparingVideoPost.value || isUploading.value;
  bool hasMoreUserVideos(String userId) =>
      _userVideoCursorsByUserId[userId] != null;

  @override
  void onInit() {
    super.onInit();
    fetchFeed(refresh: true);
  }

  /// Changes filter and reloads the feed (same API; friends/subject also refined client-side).
  Future<void> setFeedScope(FeedScope scope, {String? subject}) async {
    final subj = subject?.trim() ?? '';
    if (scope != FeedScope.subject && scope == feedScope.value) {
      return;
    }
    if (scope == FeedScope.subject &&
        feedScope.value == FeedScope.subject &&
        subj.isNotEmpty &&
        subj == feedSubject.value.trim()) {
      return;
    }

    feedScope.value = scope;
    if (scope != FeedScope.subject) {
      feedSubject.value = '';
    } else if (subj.isNotEmpty) {
      feedSubject.value = subj;
    }
    await fetchFeed(refresh: true);
  }

  Future<void> fetchFeed({bool refresh = false}) async {
    if (isLoadingFeed.value && !refresh) return;

    final token = await _tokenOrNotify();
    if (token == null) return;

    if (refresh) {
      isRefreshingFeed.value = true;
      _nextFeedCursor = null;
    } else {
      isLoadingFeed.value = true;
    }
    feedError.value = '';

    try {
      final scope = feedScope.value;
      final subjectQ =
          scope == FeedScope.subject && feedSubject.value.trim().isNotEmpty
              ? feedSubject.value.trim()
              : null;
      final friendsQ = scope == FeedScope.friends ? true : null;

      final response = await _api.getVideoFeed(
        token: token,
        cursor: refresh ? null : _nextFeedCursor,
        subject: subjectQ,
        friendsOnly: friendsQ,
      );
      _ensureSuccess(response, expectedStatuses: const [200]);

      final body = _decodeBody(response.body);
      var fetchedVideos = (body['videos'] as List<dynamic>? ?? [])
          .map((item) => VideoPost.fromJson(_asMap(item)))
          .where((video) =>
              video.isSlideshow ||
              (video.playbackUrl != null && video.playbackUrl!.isNotEmpty))
          .toList();

      if (scope == FeedScope.friends && Get.isRegistered<FriendsController>()) {
        final ids = Get.find<FriendsController>()
            .friends
            .map((f) => f.id)
            .toSet();
        if (ids.isNotEmpty) {
          fetchedVideos =
              fetchedVideos.where((v) => ids.contains(v.ownerId)).toList();
        } else {
          fetchedVideos = [];
        }
      }

      if (scope == FeedScope.subject && feedSubject.value.trim().isNotEmpty) {
        final needle = feedSubject.value.trim().toLowerCase();
        fetchedVideos = fetchedVideos
            .where(
              (v) => v.subject.trim().toLowerCase() == needle,
            )
            .toList();
      }

      _nextFeedCursor = body['nextCursor'] as String?;
      if (refresh) {
        videos.assignAll(fetchedVideos);
      } else {
        videos.addAll(fetchedVideos);
      }
    } catch (e) {
      feedError.value = e.toString();
      Get.snackbar(
        'Video Feed',
        'Failed to load videos.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingFeed.value = false;
      isRefreshingFeed.value = false;
    }
  }

  Future<VideoPost?> getVideoById(String videoId) async {
    final token = await _tokenOrNotify();
    if (token == null) return null;

    final response = await _api.getVideoById(token: token, videoId: videoId);
    _ensureSuccess(response, expectedStatuses: const [200]);
    final video =
        VideoPost.fromJson(_asMap(_decodeBody(response.body)['video']));
    final feedIdx = videos.indexWhere((item) => item.id == video.id);
    if (feedIdx != -1) {
      videos[feedIdx] = video;
    } else {
      videos.insert(0, video);
    }
    final userVideos = userVideosByUserId[video.ownerId];
    if (userVideos != null) {
      final userVideoIndex =
          userVideos.indexWhere((item) => item.id == video.id);
      if (userVideoIndex != -1) {
        final updatedUserVideos = [...userVideos];
        updatedUserVideos[userVideoIndex] = video;
        userVideosByUserId[video.ownerId] = updatedUserVideos;
      }
    }
    return video;
  }

  /// Loads the clip, switches to the feed tab, and signals [FeedScreen] to
  /// scroll to it (used by universal links).
  Future<bool> openSharedVideoFromDeepLink(String videoId) async {
    try {
      final video = await getVideoById(videoId);
      if (video == null) return false;
      if (!Get.isRegistered<NavigationController>()) return false;
      Get.find<NavigationController>().updateIndex(1);
      pendingScrollFeedToVideoId.value = videoId;
      return true;
    } catch (e, st) {
      debugPrint('openSharedVideoFromDeepLink: $e\n$st');
      Get.snackbar(
        'Video',
        'Could not open this video link.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<bool> uploadVideo({
    required File file,
    required String caption,
    required String subject,
    Uint8List? thumbnailBytes,
  }) async {
    final token = await _tokenOrNotify();
    if (token == null) return false;

    final mimeType = lookupMimeType(file.path) ?? 'video/mp4';
    if (!mimeType.toLowerCase().startsWith('video/')) {
      Get.snackbar('Video Upload', 'Please choose a video file.');
      return false;
    }

    isUploading.value = true;
    try {
      uploadStatus.value = 'Creating video';
      final createResponse = await _api.createVideo(
        token: token,
        mimeType: mimeType,
        subject: subject,
        thumbnailMimeType: thumbnailBytes == null ? null : 'image/jpeg',
        caption: caption,
      );
      _ensureSuccess(createResponse, expectedStatuses: const [201]);
      final created = CreateVideoUploadResponse.fromJson(
        _decodeBody(createResponse.body),
      );
      final mainUpload = created.upload;
      if (mainUpload == null) {
        throw Exception('Missing main video upload URL from server.');
      }

      uploadStatus.value = 'Uploading video';
      final uploadResponse = await _api.uploadVideoFileToSignedUrl(
        uploadUrl: mainUpload.uploadUrl,
        file: file,
        mimeType: mimeType,
      );
      if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
        throw Exception('Storage upload failed: ${uploadResponse.statusCode}');
      }

      final thumbnailUpload = created.thumbnailUpload;
      if (thumbnailBytes != null) {
        if (thumbnailUpload == null) {
          throw Exception('Thumbnail upload target was not created.');
        }

        uploadStatus.value = 'Uploading thumbnail';
        final thumbnailResponse = await _api.uploadBytesToSignedUrl(
          uploadUrl: thumbnailUpload.uploadUrl,
          bytes: thumbnailBytes,
          mimeType: 'image/jpeg',
        );
        if (thumbnailResponse.statusCode < 200 ||
            thumbnailResponse.statusCode >= 300) {
          throw Exception(
            'Thumbnail upload failed: ${thumbnailResponse.statusCode}',
          );
        }
      }

      uploadStatus.value = 'Publishing video';
      final completeResponse = await _api.completeVideoUpload(
        token: token,
        videoId: created.video.id,
      );
      _ensureSuccess(completeResponse, expectedStatuses: const [200]);
      final completed = VideoPost.fromJson(
        _asMap(_decodeBody(completeResponse.body)['video']),
      );

      videos.removeWhere((video) => video.id == completed.id);
      videos.insert(0, completed);
      _insertUserVideo(completed);
      return true;
    } catch (e) {
      Get.snackbar(
        'Video Upload',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      uploadStatus.value = '';
      isUploading.value = false;
    }
  }

  /// Native slideshow (Option B): multiple images, one feed post.
  Future<bool> uploadSlideshow({
    required List<File> imageFiles,
    required String caption,
    required String subject,
    int defaultSlideDurationMs = 3500,
  }) async {
    if (imageFiles.isEmpty) return false;
    if (imageFiles.length > 20) {
      Get.snackbar('Slideshow', 'Use at most 20 images.');
      return false;
    }

    final token = await _tokenOrNotify();
    if (token == null) return false;

    final slideMimeTypes = <String>[];
    for (final f in imageFiles) {
      final m = lookupMimeType(f.path) ?? 'image/jpeg';
      if (!m.toLowerCase().startsWith('image/')) {
        Get.snackbar('Slideshow', 'Only image files are supported.');
        return false;
      }
      slideMimeTypes.add(m);
    }

    Uint8List? thumbBytes;
    try {
      thumbBytes = await imageFiles.first.readAsBytes();
    } catch (_) {}

    isUploading.value = true;
    try {
      uploadStatus.value = 'Creating slideshow';
      final firstMime = slideMimeTypes.first;
      final createResponse = await _api.createVideo(
        token: token,
        mimeType: 'image/slideshow',
        subject: subject,
        caption: caption,
        contentKind: 'slideshow',
        slideCount: imageFiles.length,
        defaultSlideDurationMs: defaultSlideDurationMs,
        slideMimeTypes: slideMimeTypes,
        thumbnailMimeType: thumbBytes != null ? firstMime : null,
      );
      _ensureSuccess(createResponse, expectedStatuses: const [201]);
      final created = CreateVideoUploadResponse.fromJson(
        _decodeBody(createResponse.body),
      );
      if (created.slideUploads.length != imageFiles.length) {
        throw Exception(
          'Server returned ${created.slideUploads.length} upload slots for '
          '${imageFiles.length} images. Enable slideshow fields on POST /videos.',
        );
      }

      for (var i = 0; i < imageFiles.length; i++) {
        uploadStatus.value = 'Uploading image ${i + 1}/${imageFiles.length}';
        final slot = created.slideUploads[i];
        final bytes = await imageFiles[i].readAsBytes();
        final res = await _api.uploadBytesToSignedUrl(
          uploadUrl: slot.uploadUrl,
          bytes: bytes,
          mimeType: slideMimeTypes[i],
        );
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw Exception('Slide ${i + 1} upload failed: ${res.statusCode}');
        }
      }

      final thumbnailUpload = created.thumbnailUpload;
      if (thumbBytes != null && thumbnailUpload != null) {
        uploadStatus.value = 'Uploading cover';
        final tRes = await _api.uploadBytesToSignedUrl(
          uploadUrl: thumbnailUpload.uploadUrl,
          bytes: thumbBytes,
          mimeType: firstMime.startsWith('image/') ? firstMime : 'image/jpeg',
        );
        if (tRes.statusCode < 200 || tRes.statusCode >= 300) {
          throw Exception('Thumbnail upload failed: ${tRes.statusCode}');
        }
      }

      final slidesPayload = <Map<String, dynamic>>[];
      for (final slot in created.slideUploads) {
        slidesPayload.add({
          'storagePath': slot.storagePath,
          'order': slot.order,
          'durationMs': defaultSlideDurationMs,
        });
      }
      final totalMs = defaultSlideDurationMs * imageFiles.length;

      uploadStatus.value = 'Publishing';
      final completeResponse = await _api.completeVideoUpload(
        token: token,
        videoId: created.video.id,
        durationMs: totalMs,
        slides: slidesPayload,
      );
      _ensureSuccess(completeResponse, expectedStatuses: const [200]);
      final completed = VideoPost.fromJson(
        _asMap(_decodeBody(completeResponse.body)['video']),
      );

      videos.removeWhere((video) => video.id == completed.id);
      videos.insert(0, completed);
      _insertUserVideo(completed);
      return true;
    } catch (e) {
      Get.snackbar(
        'Slideshow',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      uploadStatus.value = '';
      isUploading.value = false;
    }
  }

  Future<void> toggleLike(VideoPost video) async {
    final token = await _tokenOrNotify();
    if (token == null) return;

    final original = video;
    final nextLiked = !video.likedByMe;
    final optimistic = video.copyWith(
      likedByMe: nextLiked,
      likeCount: nextLiked ? video.likeCount + 1 : _decrement(video.likeCount),
    );
    _replaceVideo(optimistic);

    try {
      final response = nextLiked
          ? await _api.likeVideo(token: token, videoId: video.id)
          : await _api.unlikeVideo(token: token, videoId: video.id);
      _ensureSuccess(response, expectedStatuses: const [200]);
      final body = _decodeBody(response.body);
      _replaceVideo(
        optimistic.copyWith(
          likedByMe: body['liked'] == true,
          likeCount: _intValue(body['likeCount'], optimistic.likeCount),
        ),
      );
    } catch (_) {
      _replaceVideo(original);
      Get.snackbar('Video Like', 'Failed to update like.');
    }
  }

  Future<void> deleteVideo(VideoPost video) async {
    final token = await _tokenOrNotify();
    if (token == null) return;

    try {
      final response = await _api.deleteVideo(token: token, videoId: video.id);
      _ensureSuccess(response, expectedStatuses: const [200]);
      videos.removeWhere((item) => item.id == video.id);
      _removeUserVideo(video);
      commentsByVideoId.remove(video.id);
    } catch (e) {
      Get.snackbar('Delete Video', e.toString());
    }
  }

  Future<void> fetchUserVideos(String userId, {bool refresh = true}) async {
    if (loadingUserVideosByUserId[userId] == true) return;

    final token = await _tokenOrNotify();
    if (token == null) return;

    loadingUserVideosByUserId[userId] = true;
    if (refresh) {
      _userVideoCursorsByUserId[userId] = null;
    }

    try {
      final response = await _api.getUserVideos(
        token: token,
        userId: userId,
        cursor: refresh ? null : _userVideoCursorsByUserId[userId],
      );
      _ensureSuccess(response, expectedStatuses: const [200]);
      final body = _decodeBody(response.body);
      final fetchedVideos = (body['videos'] as List<dynamic>? ?? [])
          .map((item) => VideoPost.fromJson(_asMap(item)))
          .toList();

      _userVideoCursorsByUserId[userId] = body['nextCursor'] as String?;
      if (refresh) {
        // Keep videos the client already has for this user that the server
        // did not return yet (e.g. upload finished while an older fetch was
        // in flight, or read-your-writes lag).
        final previous = userVideosByUserId[userId] ?? <VideoPost>[];
        final fetchedIds = fetchedVideos.map((v) => v.id).toSet();
        final notYetOnServer = previous
            .where((v) => v.ownerId == userId && !fetchedIds.contains(v.id))
            .toList();
        final merged = [...notYetOnServer, ...fetchedVideos];
        _sortUserVideosNewestFirst(merged);
        userVideosByUserId[userId] = merged;
      } else {
        userVideosByUserId[userId] = [
          ...(userVideosByUserId[userId] ?? <VideoPost>[]),
          ...fetchedVideos,
        ];
      }
    } catch (e) {
      Get.snackbar('Profile Videos', e.toString());
    } finally {
      loadingUserVideosByUserId[userId] = false;
    }
  }

  Future<void> fetchComments(String videoId, {bool refresh = true}) async {
    final token = await _tokenOrNotify();
    if (token == null) return;

    loadingCommentsByVideoId[videoId] = true;
    if (refresh) {
      _commentCursorsByVideoId[videoId] = null;
    }

    try {
      // Note: do NOT call getVideoById here — it returns a fresh signed
      // playbackUrl which would invalidate the in-flight video player and
      // restart playback when the user opens the comments sheet. Like and
      // comment counts are kept up to date optimistically elsewhere.
      final response = await _api.getVideoComments(
        token: token,
        videoId: videoId,
        cursor: refresh ? null : _commentCursorsByVideoId[videoId],
      );
      _ensureSuccess(response, expectedStatuses: const [200]);
      final body = _decodeBody(response.body);
      final comments = (body['comments'] as List<dynamic>? ?? [])
          .map((item) => VideoComment.fromJson(_asMap(item)))
          .map(_withLiveSelfAvatar)
          .toList();

      _commentCursorsByVideoId[videoId] = body['nextCursor'] as String?;
      if (refresh) {
        commentsByVideoId[videoId] = comments;
      } else {
        commentsByVideoId[videoId] = [
          ...(commentsByVideoId[videoId] ?? <VideoComment>[]),
          ...comments,
        ];
      }
    } catch (e) {
      Get.snackbar('Comments', e.toString());
    } finally {
      loadingCommentsByVideoId[videoId] = false;
    }
  }

  /// Returns `true` if the comment was created successfully.
  Future<bool> createComment({
    required VideoPost video,
    required String text,
    String? parentCommentId,
  }) async {
    final token = await _tokenOrNotify();
    if (token == null) return false;

    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return false;

    try {
      final response = await _api.createVideoComment(
        token: token,
        videoId: video.id,
        text: trimmedText,
        parentCommentId: parentCommentId,
      );
      _ensureSuccess(response, expectedStatuses: const [201]);
      if (parentCommentId != null && parentCommentId.isNotEmpty) {
        await fetchComments(video.id, refresh: true);
      } else {
        var comment = VideoComment.fromJson(
          _asMap(_decodeBody(response.body)['comment']),
        );
        comment = _withLiveSelfAvatar(comment);
        commentsByVideoId[video.id] = [
          comment,
          ...(commentsByVideoId[video.id] ?? <VideoComment>[]),
        ];
      }
      _replaceVideo(video.copyWith(commentCount: video.commentCount + 1));
      return true;
    } catch (e) {
      Get.snackbar('Comments', e.toString());
      return false;
    }
  }

  Future<void> toggleCommentLike({
    required VideoPost video,
    required VideoComment comment,
  }) async {
    final token = await _tokenOrNotify();
    if (token == null) return;

    final nextLiked = !comment.likedByMe;
    final optimistic = comment.copyWith(
      likedByMe: nextLiked,
      likeCount:
          nextLiked ? comment.likeCount + 1 : _decrement(comment.likeCount),
    );
    _replaceCommentInList(video.id, comment.id, optimistic);

    try {
      final response = nextLiked
          ? await _api.likeVideoComment(
              token: token, videoId: video.id, commentId: comment.id)
          : await _api.unlikeVideoComment(
              token: token, videoId: video.id, commentId: comment.id);
      _ensureSuccess(response, expectedStatuses: const [200]);
      final body = _decodeBody(response.body);
      if (body['comment'] != null) {
        _replaceCommentInList(
          video.id,
          comment.id,
          VideoComment.fromJson(_asMap(body['comment'])),
        );
      } else {
        final likeCount = _intValue(body['likeCount'], optimistic.likeCount);
        final liked = body['liked'] == true;
        _replaceCommentInList(
          video.id,
          comment.id,
          optimistic.copyWith(likeCount: likeCount, likedByMe: liked),
        );
      }
    } catch (_) {
      _replaceCommentInList(video.id, comment.id, comment);
      Get.snackbar('Comments', 'Could not update like.');
    }
  }

  void _replaceCommentInList(
    String videoId,
    String commentId,
    VideoComment next,
  ) {
    final list = commentsByVideoId[videoId];
    if (list == null) return;
    final i = list.indexWhere((c) => c.id == commentId);
    if (i == -1) return;
    final copy = [...list];
    copy[i] = _withLiveSelfAvatar(next);
    commentsByVideoId[videoId] = copy;
  }

  /// Uses Firebase [User.photoURL] for the signed-in user so avatars match
  /// the profile editor after a PFP change (API comments may be stale).
  VideoComment _withLiveSelfAvatar(VideoComment c) {
    final uid = currentUserId;
    if (uid == null || c.authorId != uid) return c;
    final slug = authController.firebaseUser.value?.photoURL?.trim();
    if (slug == null || slug.isEmpty) return c;
    return c.copyWith(authorProfilePicture: slug);
  }

  Future<void> deleteComment({
    required VideoPost video,
    required VideoComment comment,
  }) async {
    final token = await _tokenOrNotify();
    if (token == null) return;

    try {
      final response = await _api.deleteVideoComment(
        token: token,
        videoId: video.id,
        commentId: comment.id,
      );
      _ensureSuccess(response, expectedStatuses: const [200]);
      await fetchComments(video.id, refresh: true);
      _replaceVideo(
        video.copyWith(
          commentCount: _decrement(video.commentCount),
        ),
      );
    } catch (e) {
      Get.snackbar('Comments', e.toString());
    }
  }

  Future<String?> _tokenOrNotify() async {
    final token = await authController.getIdToken();
    if (token == null) {
      Get.snackbar('Not Logged In', 'Sign in to use video features.');
    }
    return token;
  }

  void _replaceVideo(VideoPost video) {
    final index = videos.indexWhere((item) => item.id == video.id);
    if (index != -1) {
      videos[index] = video;
    }

    final userVideos = userVideosByUserId[video.ownerId];
    if (userVideos == null) return;
    final userVideoIndex = userVideos.indexWhere((item) => item.id == video.id);
    if (userVideoIndex == -1) return;
    final updatedUserVideos = [...userVideos];
    updatedUserVideos[userVideoIndex] = video;
    userVideosByUserId[video.ownerId] = updatedUserVideos;
  }

  void _insertUserVideo(VideoPost video) {
    final ownerId = video.ownerId;
    if (ownerId.isEmpty) return;
    final existingVideos = userVideosByUserId[ownerId] ?? <VideoPost>[];
    userVideosByUserId[ownerId] = [
      video,
      ...existingVideos.where((item) => item.id != video.id),
    ];
  }

  static void _sortUserVideosNewestFirst(List<VideoPost> list) {
    list.sort((a, b) {
      final ca = a.createdAt ?? '';
      final cb = b.createdAt ?? '';
      return cb.compareTo(ca);
    });
  }

  void _removeUserVideo(VideoPost video) {
    final existingVideos = userVideosByUserId[video.ownerId];
    if (existingVideos == null) return;
    userVideosByUserId[video.ownerId] = [
      ...existingVideos.where((item) => item.id != video.id),
    ];
  }

  Map<String, dynamic> _decodeBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  void _ensureSuccess(
    dynamic response, {
    required List<int> expectedStatuses,
  }) {
    if (expectedStatuses.contains(response.statusCode)) return;

    String message = 'Request failed: ${response.statusCode}';
    try {
      final decoded = _decodeBody(response.body);
      message = decoded['error']?.toString() ??
          decoded['message']?.toString() ??
          message;
    } catch (_) {
      if (response.body.toString().isNotEmpty) {
        message = response.body.toString();
      }
    }
    throw Exception(message);
  }

  int _intValue(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _decrement(int value) {
    if (value <= 0) return 0;
    return value - 1;
  }
}
