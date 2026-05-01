import 'dart:io';

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
      if (mounted) {
        setState(() => _isGeneratingThumbnail = false);
      }
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

  Future<void> _publish() async {
    final file = _selectedFile;
    final caption = _captionController.text;
    final subject = _selectedSubject;
    final existingThumbnailBytes = _thumbnailBytes;

    if (file == null || subject.isEmpty) {
      return;
    }

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
          Get.snackbar('Video Published', 'Your video is now on your profile.');
        }
      } catch (e) {
        Get.snackbar('Video Upload', 'Failed to publish video: $e');
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
      backgroundColor: _hasVideo ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: _hasVideo ? Colors.white : Colors.black,
        foregroundColor: _hasVideo ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(_hasVideo ? 'Post details' : 'Create video'),
        leading: _hasVideo
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _thumbnailBytes = null;
                  });
                  _previewController?.dispose();
                  _previewController = null;
                },
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: SafeArea(
        child: Obx(() {
          final isUploading = _videoController.isUploading.value;
          final uploadStatus = _videoController.uploadStatus.value;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              if (!_hasVideo)
                _PickVideoStep(onPickVideo: _pickVideo)
              else
                _PostDetailsStep(
                  previewController: _previewController,
                  captionController: _captionController,
                  selectedSubject: _selectedSubject,
                  thumbnailBytes: _thumbnailBytes,
                  isGeneratingThumbnail: _isGeneratingThumbnail,
                  isUploading: isUploading,
                  uploadStatus: uploadStatus,
                  canPublish: _hasPostDetails && !isUploading,
                  onPickSubject: isUploading ? null : _showSubjectPicker,
                  onPublish: _publish,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _PickVideoStep extends StatelessWidget {
  const _PickVideoStep({required this.onPickVideo});

  final VoidCallback onPickVideo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your video',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Start by selecting the clip. Next you will add a caption and subject. The cover is set from the first frame.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 15,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onPickVideo,
          child: AspectRatio(
            aspectRatio: 9 / 13,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file_outlined,
                    color: Color(0xFFB79CFF),
                    size: 58,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Upload a video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Choose an existing clip from your device.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PostDetailsStep extends StatelessWidget {
  const _PostDetailsStep({
    required this.previewController,
    required this.captionController,
    required this.selectedSubject,
    required this.thumbnailBytes,
    required this.isGeneratingThumbnail,
    required this.isUploading,
    required this.uploadStatus,
    required this.canPublish,
    required this.onPickSubject,
    required this.onPublish,
  });

  final VideoPlayerController? previewController;
  final TextEditingController captionController;
  final String selectedSubject;
  final Uint8List? thumbnailBytes;
  final bool isGeneratingThumbnail;
  final bool isUploading;
  final String uploadStatus;
  final bool canPublish;
  final VoidCallback? onPickSubject;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: captionController,
                enabled: !isUploading,
                maxLength: 2200,
                maxLines: 7,
                minLines: 5,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Add description...',
                  hintStyle: TextStyle(
                    color: Color(0xFFB7B7B7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  counterText: '',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: 6),
                ),
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 132,
              child: _ThumbnailPreview(
                previewController: previewController,
                thumbnailBytes: thumbnailBytes,
                isGenerating: isGeneratingThumbnail,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SubjectSelector(
          selectedSubject: selectedSubject,
          onTap: onPickSubject,
        ),
        const SizedBox(height: 220),
        if (isUploading) ...[
          const LinearProgressIndicator(color: Color(0xFFFF2D55)),
          const SizedBox(height: 10),
          Text(
            uploadStatus,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canPublish ? onPublish : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D55),
              disabledBackgroundColor: const Color(0xFFE8E8E8),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.black38,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(isUploading ? 'Posting...' : 'Post'),
          ),
        ),
      ],
    );
  }
}

class _ThumbnailPreview extends StatelessWidget {
  const _ThumbnailPreview({
    required this.previewController,
    required this.thumbnailBytes,
    required this.isGenerating,
  });

  final VideoPlayerController? previewController;
  final Uint8List? thumbnailBytes;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 9 / 13,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailBytes != null)
                  Image.memory(thumbnailBytes!, fit: BoxFit.cover)
                else if (previewController != null &&
                    previewController!.value.isInitialized)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: previewController!.value.size.width,
                      height: previewController!.value.size.height,
                      child: VideoPlayer(previewController!),
                    ),
                  )
                else
                  const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white54,
                      size: 42,
                    ),
                  ),
                if (isGenerating)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.42),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB79CFF),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({
    required this.selectedSubject,
    required this.onTap,
  });

  final String selectedSubject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFEFEFEF)),
            bottom: BorderSide(color: Color(0xFFEFEFEF)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              const Icon(Icons.school_outlined, color: Colors.black, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  selectedSubject.isEmpty ? 'Subject' : selectedSubject,
                  style: TextStyle(
                    color: selectedSubject.isEmpty
                        ? Colors.black
                        : const Color(0xFFFF2D55),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9C9C9C)),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final subjects = _filteredSubjects;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF101010),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose subject',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => setState(() => _query = value),
            decoration: _fieldDecoration(hintText: 'Search subjects'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: subjects.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final isSelected = subject == widget.selectedSubject;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFFB79CFF))
                      : null,
                  onTap: () => widget.onSelected(subject),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({required String hintText}) {
  return InputDecoration(
    counterStyle: TextStyle(
      color: Colors.white.withValues(alpha: 0.48),
    ),
    hintText: hintText,
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
  );
}
