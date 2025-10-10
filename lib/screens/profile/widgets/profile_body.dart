import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/auth_controller.dart';
import 'package:share/share.dart';
import '../components/pfp_viewer.dart';
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
  bool showTooltip = false;

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
  }

  void toggleEditMode(bool enable) {
    widget.onEditModeChange(enable);
    if (enable) {
      setState(() {
        showTooltip = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => showTooltip = false);
        }
      });
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
                            offsetUp: -120,
                            isEditing: widget.isEditingPfp,
                            selectedIndex: selectedAvatarId -
                                1, // convert 1-based to 0-based
                            onEditModeChange: toggleEditMode,
                            onAvatarChanged: (int newId) {
                              setState(() {
                                selectedAvatarId = newId;
                              });
                            },
                            onDone: () async {
                              toggleEditMode(false);
                              final currentPfpId = int.tryParse(
                                    authController
                                            .firebaseUser.value?.photoURL ??
                                        '',
                                  ) ??
                                  1;
                              if (selectedAvatarId != currentPfpId) {
                                await authController
                                    .updateProfilePicture(selectedAvatarId);
                              }
                            },
                          ),
                        ),
                        AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.only(
                              top: widget.isEditingPfp ? 120 : 0),
                          child: Stack(
                            children: [
                              IgnorePointer(
                                ignoring: widget.isEditingPfp,
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A1A),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: greyBorder, width: 0.8),
                                          ),
                                          padding: const EdgeInsets.only(
                                              top: 16, left: 16, right: 16),
                                          child: Column(
                                            children: [
                                              Obx(() {
                                                final name =
                                                    authController.name.value;
                                                if (!isEditingName) {
                                                  return Text(
                                                    name,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      letterSpacing: -1,
                                                      height: 1.2,
                                                    ),
                                                  );
                                                } else {
                                                  nameController.text = name;
                                                  return Center(
                                                    child: Container(
                                                      height: 32,
                                                      alignment:
                                                          Alignment.center,
                                                      child: TextField(
                                                        controller:
                                                            nameController,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          letterSpacing: -1,
                                                          height: 1.2,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        cursorColor:
                                                            Colors.white,
                                                        autofocus: true,
                                                        maxLines: 1,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        onSubmitted:
                                                            (value) async {
                                                          final newName =
                                                              value.trim();
                                                          if (newName
                                                                  .isNotEmpty &&
                                                              newName !=
                                                                  authController
                                                                      .name
                                                                      .value) {
                                                            await authController
                                                                .updateDisplayName(
                                                                    newName);
                                                          }
                                                          setState(() =>
                                                              isEditingName =
                                                                  false);
                                                        },
                                                        onTapOutside: (event) {
                                                          // Reset to original name and exit editing mode
                                                          nameController.text =
                                                              authController
                                                                  .name.value;
                                                          setState(() =>
                                                              isEditingName =
                                                                  false);
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              InputBorder.none,
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
                                                    authController.firebaseUser
                                                            .value?.email ??
                                                        'error',
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  )),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
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
                                                        () =>
                                                            const FriendsScreen(),
                                                        transition:
                                                            Transition.fadeIn,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    250),
                                                        curve: Curves.easeInOut,
                                                      );
                                                    },
                                                    child: InfoStatCard(
                                                      label: 'Friends',
                                                      value: authController
                                                          .friendCount
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
                                                setState(
                                                    () => isEditingName = true);
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
                                            duration: const Duration(
                                                milliseconds: 250),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        icon: const Icon(Icons.person_add_alt,
                                            size: 24, color: Color(0xFFB388FF)),
                                        label: const Text(
                                          'ADD FRIENDS',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
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
                                              value: authController
                                                  .streakCount.value
                                                  .toString()),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: InfoStatCard(
                                              icon: Icons.star,
                                              label: 'Total Stars',
                                              value: authController
                                                  .xpCount.value
                                                  .toString()),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.isEditingPfp)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.75),
                                  ),
                                ),
                            ],
                          ),
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
