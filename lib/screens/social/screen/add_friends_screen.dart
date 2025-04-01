import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/friends_controller.dart';
import 'package:lumi_learn_app/services/friends_service.dart';
import 'package:lumi_learn_app/screens/social/widgets/add_friends_tab.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_requests_tab.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool _contactsPermissionGranted = false;
  late final TabController _tabController;
  late final FriendsController _friendsController;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<FriendsService>()) {
      Get.put(FriendsService());
    }

    _friendsController = Get.put(FriendsController(service: Get.find()));
    _tabController = TabController(length: 2, vsync: this);

    _checkInitialPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _friendsController.getRequests();
    });
  }

  Future<void> _checkInitialPermission() async {
    final status = await Permission.contacts.status;
    setState(() {
      _contactsPermissionGranted = status.isGranted;
    });
  }

  Future<void> _checkContactsPermission() async {
    final status = await Permission.contacts.request();
    setState(() {
      _contactsPermissionGranted = status.isGranted;
    });

    if (status.isGranted) {
      Get.snackbar("Permission Granted", "You can now access your contacts.");
    } else {
      Get.snackbar(
        "Access Denied",
        "Contacts permission is required to invite friends.",
      );
    }
  }

  void _searchByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Empty Field", "Please enter an email to search.");
      return;
    }

    await _friendsController.searchFriends(email);

    if (_friendsController.friends.isEmpty) {
      Get.snackbar("No Results", "No users found with that email.");
    } else {
      Get.defaultDialog(
        title: "User Found",
        content: Column(
          children: _friendsController.friends
              .map((friend) => ListTile(
                    title: Text(friend.name ?? "No name",
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(friend.email ?? "",
                        style: const TextStyle(color: Colors.white54)),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _friendsController.sendFriendRequest(friend.id);
                        Get.back();
                        Get.snackbar("Request Sent",
                            "Friend request sent to ${friend.name ?? "user"}.");
                      },
                      child: const Text("Add"),
                    ),
                  ))
              .toList(),
        ),
        backgroundColor: Colors.black87,
      );
    }
  }

  void _shareFollowLink() {
    final user = AuthController.instance.firebaseUser.value;
    if (user != null) {
      final link = "https://lumilearn.app/user/${user.uid}";
      Share.share("Follow ${user.displayName ?? "me"} on Lumi Learn! $link");
    } else {
      Get.snackbar("Not Logged In", "Sign in to share your profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Add Friends',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Add Friends"),
            Tab(text: "Friend Requests"),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AddFriendsTab(
            emailController: _emailController,
            onCheckContactsPermission: _checkContactsPermission,
            onSearchByEmail: _searchByEmail,
            onShareLink: _shareFollowLink,
            contactsPermissionGranted: _contactsPermissionGranted,
          ),
          const FriendRequestsTab(),
        ],
      ),
    );
  }
}
