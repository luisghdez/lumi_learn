import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:lumi_learn_app/application/models/video_model.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import '../components/pfp_viewer.dart';
import '../components/pfp_gallery_screen.dart';
import '../components/info_stat_card.dart';
import 'package:lumi_learn_app/screens/settings/settings_screen.dart';
import 'package:lumi_learn_app/screens/social/friends_screen.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/social/screen/add_friends_screen.dart';

class ProfileBody extends StatefulWidget {
  final bool isEditingPfp;
  final Function(bool) onEditModeChange;
  final NavigationController navController;

  const ProfileBody({
    super.key,
    required this.isEditingPfp,
    required this.onEditModeChange,
    required this.navController,
  });

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool isEditingName = false;
  TextEditingController nameController = TextEditingController();

  int selectedAvatarId = 1;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    // Initialize selectedAvatarId once from the auth controller's photoURL.
    selectedAvatarId =
        int.tryParse(authController.firebaseUser.value?.photoURL ?? "0") ?? 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = authController.firebaseUser.value?.uid;
      if (userId != null && Get.isRegistered<VideoController>()) {
        Get.find<VideoController>().fetchUserVideos(userId);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void toggleEditMode(bool enable) {
    if (enable) {
      // Open the pfp gallery screen
      Get.to(
        () => PfpGalleryScreen(
          selectedIndex: selectedAvatarId,
          onAvatarSelected: (int newId) async {
            setState(() {
              selectedAvatarId = newId;
            });

            final authController = Get.find<AuthController>();
            final currentPfpId = int.tryParse(
                  authController.firebaseUser.value?.photoURL ?? '',
                ) ??
                1;

            if (selectedAvatarId != currentPfpId) {
              await authController.updateProfilePicture(selectedAvatarId);
            }
          },
        ),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  bool hasNotch(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    // You can tweak this threshold.
    // iPhones with a notch are typically 44px or more.
    return topInset > 20;
  }

  void _shareProfileLink() {
    final authController = Get.find<AuthController>();
    final user = authController.firebaseUser.value;
    if (user != null) {
      final link = "https://www.lumilearnapp.com/invite/${user.uid}";
      Share.share("Follow ${authController.name.value} on Lumi Learn! $link");
    } else {
      Get.snackbar("Not Logged In", "Sign in to share your profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final bool deviceHasNotch = hasNotch(context);

    final double topPadding = isTablet ? 50.0 : (deviceHasNotch ? 0.0 : 20.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    MediaQuery.of(context).viewInsets.bottom + 40,
                  ),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        Center(
                          child: PfpViewer(
                            offsetUp: -70,
                            isEditing: false,
                            selectedIndex: selectedAvatarId -
                                1, // convert 1-based to 0-based
                            onEditModeChange: toggleEditMode,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: greyBorder, width: 0.8),
                                  ),
                                  padding: const EdgeInsets.only(
                                      top: 16, left: 16, right: 16),
                                  child: Column(
                                    children: [
                                      Obx(() {
                                        final name = authController.name.value;
                                        if (!isEditingName) {
                                          return Text(
                                            name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: -1,
                                              height: 1.2,
                                            ),
                                          );
                                        } else {
                                          nameController.text = name;
                                          return Center(
                                            child: Container(
                                              height: 32,
                                              alignment: Alignment.center,
                                              child: TextField(
                                                controller: nameController,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w300,
                                                  letterSpacing: -1,
                                                  height: 1.2,
                                                ),
                                                textAlign: TextAlign.center,
                                                cursorColor: Colors.white,
                                                autofocus: true,
                                                maxLines: 1,
                                                textInputAction:
                                                    TextInputAction.done,
                                                onSubmitted: (value) async {
                                                  final newName = value.trim();
                                                  if (newName.isNotEmpty &&
                                                      newName !=
                                                          authController
                                                              .name.value) {
                                                    await authController
                                                        .updateDisplayName(
                                                            newName);
                                                  }
                                                  setState(() =>
                                                      isEditingName = false);
                                                },
                                                onTapOutside: (event) {
                                                  // Reset to original name and exit editing mode
                                                  nameController.text =
                                                      authController.name.value;
                                                  setState(() =>
                                                      isEditingName = false);
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                      const SizedBox(height: 4),
                                      Obx(() => Text(
                                            authController.firebaseUser.value
                                                    ?.email ??
                                                'error',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                          )),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: InfoStatCard(
                                              label: 'Courses',
                                              value: authController
                                                  .courseSlotsUsed
                                                  .toString(),
                                              background: false,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 60,
                                            child: VerticalDivider(
                                              color: greyBorder,
                                              thickness: 1,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => const FriendsScreen(),
                                                transition: Transition.fadeIn,
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: InfoStatCard(
                                              label: 'Friends',
                                              value: authController.friendCount
                                                  .toString(),
                                              background: false,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                if (!isEditingName)
                                  Positioned(
                                    top: 8,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() => isEditingName = true);
                                      },
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white54,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Get.to(
                                    () => const AddFriendsScreen(),
                                    transition: Transition.fadeIn,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: const Icon(Icons.person_add_alt,
                                    size: 24, color: Color(0xFFB388FF)),
                                label: const Text(
                                  'ADD FRIENDS',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: InfoStatCard(
                                      icon: Icons.rocket_launch,
                                      label: 'Day streak',
                                      value: authController.streakCount.value
                                          .toString()),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InfoStatCard(
                                      icon: Icons.star,
                                      label: 'Total Stars',
                                      value: authController.xpCount.value
                                          .toString()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const _ProfileVideosSection(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, left: 16),
                  child: AbsorbPointer(
                    absorbing: widget.isEditingPfp,
                    child: GestureDetector(
                      onTap: _shareProfileLink,
                      child: Icon(
                        Icons.share,
                        color: widget.isEditingPfp
                            ? const Color.fromARGB(63, 158, 158, 158)
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, right: 16),
                  child: AbsorbPointer(
                    absorbing: widget.isEditingPfp,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => const SettingsScreen());
                      },
                      child: Icon(
                        Icons.settings,
                        color: widget.isEditingPfp
                            ? const Color.fromARGB(63, 158, 158, 158)
                            : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileVideosSection extends StatelessWidget {
  const _ProfileVideosSection();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final videoController = Get.find<VideoController>();
    final userId = authController.firebaseUser.value?.uid;

    if (userId == null) return const SizedBox.shrink();

    return Obx(() {
      final videos = videoController.userVideosByUserId[userId] ?? [];
      final isLoading =
          videoController.loadingUserVideosByUserId[userId] == true;
      final hasPendingVideo = videoController.hasPendingVideoPost;
      final tileCount = videos.length + (hasPendingVideo ? 1 : 0);

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: greyBorder, width: 0.8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Videos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFB388FF),
                    ),
                  )
                else
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => videoController.fetchUserVideos(userId),
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (videos.isEmpty && !isLoading && !hasPendingVideo)
              const _EmptyProfileVideos()
            else
              GridView.builder(
                itemCount: tileCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 9 / 14,
                ),
                itemBuilder: (context, index) {
                  if (hasPendingVideo && index == 0) {
                    return const _UploadingVideoTile();
                  }
                  final videoIndex = hasPendingVideo ? index - 1 : index;
                  return _ProfileVideoTile(video: videos[videoIndex]);
                },
              ),
          ],
        ),
      );
    });
  }
}

class _UploadingVideoTile extends StatelessWidget {
  const _UploadingVideoTile();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Colors.white.withValues(alpha: 0.08),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _VideoTileFallback(),
            ColoredBox(color: Colors.black.withValues(alpha: 0.46)),
            const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFFB388FF),
                ),
              ),
            ),
            const Positioned(
              left: 6,
              right: 6,
              bottom: 8,
              child: Text(
                'Posting...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileVideoTile extends StatelessWidget {
  const _ProfileVideoTile({required this.video});

  final VideoPost video;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => _ProfileVideoPreviewScreen(video: video),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 250),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
              Image.network(
                video.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _VideoTileVideoFrame(video: video),
              )
            else
              _VideoTileVideoFrame(video: video),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
            const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            if (video.subject.isNotEmpty)
              Positioned(
                left: 6,
                right: 6,
                top: 6,
                child: Text(
                  video.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    video.likeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTileFallback extends StatelessWidget {
  const _VideoTileFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A174B),
            Color(0xFF0B0B0B),
            Color(0xFF1E2F4A),
          ],
        ),
      ),
    );
  }
}

class _VideoTileVideoFrame extends StatefulWidget {
  const _VideoTileVideoFrame({required this.video});

  final VideoPost video;

  @override
  State<_VideoTileVideoFrame> createState() => _VideoTileVideoFrameState();
}

class _VideoTileVideoFrameState extends State<_VideoTileVideoFrame> {
  VideoPlayerController? _controller;
  bool _failedToLoadFrame = false;

  @override
  void initState() {
    super.initState();
    final playbackUrl = widget.video.playbackUrl;
    if (playbackUrl == null || playbackUrl.isEmpty) {
      _failedToLoadFrame = true;
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(playbackUrl));
    _controller = controller;
    controller.initialize().then((_) async {
      if (!mounted) return;
      await controller.seekTo(Duration.zero);
      await controller.pause();
      if (!mounted) return;
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      debugPrint('Unable to load profile video frame: $error');
      setState(() => _failedToLoadFrame = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failedToLoadFrame ||
        controller == null ||
        !controller.value.isInitialized) {
      return const _VideoTileFallback();
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _EmptyProfileVideos extends StatelessWidget {
  const _EmptyProfileVideos();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.movie_creation_outlined,
            color: Colors.white.withValues(alpha: 0.72),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'No videos yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Published videos will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.56),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileVideoPreviewScreen extends StatefulWidget {
  const _ProfileVideoPreviewScreen({required this.video});

  final VideoPost video;

  @override
  State<_ProfileVideoPreviewScreen> createState() =>
      _ProfileVideoPreviewScreenState();
}

class _ProfileVideoPreviewScreenState
    extends State<_ProfileVideoPreviewScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final playbackUrl = widget.video.playbackUrl;
    if (playbackUrl == null || playbackUrl.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(playbackUrl));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      controller
        ..setLooping(true)
        ..play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Video'),
      ),
      body: GestureDetector(
        onTap: _togglePlayback,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFB388FF)),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 36,
              child: Text(
                widget.video.caption,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
