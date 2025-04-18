import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/constants.dart';
import 'package:lumi_learn_app/controllers/friends_controller.dart';
import 'package:lumi_learn_app/screens/profile/components/info_stat_card.dart';
import 'package:lumi_learn_app/screens/social/components/pfp_viewer.dart';
import 'package:lumi_learn_app/screens/social/components/xp_chart_box.dart';

class FriendProfile extends StatelessWidget {
  const FriendProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final FriendsController controller = Get.find<FriendsController>();

    return Obx(() {
      final friend = controller.activeFriend.value;
      if (friend == null) {
        // While waiting for the active friend to load, show a loading indicator.
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 🌌 Galaxy header background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/galaxies/galaxyDefault.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 👇 Scrollable body content
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 0, left: 16, right: 16),
              child: Column(
                children: [
                  const Center(
                    child: PfpViewer(
                      offsetUp: -120,
                      backgroundImage: AssetImage('assets/pfp/pfp1.png'),
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
                    // Read our state variable from the controller
                    final String requestStatus =
                        controller.friendRequestStatus.value;

                    // Set the button text: if already a friend, 'Friends'; if a request is pending, 'Pending'; else 'Send Request'
                    final String buttonText = alreadyFriend
                        ? 'Friends'
                        : requestStatus != 'none'
                            ? 'Pending'
                            : 'Send Request';

                    // Set the button icon based on the state.
                    final Icon buttonIcon = alreadyFriend
                        ? const Icon(Icons.check_circle,
                            size: 24, color: Colors.greenAccent)
                        : requestStatus != 'none'
                            ? const Icon(Icons.hourglass_top,
                                size: 24, color: Colors.orangeAccent)
                            : const Icon(Icons.person_add_alt,
                                size: 24, color: Color(0xFFB388FF));

                    // Disable the button if already friends or if there's a pending request.
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
                                  // Optionally refresh the request status after sending.
                                } catch (e) {
                                  // Optionally handle errors here.
                                }
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

                  // Stats row
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

                  // const SizedBox(height: 20),

                  // // XP Chart
                  // const XPChartBox(),

                  // const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
