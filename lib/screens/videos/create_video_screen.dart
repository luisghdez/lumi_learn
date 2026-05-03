import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:lumi_learn_app/application/controllers/create_flow_controller.dart';
import 'package:lumi_learn_app/screens/create/create_flow_transitions.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/data/subject_catalog.dart';
import 'package:lumi_learn_app/widgets/bottom_nav_bar.dart'
    show createFlowContentBottomInset;
import 'package:lumi_learn_app/widgets/glass_confirm_dialog.dart';
import 'package:lumi_learn_app/widgets/lumi_cosmic_backdrop.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({
    super.key,
    this.embeddedInCreateFlow = false,
  });

  /// When true, shown inside the create hub shell with draft sync to the flow controller.
  final bool embeddedInCreateFlow;

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  final VideoController _videoController = Get.find<VideoController>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _subjectSearchController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  CreateFlowController? _createFlow;

  File? _selectedFile;
  List<File>? _slideshowFiles;
  VideoPlayerController? _previewController;
  Uint8List? _thumbnailBytes;
  String _selectedSubject = '';
  bool _isGeneratingThumbnail = false;
  bool _showPostDetails = false;

  bool get _hasVideo => _selectedFile != null;
  bool get _isSlideshow =>
      _slideshowFiles != null && _slideshowFiles!.isNotEmpty;
  bool get _hasSelectableMedia => _hasVideo || _isSlideshow;
  bool get _hasPostDetails =>
      _hasSelectableMedia && _selectedSubject.isNotEmpty;

  /// Title for the hoisted top bar when embedded in the create hub (matches course header row).
  String get _embeddedGlassTitle {
    if (_hasSelectableMedia && _showPostDetails) {
      return _isSlideshow ? 'New slideshow' : 'New video';
    }
    return 'Create';
  }

  void _syncCreateFlowSubStep() {
    if (!widget.embeddedInCreateFlow || _createFlow == null) return;
    if (!_hasSelectableMedia) {
      _createFlow!.setVideoSubStep(0);
    } else {
      _createFlow!.setVideoSubStep(_showPostDetails ? 1 : 0);
    }
  }

  void _snapshotDraftToFlow() {
    if (!widget.embeddedInCreateFlow || _createFlow == null) return;
    _createFlow!.snapshotVideoDraft(
      videoPath: _selectedFile?.path,
      slidePaths: _slideshowFiles?.map((f) => f.path).toList(),
      caption: _captionController.text,
      subject: _selectedSubject,
    );
  }

  bool _handleEmbeddedAndroidBack() {
    if (_hasSelectableMedia && _showPostDetails) {
      _backFromDetailsToPick();
      return true;
    }
    return false;
  }

  void _backFromDetailsToPick() {
    _previewController?.pause();
    setState(() => _showPostDetails = false);
    _syncCreateFlowSubStep();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _snapshotDraftToFlow();
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.embeddedInCreateFlow && Get.isRegistered<CreateFlowController>()) {
      _createFlow = Get.find<CreateFlowController>();
      _createFlow!.onVideoEmbeddedBack = _handleEmbeddedAndroidBack;
      _captionController.text = _createFlow!.persistedCaption.value;
      _selectedSubject = _createFlow!.persistedSubject.value;
      final vp = _createFlow!.persistedVideoPath.value;
      final slides = _createFlow!.persistedSlidePaths.toList();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (vp != null && File(vp).existsSync()) {
          final openDetails =
              _createFlow!.persistedCaption.value.trim().isNotEmpty;
          await _loadSelectedVideo(
            File(vp),
            advanceToDetails: openDetails,
          );
        } else if (slides.isNotEmpty) {
          final files = slides.where((p) => File(p).existsSync()).map(File.new).toList();
          if (files.isNotEmpty) {
            await _previewController?.dispose();
            if (!mounted) return;
            setState(() {
              _slideshowFiles = files;
              _selectedFile = null;
              _previewController = null;
              _thumbnailBytes = null;
              _showPostDetails = false;
            });
          }
        }
        _syncCreateFlowSubStep();
      });
    }
    _captionController.addListener(() {
      if (mounted) setState(() {});
      if (_createFlow != null) _snapshotDraftToFlow();
    });
  }

  @override
  void dispose() {
    if (widget.embeddedInCreateFlow && _createFlow != null) {
      if (_createFlow!.onVideoEmbeddedBack == _handleEmbeddedAndroidBack) {
        _createFlow!.onVideoEmbeddedBack = null;
      }
    }
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

  Future<void> _pickSlideshow() async {
    final picks = await _picker.pickMultiImage(imageQuality: 92);
    if (picks.isEmpty) return;
    if (picks.length > 20) {
      Get.snackbar('Slideshow', 'Pick up to 20 photos at once.');
      return;
    }
    await _previewController?.dispose();
    if (!mounted) return;
    setState(() {
      _slideshowFiles = picks.map((x) => File(x.path)).toList();
      _selectedFile = null;
      _previewController = null;
      _thumbnailBytes = null;
      _showPostDetails = true;
    });
    _syncCreateFlowSubStep();
    _snapshotDraftToFlow();
  }

  Future<void> _loadSelectedVideo(
    File file, {
    bool advanceToDetails = true,
  }) async {
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
      _slideshowFiles = null;
      _selectedFile = file;
      _previewController = previewController;
      _thumbnailBytes = null;
      _showPostDetails = advanceToDetails;
    });
    _syncCreateFlowSubStep();
    _snapshotDraftToFlow();

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
      _slideshowFiles = null;
      _previewController = null;
      _thumbnailBytes = null;
      _showPostDetails = false;
    });
    _syncCreateFlowSubStep();
    _snapshotDraftToFlow();
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
    final slides = _slideshowFiles;
    final caption = _captionController.text;
    final subject = _selectedSubject;
    final existingThumbnailBytes = _thumbnailBytes;

    if (subject.isEmpty) return;
    if (!_hasVideo && !_isSlideshow) return;

    _videoController.isPreparingVideoPost.value = true;
    Get.find<NavigationController>().updateIndex(2);
    if (widget.embeddedInCreateFlow && Get.isRegistered<CreateFlowController>()) {
      Get.find<CreateFlowController>().discard();
    } else {
      Get.back<void>();
    }

    () async {
      try {
        _videoController.isPreparingVideoPost.value = false;
        bool success;
        if (_isSlideshow && slides != null) {
          success = await _videoController.uploadSlideshow(
            imageFiles: List<File>.from(slides),
            caption: caption,
            subject: subject,
          );
          if (success) {
            Get.snackbar('Posted', 'Your slideshow is live on your profile.');
          }
        } else if (file != null) {
          final thumbnailBytes =
              existingThumbnailBytes ?? await _createFirstFrameThumbnail(file);
          success = await _videoController.uploadVideo(
            file: file,
            caption: caption,
            subject: subject,
            thumbnailBytes: thumbnailBytes,
          );
          if (success) {
            Get.snackbar('Posted', 'Your video is live on your profile.');
          }
        } else {
          success = false;
        }
      } catch (e) {
        Get.snackbar('Upload', 'Failed to publish: $e');
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
            _snapshotDraftToFlow();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildVideoStepSwitcher() {
    final hideInnerTopBar = widget.embeddedInCreateFlow;

    final pickChild = _PickVideoView(
      key: const ValueKey('pick'),
      showGlassTopBar: !hideInnerTopBar,
      onClose: widget.embeddedInCreateFlow
          ? _onEmbeddedPickClose
          : () => Get.back<void>(),
      onPickVideo: _pickVideo,
      onPickSlideshow: _pickSlideshow,
    );

    final detailsChild = _PostDetailsView(
      key: const ValueKey('details'),
      showGlassTopBar: !hideInnerTopBar,
      previewController: _previewController,
      slideshowFiles: _slideshowFiles,
      captionController: _captionController,
      captionLength: _captionController.text.length,
      selectedSubject: _selectedSubject,
      thumbnailBytes: _thumbnailBytes,
      isGeneratingThumbnail: _isGeneratingThumbnail,
      readyForPublish: _hasPostDetails,
      onClose: widget.embeddedInCreateFlow
          ? _backFromDetailsToPick
          : _clearVideo,
      onPickSubject: _showSubjectPicker,
      onPublish: _publish,
      onTogglePlayback: _togglePreviewPlayback,
    );

    final stepChild = _hasSelectableMedia && _showPostDetails
        ? detailsChild
        : pickChild;

    final switcher = AnimatedSwitcher(
      duration: kCreateFlowFadeDuration,
      switchInCurve: kCreateFlowFadeCurve,
      switchOutCurve: kCreateFlowFadeCurve,
      transitionBuilder: (child, animation) {
        return RepaintBoundary(
          child: kCreateFlowFadeTransition(child, animation),
        );
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: stepChild,
    );

    if (widget.embeddedInCreateFlow &&
        Get.isRegistered<CreateFlowController>()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: _GlassTopBar(
                  onClose: _hasSelectableMedia && _showPostDetails
                      ? _backFromDetailsToPick
                      : _onEmbeddedPickClose,
                  title: _embeddedGlassTitle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const _EmbeddedCreateVideoStepHeader(),
          Expanded(child: switcher),
        ],
      );
    }

    return switcher;
  }

  Future<void> _onEmbeddedPickClose() async {
    if (!widget.embeddedInCreateFlow) return;
    final flow = Get.find<CreateFlowController>();
    if (_hasSelectableMedia) {
      final ok = await showGlassConfirmDialog(
            context,
            title: 'Leave this step?',
            body:
                'Your selected video or photos will be cleared if you return to the create menu.',
            cancelText: 'Stay here',
            confirmText: 'Go back',
          ) ??
          false;
      if (!ok || !mounted) return;
      _clearVideo();
    }
    flow.goToTypeChoice();
  }

  @override
  Widget build(BuildContext context) {
    final standaloneBody = Stack(
      fit: StackFit.expand,
      children: [
        const LumiCosmicBackdrop(),
        SafeArea(child: _buildVideoStepSwitcher()),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      // Embedded: keyboard overlays the bottom. Caption step adds scroll slack
      // only inside [_PostDetailsView] so fields can scroll up.
      resizeToAvoidBottomInset: !widget.embeddedInCreateFlow,
      body: widget.embeddedInCreateFlow
          ? Builder(
              builder: (context) {
                final navReserve = createFlowContentBottomInset(context);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    const Positioned.fill(child: LumiCosmicBackdrop()),
                    Padding(
                      padding: EdgeInsets.only(bottom: navReserve),
                      child: SafeArea(
                        bottom: false,
                        child: _buildVideoStepSwitcher(),
                      ),
                    ),
                  ],
                );
              },
            )
          : standaloneBody,
    );
  }
}

// ---------------------------------------------------------------------------
// Embedded create flow — step block matches course step indicator spacing
// (56px header → 4px gap → same horizontal margins as CourseStepIndicator).
// ---------------------------------------------------------------------------

class _EmbeddedCreateVideoStepHeader extends StatelessWidget {
  const _EmbeddedCreateVideoStepHeader();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only depend on [videoSubStep]. Do not gate on [shellPage]: when leaving
      // the video flow, [shellPage] becomes 0 before [AnimatedSwitcher] finishes
      // fading this screen out, which used to hide the step strip one beat early.
      final sub = Get.find<CreateFlowController>().videoSubStep.value;
      final dim = Colors.white.withValues(alpha: 0.28);
      final label = sub == 0 ? 'Step 2 — Media' : 'Step 3 — Publish';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: sub >= 1 ? Colors.white : dim,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.25,
              ),
            ),
          ],
        ),
      );
    });
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
    required this.onPickSlideshow,
    this.showGlassTopBar = true,
  });

  final VoidCallback onClose;
  final VoidCallback onPickVideo;
  final VoidCallback onPickSlideshow;
  /// When false, the parent (embedded create hub) draws the top bar above the step strip.
  final bool showGlassTopBar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, showGlassTopBar ? 6 : 0, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showGlassTopBar) ...[
            _GlassTopBar(
              onClose: onClose,
              title: 'Create',
            ),
            const SizedBox(height: 22),
          ],
          const Text(
            'Video or photo slideshow',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Upload a clip, or pick several photos for a swipeable slideshow '
            'on the feed — then add subject and caption.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _VerticalMediaOption(
                  icon: Icons.video_library_rounded,
                  title: 'Upload video',
                  subtitle: 'One clip from your library',
                  onTap: onPickVideo,
                ),
                const SizedBox(height: 18),
                _VerticalMediaOption(
                  icon: Icons.collections_rounded,
                  title: 'Photo slideshow',
                  subtitle: 'Choose 2–20 photos',
                  onTap: onPickSlideshow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalMediaOption extends StatelessWidget {
  const _VerticalMediaOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 14.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.38),
                size: 28,
              ),
            ],
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
    this.slideshowFiles,
    required this.captionController,
    required this.captionLength,
    required this.selectedSubject,
    required this.thumbnailBytes,
    required this.isGeneratingThumbnail,
    required this.readyForPublish,
    required this.onClose,
    required this.onPickSubject,
    required this.onPublish,
    required this.onTogglePlayback,
    this.showGlassTopBar = true,
  });

  final VideoPlayerController? previewController;
  final List<File>? slideshowFiles;
  final TextEditingController captionController;
  final int captionLength;
  final String selectedSubject;
  final Uint8List? thumbnailBytes;
  final bool isGeneratingThumbnail;
  /// Subject (and media) ready; combined with upload state inside [Obx] for publish.
  final bool readyForPublish;
  final VoidCallback onClose;
  final VoidCallback onPickSubject;
  final VoidCallback onPublish;
  final VoidCallback onTogglePlayback;
  /// When false, embedded create hub draws the top bar above the step strip.
  final bool showGlassTopBar;

  @override
  Widget build(BuildContext context) {
    final isSlideshow =
        slideshowFiles != null && slideshowFiles!.isNotEmpty;
    final kb = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, showGlassTopBar ? 8 : 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showGlassTopBar) ...[
            _GlassTopBar(
              onClose: onClose,
              title: isSlideshow ? 'New slideshow' : 'New video',
            ),
            const SizedBox(height: 14),
          ],
          if (isSlideshow)
            _SlideshowPreviewCard(files: slideshowFiles!)
          else
            _VideoPreviewCard(
              controller: previewController,
              thumbnailBytes: thumbnailBytes,
              isGenerating: isGeneratingThumbnail,
              onTogglePlayback: onTogglePlayback,
            ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: EdgeInsets.only(bottom: kb + 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                    child: Obx(() {
                      final vc = Get.find<VideoController>();
                      final uploading = vc.isUploading.value;
                      final uploadStatus = vc.uploadStatus.value;
                      final canPublish = readyForPublish && !uploading;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _GlassCaptionField(
                            controller: captionController,
                            enabled: !uploading,
                            length: captionLength,
                          ),
                          const SizedBox(height: 12),
                          _SubjectSelector(
                            subject: selectedSubject,
                            onTap: uploading ? null : onPickSubject,
                          ),
                          if (uploading) ...[
                            const SizedBox(height: 18),
                            _UploadProgress(label: uploadStatus),
                          ],
                          const SizedBox(height: 18),
                          _PostButton(
                            isUploading: uploading,
                            canPublish: canPublish,
                            onTap: onPublish,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideshowPreviewCard extends StatelessWidget {
  const _SlideshowPreviewCard({required this.files});

  final List<File> files;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
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
                  PageView.builder(
                    itemCount: files.length,
                    itemBuilder: (_, i) => Image.file(
                      files[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Text(
                      '${files.length} photos · swipe to preview',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                          ),
                        ],
                      ),
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
                scrollPadding: EdgeInsets.zero,
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
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: Colors.white.withValues(alpha: 0.88),
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
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.85),
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.75),
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
