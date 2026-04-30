import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';

import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({super.key});

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  final VideoController _videoController = Get.find<VideoController>();
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  VideoPlayerController? _previewController;

  @override
  void dispose() {
    _captionController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    await _previewController?.dispose();
    final previewController = VideoPlayerController.file(File(picked.path));
    await previewController.initialize();
    await previewController.setLooping(true);
    await previewController.play();

    if (!mounted) {
      await previewController.dispose();
      return;
    }

    setState(() {
      _selectedFile = File(picked.path);
      _previewController = previewController;
    });
  }

  Future<void> _publish() async {
    final file = _selectedFile;
    if (file == null) return;

    final success = await _videoController.uploadVideo(
      file: file,
      caption: _captionController.text,
    );

    if (!success || !mounted) return;

    Get.find<NavigationController>().updateIndex(0);
    Get.back<void>();
    Get.snackbar('Video Published', 'Your video is now in the feed.');
  }

  String get _selectedFileName {
    final file = _selectedFile;
    if (file == null) return 'No video selected';
    return p.basename(file.path);
  }

  String get _selectedDuration {
    final value = _previewController?.value;
    if (value == null || !value.isInitialized) return '';
    final duration = value.duration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Create video'),
      ),
      body: SafeArea(
        child: Obx(() {
          final isUploading = _videoController.isUploading.value;
          final uploadStatus = _videoController.uploadStatus.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              const Text(
                'Start a learning video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose a short clip, add a caption, and publish it to the learning feed.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              _VideoPreview(
                controller: _previewController,
                onPickVideo: isUploading ? null : _pickVideo,
              ),
              const SizedBox(height: 16),
              _SelectedVideoCard(
                fileName: _selectedFileName,
                duration: _selectedDuration,
                hasVideo: _selectedFile != null,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _captionController,
                enabled: !isUploading,
                maxLength: 2200,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                  ),
                  hintText: 'Write a caption or lesson prompt...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.44),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFB79CFF)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (isUploading) ...[
                const LinearProgressIndicator(color: Color(0xFFB79CFF)),
                const SizedBox(height: 10),
                Text(
                  uploadStatus,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedFile == null || isUploading ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.14),
                    foregroundColor: Colors.black,
                    disabledForegroundColor:
                        Colors.white.withValues(alpha: 0.48),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(isUploading ? 'Publishing...' : 'Publish video'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({
    required this.controller,
    required this.onPickVideo,
  });

  final VideoPlayerController? controller;
  final VoidCallback? onPickVideo;

  @override
  Widget build(BuildContext context) {
    final previewController = controller;

    return GestureDetector(
      onTap: onPickVideo,
      child: AspectRatio(
        aspectRatio: 9 / 13,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          clipBehavior: Clip.antiAlias,
          child:
              previewController != null && previewController.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: previewController.value.size.width,
                        height: previewController.value.size.height,
                        child: VideoPlayer(previewController),
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file_outlined,
                          color: Color(0xFFB79CFF),
                          size: 54,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Tap to choose a video',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'A short local clip is best for testing.',
                          style: TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _SelectedVideoCard extends StatelessWidget {
  const _SelectedVideoCard({
    required this.fileName,
    required this.duration,
    required this.hasVideo,
  });

  final String fileName;
  final String duration;
  final bool hasVideo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8E5CFF).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              hasVideo ? Icons.movie_outlined : Icons.videocam_outlined,
              color: const Color(0xFFB79CFF),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasVideo && duration.isNotEmpty
                      ? 'Ready to upload • $duration'
                      : 'Pick an existing clip from your device.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.64),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
