import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import '../components/pfp_viewer.dart';
import '../components/info_stat_card.dart';
import '../components/xp_chart_box.dart';
import 'package:lumi_learn_app/screens/settings/settings_screen.dart';
import 'package:lumi_learn_app/screens/social/friends_screen.dart';
import 'package:lumi_learn_app/controllers/navigation_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 768;
    final double topPadding = isTablet ? 50.0 : 0.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 40),
              child: Column(
                children: [
                  Center(
                    child: PfpViewer(
                      offsetUp: -120,
                      isEditing: widget.isEditingPfp,
                      onEditModeChange: toggleEditMode,
                    ),
                  ),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding:
                        EdgeInsets.only(top: widget.isEditingPfp ? 120 : 0),
                    child: Stack(
                      children: [
                        IgnorePointer(
                          ignoring: widget.isEditingPfp,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: greyBorder, width: 0.8),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 16, left: 16, right: 16),
                                child: Column(
                                  children: [
                                    Obx(() => Text(
                                          authController.firebaseUser.value
                                                  ?.displayName ??
                                              'User',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w300,
                                            letterSpacing: -1,
                                          ),
                                        )),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                          authController
                                                  .firebaseUser.value?.email ??
                                              'error',
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        )),
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
                                            Get.to(() => const FriendsScreen());
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
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.to(
                                      () => const AddFriendsScreen(),
                                      transition: Transition.rightToLeft,
                                      duration:
                                          const Duration(milliseconds: 300),
                                    );
                                  },
                                  icon: const Icon(Icons.person_add_alt,
                                      size: 24, color: Color(0xFFB388FF)),
                                  label: const Text(
                                    'ADD FRIENDS',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
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
                              const SizedBox(height: 20),
                              const XPChartBox(),
                              const SizedBox(height: 60),
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
                        color: widget.isEditingPfp ? Colors.grey : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isEditingPfp)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 104, right: 12),
                  child: TextButton(
                    onPressed: () => toggleEditMode(false),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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
