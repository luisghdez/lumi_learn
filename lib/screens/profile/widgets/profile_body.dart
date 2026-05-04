import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:lumi_learn_app/application/controllers/video_controller.dart';
import 'package:share/share.dart';
import '../components/pfp_viewer.dart';
import '../components/pfp_gallery_screen.dart';
import '../components/info_stat_card.dart';
import 'package:lumi_learn_app/screens/settings/settings_screen.dart';
import 'package:lumi_learn_app/screens/social/friends_screen.dart';
import 'package:lumi_learn_app/application/controllers/navigation_controller.dart';
import 'package:lumi_learn_app/screens/social/widgets/saved_courses_list_screen.dart';
import 'package:lumi_learn_app/widgets/profile_videos_grid.dart';

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
  final ScrollController _scrollController = ScrollController();

  int selectedAvatarId = 1;
  Worker? _profileTabWorker;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    // Initialize selectedAvatarId once from the auth controller's photoURL.
    selectedAvatarId =
        int.tryParse(authController.firebaseUser.value?.photoURL ?? "0") ?? 1;
    // Refetch videos when the user switches to this tab so new posts appear
    // without leaving the app (e.g. after publishing from Create Video).
    _profileTabWorker = ever<int>(widget.navController.currentIndex, (idx) {
      if (idx == 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final userId = Get.find<AuthController>().firebaseUser.value?.uid;
          if (userId != null && Get.isRegistered<VideoController>()) {
            Get.find<VideoController>().fetchUserVideos(userId, refresh: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _profileTabWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sits between [RefreshIndicator] and [SingleChildScrollView] so scroll
  /// updates are seen before the indicator’s internal listener.
  bool _onProfileScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;
    final m = notification.metrics;
    if (!m.hasPixels || m.axis != Axis.vertical) return false;
    widget.navController.applyVerticalScrollForNavBar(
      pixels: m.pixels,
      minExtent: m.minScrollExtent,
      maxExtent: m.maxScrollExtent,
      scrollDelta: notification.scrollDelta ?? 0,
    );
    return false;
  }

  Future<void> _onPullToRefresh() async {
    final authController = Get.find<AuthController>();
    final userId = authController.firebaseUser.value?.uid;
    if (userId != null && Get.isRegistered<VideoController>()) {
      await Get.find<VideoController>().fetchUserVideos(userId, refresh: true);
    }
    await authController.fetchUserData();
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
                return RefreshIndicator(
                  color: const Color(0xFFB388FF),
                  onRefresh: _onPullToRefresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onProfileScrollNotification,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                  }),
                                  const SizedBox(height: 4),
                                  Obx(() => Text(
                                        authController
                                                .firebaseUser.value?.email ??
                                            'error',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                      )),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => const _EditUsernameScreen(),
                                        transition: Transition.cupertino,
                                        duration:
                                            const Duration(milliseconds: 260),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 13,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.08),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.10),
                                        ),
                                      ),
                                      child: Text(
                                        'Edit username',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.86),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(
                                            () => const SavedCoursesListScreen(
                                              forUserId: null,
                                            ),
                                            transition: Transition.fadeIn,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: InfoStatCard(
                                          label: 'Courses',
                                          value: authController.courseSlotsUsed
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
                            const SizedBox(height: 12),
                            Obx(() {
                              final uid =
                                  authController.firebaseUser.value?.uid;
                              if (uid == null) {
                                return const SizedBox.shrink();
                              }
                              return ProfileVideosGrid(
                                userId: uid,
                                showPendingUploadSlot: true,
                                scrollController: _scrollController,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
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

class _EditUsernameScreen extends StatefulWidget {
  const _EditUsernameScreen();

  @override
  State<_EditUsernameScreen> createState() => _EditUsernameScreenState();
}

class _EditUsernameScreenState extends State<_EditUsernameScreen> {
  late final TextEditingController _usernameController;
  late final String _initialUsername;
  final RxBool _isSaving = false.obs;

  static final RegExp _usernamePattern = RegExp(r'^[a-zA-Z0-9._]+$');

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    _initialUsername = authController.name.value.trim();
    _usernameController = TextEditingController(text: _initialUsername);
    _usernameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _isSaving.close();
    super.dispose();
  }

  String get _username => _usernameController.text.trim();

  bool get _isValidUsername {
    final username = _username;
    return username.length >= 3 &&
        username.length <= 24 &&
        _usernamePattern.hasMatch(username);
  }

  bool get _canSave =>
      _isValidUsername && _username != _initialUsername && !_isSaving.value;

  Future<void> _saveUsername() async {
    if (!_canSave) return;

    _isSaving.value = true;
    try {
      final didSave = await Get.find<AuthController>().updateDisplayName(
        _username,
        showSuccessMessage: false,
      );
      if (mounted && didSave) {
        Navigator.of(context).pop();
      }
    } finally {
      _isSaving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _username;
    final showValidation = username.isNotEmpty && !_isValidUsername;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0D),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Get.back(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _canSave ? _saveUsername : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 140),
                          style: TextStyle(
                            color: _canSave
                                ? const Color(0xFFFF4D7D)
                                : const Color(0xFFFF4D7D)
                                    .withValues(alpha: 0.28),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          child: Text(_isSaving.value ? 'Saving...' : 'Save'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 34, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Choose the name people see on your profile. Usernames can contain letters, numbers, underscores, and periods.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 16,
                        height: 1.28,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showValidation
                              ? const Color(0xFFFF4D7D)
                                  .withValues(alpha: 0.72)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              autofocus: true,
                              cursorColor: const Color(0xFFFF4D7D),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.done,
                              maxLength: 24,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9._]'),
                                ),
                              ],
                              onSubmitted: (_) => _saveUsername(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.2,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 14),
                              ),
                            ),
                          ),
                          if (_usernameController.text.isNotEmpty)
                            GestureDetector(
                              onTap: _usernameController.clear,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Icon(
                                  Icons.cancel_rounded,
                                  color:
                                      Colors.white.withValues(alpha: 0.38),
                                  size: 22,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            username.isEmpty
                                ? 'lumi.app/@username'
                                : 'lumi.app/@$username',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.42),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${username.length}/24',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.42),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (showValidation) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Use 3-24 letters, numbers, underscores, or periods.',
                        style: TextStyle(
                          color: Color(0xFFFF7A9B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

