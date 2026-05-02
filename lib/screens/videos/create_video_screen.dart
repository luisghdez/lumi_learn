import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/data/subject_catalog.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({super.key});

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  final VideoController _videoController = Get.find<VideoController>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _subjectSearchController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  VideoPlayerController? _previewController;
  Uint8List? _thumbnailBytes;
  String _selectedSubject = '';
  bool _isGeneratingThumbnail = false;

  bool get _hasVideo => _selectedFile != null;
  bool get _hasPostDetails => _hasVideo && _selectedSubject.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _captionController.dispose();
    _subjectSearchController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    await _loadSelectedVideo(File(picked.path));
  }

  Future<void> _loadSelectedVideo(File file) async {
    await _previewController?.dispose();
    final previewController = VideoPlayerController.file(file);
    await previewController.initialize();
    await previewController.setLooping(true);
    await previewController.seekTo(Duration.zero);

    if (!mounted) {
      await previewController.dispose();
      return;
    }

    setState(() {
      _selectedFile = file;
      _previewController = previewController;
      _thumbnailBytes = null;
    });

    await _generateFirstFrameThumbnail();
  }

  Future<void> _generateFirstFrameThumbnail() async {
    final file = _selectedFile;
    if (file == null) return;

    setState(() => _isGeneratingThumbnail = true);
    try {
      final bytes = await _createFirstFrameThumbnail(file);
      if (!mounted || bytes == null) return;
      setState(() => _thumbnailBytes = bytes);
    } catch (e) {
      debugPrint('First-frame thumbnail generation failed: $e');
    } finally {
      if (mounted) setState(() => _isGeneratingThumbnail = false);
    }
  }

  Future<Uint8List?> _createFirstFrameThumbnail(File file) async {
    try {
      return await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 720,
        quality: 88,
        timeMs: 0,
      );
    } on MissingPluginException catch (e) {
      debugPrint('video_thumbnail plugin is unavailable: $e');
      return null;
    } catch (e) {
      debugPrint('First-frame thumbnail generation failed: $e');
      return null;
    }
  }

  void _clearVideo() {
    _previewController?.pause();
    _previewController?.dispose();
    setState(() {
      _selectedFile = null;
      _previewController = null;
      _thumbnailBytes = null;
    });
  }

  void _togglePreviewPlayback() {
    final controller = _previewController;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  Future<void> _publish() async {
    final file = _selectedFile;
    final caption = _captionController.text;
    final subject = _selectedSubject;
    final existingThumbnailBytes = _thumbnailBytes;

    if (file == null || subject.isEmpty) return;

    _videoController.isPreparingVideoPost.value = true;
    Get.find<NavigationController>().updateIndex(2);
    Get.back<void>();

    () async {
      try {
        final thumbnailBytes =
            existingThumbnailBytes ?? await _createFirstFrameThumbnail(file);
        _videoController.isPreparingVideoPost.value = false;
        final success = await _videoController.uploadVideo(
          file: file,
          caption: caption,
          subject: subject,
          thumbnailBytes: thumbnailBytes,
        );

        if (success) {
          Get.snackbar('Posted', 'Your video is live on your profile.');
        }
      } catch (e) {
        Get.snackbar('Video Upload', 'Failed to publish: $e');
      } finally {
        _videoController.isPreparingVideoPost.value = false;
      }
    }();
  }

  void _showSubjectPicker() {
    _subjectSearchController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) {
        return _SubjectPickerSheet(
          searchController: _subjectSearchController,
          selectedSubject: _selectedSubject,
          onSelected: (subject) {
            setState(() => _selectedSubject = subject);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _CreateBackdrop(),
          SafeArea(
            child: Obx(() {
              final isUploading = _videoController.isUploading.value;
              final uploadStatus = _videoController.uploadStatus.value;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _hasVideo
                    ? _PostDetailsView(
                        key: const ValueKey('details'),
                        previewController: _previewController,
                        captionController: _captionController,
                        captionLength: _captionController.text.length,
                        selectedSubject: _selectedSubject,
                        thumbnailBytes: _thumbnailBytes,
                        isGeneratingThumbnail: _isGeneratingThumbnail,
                        isUploading: isUploading,
                        uploadStatus: uploadStatus,
                        canPublish: _hasPostDetails && !isUploading,
                        onClose: _clearVideo,
                        onPickSubject:
                            isUploading ? null : _showSubjectPicker,
                        onPublish: _publish,
                        onTogglePlayback: _togglePreviewPlayback,
                      )
                    : _PickVideoView(
                        key: const ValueKey('pick'),
                        onClose: () => Get.back<void>(),
                        onPickVideo: _pickVideo,
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Decorative background — soft cosmic gradient that lives behind every view.
// ---------------------------------------------------------------------------

class _CreateBackdrop extends StatelessWidget {
  const _CreateBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.5, -0.7),
          radius: 1.6,
          colors: [
            Color(0xFF1B1232),
            Color(0xFF050505),
          ],
          stops: [0, 0.85],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — pick a video.
// ---------------------------------------------------------------------------

class _PickVideoView extends StatelessWidget {
  const _PickVideoView({
    super.key,
    required this.onClose,
    required this.onPickVideo,
  });

  final VoidCallback onClose;
  final VoidCallback onPickVideo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          _GlassTopBar(
            onClose: onClose,
            title: 'New video',
          ),
          const Spacer(),
          _PickVideoTile(onTap: onPickVideo),
          const SizedBox(height: 22),
          const Text(
            'Choose your clip',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pick a short video from your gallery — you'll add a "
            'subject and caption next.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _PickVideoTile extends StatefulWidget {
  const _PickVideoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_PickVideoTile> createState() => _PickVideoTileState();
}

class _PickVideoTileState extends State<_PickVideoTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E5CFF).withValues(alpha: 0.18),
                  blurRadius: 30,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(_floatController.value);
                  return Transform.translate(
                    offset: Offset(0, -3 + t * 6),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — post details (preview + caption + subject + post button).
// ---------------------------------------------------------------------------

class _PostDetailsView extends StatelessWidget {
  const _PostDetailsView({
    super.key,
    required this.previewController,
    required this.captionController,
    required this.captionLength,
    required this.selectedSubject,
    required this.thumbnailBytes,
    required this.isGeneratingThumbnail,
    required this.isUploading,
    required this.uploadStatus,
    required this.canPublish,
    required this.onClose,
    required this.onPickSubject,
    required this.onPublish,
    required this.onTogglePlayback,
  });

  final VideoPlayerController? previewController;
  final TextEditingController captionController;
  final int captionLength;
  final String selectedSubject;
  final Uint8List? thumbnailBytes;
  final bool isGeneratingThumbnail;
  final bool isUploading;
  final String uploadStatus;
  final bool canPublish;
  final VoidCallback onClose;
  final VoidCallback? onPickSubject;
  final VoidCallback onPublish;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GlassTopBar(
            onClose: onClose,
            title: 'New video',
          ),
          const SizedBox(height: 14),
          _VideoPreviewCard(
            controller: previewController,
            thumbnailBytes: thumbnailBytes,
            isGenerating: isGeneratingThumbnail,
            onTogglePlayback: onTogglePlayback,
          ),
          const SizedBox(height: 14),
          _GlassCaptionField(
            controller: captionController,
            enabled: !isUploading,
            length: captionLength,
          ),
          const SizedBox(height: 12),
          _SubjectSelector(
            subject: selectedSubject,
            onTap: onPickSubject,
          ),
          const Spacer(),
          if (isUploading) ...[
            _UploadProgress(label: uploadStatus),
            const SizedBox(height: 14),
          ],
          AnimatedOpacity(
            opacity: keyboardOpen ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: keyboardOpen,
              child: _PostButton(
                isUploading: isUploading,
                canPublish: canPublish,
                onTap: onPublish,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable glass building blocks for this screen.
// ---------------------------------------------------------------------------

class _GlassTopBar extends StatelessWidget {
  const _GlassTopBar({
    required this.onClose,
    required this.title,
  });

  final VoidCallback onClose;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GlassIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onClose,
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        // Spacer to balance the back button so the title is visually centered.
        const SizedBox(width: 44),
      ],
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _VideoPreviewCard extends StatelessWidget {
  const _VideoPreviewCard({
    required this.controller,
    required this.thumbnailBytes,
    required this.isGenerating,
    required this.onTogglePlayback,
  });

  final VideoPlayerController? controller;
  final Uint8List? thumbnailBytes;
  final bool isGenerating;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTogglePlayback,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          // Compact preview so video + caption + subject + post all fit on
          // a single non-scrolling screen on common phone sizes.
          height: 200,
          child: AspectRatio(
            aspectRatio: 9 / 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (controller != null &&
                        controller!.value.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller!.value.size.width,
                          height: controller!.value.size.height,
                          child: VideoPlayer(controller!),
                        ),
                      )
                    else if (thumbnailBytes != null)
                      Image.memory(thumbnailBytes!, fit: BoxFit.cover)
                    else
                      Container(
                        color: Colors.white.withValues(alpha: 0.04),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.movie_creation_outlined,
                          color: Colors.white38,
                          size: 32,
                        ),
                      ),
                    // Soft top + bottom shading so the play indicator and
                    // any overlays read clearly against the video frames.
                    IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.32),
                            ],
                            stops: const [0, 0.4, 1],
                          ),
                        ),
                      ),
                    ),
                    if (isGenerating)
                      ColoredBox(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else if (controller != null &&
                        controller!.value.isInitialized &&
                        !controller!.value.isPlaying)
                      Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCaptionField extends StatelessWidget {
  const _GlassCaptionField({
    required this.controller,
    required this.enabled,
    required this.length,
  });

  final TextEditingController controller;
  final bool enabled;
  final int length;

  static const int _maxLength = 2200;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: controller,
                enabled: enabled,
                minLines: 3,
                maxLines: 3,
                maxLength: _maxLength,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Add a caption…',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                    fontSize: 14.5,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$length / $_maxLength',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({
    required this.subject,
    required this.onTap,
  });

  final String subject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasSubject = subject.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: hasSubject ? 0.10 : 0.06,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: hasSubject ? 0.20 : 0.12,
                ),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E5CFF).withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF8E5CFF),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasSubject ? subject : 'Choose a subject',
                    style: TextStyle(
                      color: hasSubject
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withValues(alpha: 0.45),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadProgress extends StatelessWidget {
  const _UploadProgress({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF8E5CFF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label.isEmpty ? 'Uploading…' : label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF8E5CFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostButton extends StatelessWidget {
  const _PostButton({
    required this.isUploading,
    required this.canPublish,
    required this.onTap,
  });

  final bool isUploading;
  final bool canPublish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = canPublish && !isUploading;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: enabled
                ? const [Color(0xFFFFFFFF), Color(0xFFE4E4E4)]
                : [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.04),
                  ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: enabled ? 0.85 : 0.14),
            width: 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.20),
                    blurRadius: 22,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUploading) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                isUploading ? 'Posting…' : 'Post',
                style: TextStyle(
                  color: enabled
                      ? Colors.black
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subject picker — same glass language as the comments sheet.
// ---------------------------------------------------------------------------

class _SubjectPickerSheet extends StatefulWidget {
  const _SubjectPickerSheet({
    required this.searchController,
    required this.selectedSubject,
    required this.onSelected,
  });

  final TextEditingController searchController;
  final String selectedSubject;
  final ValueChanged<String> onSelected;

  @override
  State<_SubjectPickerSheet> createState() => _SubjectPickerSheetState();
}

class _SubjectPickerSheetState extends State<_SubjectPickerSheet> {
  String _query = '';

  List<String> get _filteredSubjects {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return allSubjects;
    return allSubjects
        .where((subject) => subject.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final subjects = _filteredSubjects;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: screenHeight * 0.78,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose subject',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _GlassSearchField(
                      controller: widget.searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final isSelected = subject == widget.selectedSubject;

                        return _SubjectTile(
                          subject: subject,
                          isSelected: isSelected,
                          onTap: () => widget.onSelected(subject),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSearchField extends StatelessWidget {
  const _GlassSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Colors.white.withValues(alpha: 0.55),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: false,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Search subjects',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  final String subject;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                subject,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
