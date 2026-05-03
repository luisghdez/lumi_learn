import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/screens/profile/components/info_stat_card.dart';
import 'package:lumi_learn_app/screens/social/components/pfp_viewer.dart';
import 'package:lumi_learn_app/screens/social/widgets/remove_friend_dialog.dart';
import 'package:lumi_learn_app/screens/social/widgets/saved_courses_list_screen.dart';
import 'package:lumi_learn_app/screens/social/widgets/user_friends_list_screen.dart';
import 'package:lumi_learn_app/widgets/profile_videos_grid.dart';

class FriendProfile extends StatefulWidget {
  const FriendProfile({super.key});

  @override
  State<FriendProfile> createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool hasNotch(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    return topInset > 20;
  }

  String getProfilePicturePath(String? profilePicture) {
    if (profilePicture == null ||
        profilePicture.isEmpty ||
        profilePicture == 'default') {
      return 'assets/pfp/pfp28.png';
    }
    return 'assets/pfp/pfp$profilePicture.png';
  }

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find<FriendsController>();
    final bool deviceHasNotch = hasNotch(context);
    final double topPadding = deviceHasNotch ? 0.0 : 20.0;

    return Obx(() {
      final friend = controller.activeFriend.value;
      if (friend == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/black_moons_lighter.png',
                fit: BoxFit.cover,
              ),
            ),
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
              child: Column(
                children: [
                  Center(
                    child: PfpViewer(
                      offsetUp: -70,
                      backgroundImage: AssetImage(
                        getProfilePicturePath(friend.profilePicture),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.8),
                    ),
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          friend.email,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => SavedCoursesListScreen(
                                    forUserId: friend.id,
                                    ownerDisplayName: friend.name,
                                  ),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: InfoStatCard(
                                label: 'Courses',
                                value: '${friend.courseSlotsUsed}',
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
                                  () => UserFriendsListScreen(
                                    userId: friend.id,
                                    ownerDisplayName: friend.name,
                                  ),
                                  transition: Transition.fadeIn,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: InfoStatCard(
                                icon: Icons.people,
                                label: 'Friends',
                                value: '${friend.friendCount}',
                                background: false,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final alreadyFriend = controller.isFriend(friend.id);
                    final String requestStatus =
                        controller.friendRequestStatus.value;
                    final String buttonText = alreadyFriend
                        ? 'Friends'
                        : requestStatus != 'none'
                            ? 'Pending'
                            : 'Send Request';
                    final Icon buttonIcon = alreadyFriend
                        ? const Icon(Icons.check_circle,
                            size: 24, color: Colors.greenAccent)
                        : requestStatus != 'none'
                            ? const Icon(Icons.hourglass_top,
                                size: 24, color: Colors.orangeAccent)
                            : const Icon(Icons.person_add_alt,
                                size: 24, color: Color(0xFFB388FF));
                    final bool pendingBlock =
                        requestStatus != 'none' && !alreadyFriend;

                    final ButtonStyle friendStyle = alreadyFriend
                        ? ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3D2F),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          )
                        : ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          );

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: pendingBlock
                            ? null
                            : () async {
                                if (alreadyFriend) {
                                  final ok = await showRemoveFriendDialog(
                                    context,
                                    displayName: friend.name,
                                  );
                                  if (ok && context.mounted) {
                                    await controller.removeFriend(friend.id);
                                  }
                                  return;
                                }
                                try {
                                  await controller
                                      .sendFriendRequest(friend.id);
                                } catch (error) {
                                  debugPrint(
                                    'Failed to send friend request: $error',
                                  );
                                }
                              },
                        icon: buttonIcon,
                        label: Text(
                          buttonText,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: friendStyle,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  ProfileVideosGrid(
                    userId: friend.id,
                    showPendingUploadSlot: false,
                    scrollController: _scrollController,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, left: 16),
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
