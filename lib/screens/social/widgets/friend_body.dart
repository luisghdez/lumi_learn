import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/screens/profile/components/info_stat_card.dart';
import 'package:lumi_learn_app/screens/social/components/pfp_viewer.dart';
import 'package:lumi_learn_app/screens/social/components/xp_chart_box.dart';

class FriendProfile extends StatelessWidget {
  const FriendProfile({super.key});

  bool hasNotch(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;
    return topInset > 20;
  }

  String getProfilePicturePath(String? profilePicture) {
    if (profilePicture == null ||
        profilePicture.isEmpty ||
        profilePicture == "default") {
      return 'assets/pfp/pfp1.png';
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
            // 🌌 Fullscreen Galaxy Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/black_moons_lighter.png',
                fit: BoxFit.cover,
              ),
            ),
            // 👇 Scrollable body content
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
              child: Column(
                children: [
                  Center(
                    child: PfpViewer(
                      offsetUp: -120,
                      backgroundImage: AssetImage(
                          getProfilePicturePath(friend.profilePicture)),
                    ),
                  ),
                  // Info box
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
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InfoStatCard(
                              label: 'Courses',
                              value: '${friend.courseSlotsUsed}',
                              background: false,
                            ),
                            const SizedBox(
                              height: 60,
                              child: VerticalDivider(
                                color: greyBorder,
                                thickness: 1,
                              ),
                            ),
                            InfoStatCard(
                              icon: Icons.people,
                              label: 'Friends',
                              value: '${friend.friendCount}',
                              background: false,
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
                    final bool isDisabled =
                        alreadyFriend || requestStatus != 'none';

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isDisabled
                            ? null
                            : () async {
                                try {
                                  await controller.sendFriendRequest(friend.id);
                                } catch (e) {}
                              },
                        icon: buttonIcon,
                        label: Text(
                          buttonText,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: alreadyFriend || requestStatus != 'none'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: InfoStatCard(
                            icon: Icons.rocket_launch,
                            label: 'Day streak',
                            value: friend.streakCount.toString()),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InfoStatCard(
                            icon: Icons.star,
                            label: 'Total Stars',
                            value: friend.xpCount.toString()),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Back button with notch handling
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
