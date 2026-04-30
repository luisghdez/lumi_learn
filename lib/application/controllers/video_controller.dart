import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';

import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';

class VideoController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ApiService _api = ApiService();

  final RxList<VideoPost> videos = <VideoPost>[].obs;
  final RxMap<String, List<VideoComment>> commentsByVideoId =
      <String, List<VideoComment>>{}.obs;
  final RxMap<String, bool> loadingCommentsByVideoId = <String, bool>{}.obs;

  final RxBool isLoadingFeed = false.obs;
  final RxBool isRefreshingFeed = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadStatus = ''.obs;
  final RxString feedError = ''.obs;

  String? _nextFeedCursor;
  final Map<String, String?> _commentCursorsByVideoId = {};

  String? get currentUserId => authController.firebaseUser.value?.uid;
  bool get hasMoreFeed => _nextFeedCursor != null;

  @override
  void onInit() {
    super.onInit();
    fetchFeed(refresh: true);
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
      final response = await _api.getVideoFeed(
        token: token,
        cursor: refresh ? null : _nextFeedCursor,
      );
      _ensureSuccess(response, expectedStatuses: const [200]);

      final body = _decodeBody(response.body);
      final fetchedVideos = (body['videos'] as List<dynamic>? ?? [])
          .map((item) => VideoPost.fromJson(_asMap(item)))
          .where((video) => video.playbackUrl != null)
          .toList();

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
    _replaceVideo(video);
    return video;
  }

  Future<bool> uploadVideo({
    required File file,
    required String caption,
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
        caption: caption,
      );
      _ensureSuccess(createResponse, expectedStatuses: const [201]);
      final created = CreateVideoUploadResponse.fromJson(
        _decodeBody(createResponse.body),
      );

      uploadStatus.value = 'Uploading video';
      final uploadResponse = await _api.uploadVideoFileToSignedUrl(
        uploadUrl: created.upload.uploadUrl,
        file: file,
        mimeType: mimeType,
      );
      if (uploadResponse.statusCode < 200 || uploadResponse.statusCode >= 300) {
        throw Exception('Storage upload failed: ${uploadResponse.statusCode}');
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
      commentsByVideoId.remove(video.id);
    } catch (e) {
      Get.snackbar('Delete Video', e.toString());
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
      await getVideoById(videoId);
      final response = await _api.getVideoComments(
        token: token,
        videoId: videoId,
        cursor: refresh ? null : _commentCursorsByVideoId[videoId],
      );
      _ensureSuccess(response, expectedStatuses: const [200]);
      final body = _decodeBody(response.body);
      final comments = (body['comments'] as List<dynamic>? ?? [])
          .map((item) => VideoComment.fromJson(_asMap(item)))
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

  Future<void> createComment({
    required VideoPost video,
    required String text,
  }) async {
    final token = await _tokenOrNotify();
    if (token == null) return;

    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    try {
      final response = await _api.createVideoComment(
        token: token,
        videoId: video.id,
        text: trimmedText,
      );
      _ensureSuccess(response, expectedStatuses: const [201]);
      final comment = VideoComment.fromJson(
        _asMap(_decodeBody(response.body)['comment']),
      );
      commentsByVideoId[video.id] = [
        comment,
        ...(commentsByVideoId[video.id] ?? <VideoComment>[]),
      ];
      _replaceVideo(video.copyWith(commentCount: video.commentCount + 1));
    } catch (e) {
      Get.snackbar('Comments', e.toString());
    }
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
      commentsByVideoId[video.id] = [
        ...(commentsByVideoId[video.id] ?? <VideoComment>[]),
      ]..removeWhere((item) => item.id == comment.id);
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
    if (index == -1) return;
    videos[index] = video;
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
