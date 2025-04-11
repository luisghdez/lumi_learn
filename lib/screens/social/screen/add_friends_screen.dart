import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:lumi_learn_app/controllers/auth_controller.dart';
import 'package:lumi_learn_app/controllers/friends_controller.dart';
import 'package:lumi_learn_app/screens/social/widgets/add_friends_tab.dart';
import 'package:lumi_learn_app/screens/social/widgets/friend_requests_tab.dart';
import 'package:lumi_learn_app/models/userSearch_model.dart';

class AddFriendsScreen extends StatefulWidget {
  const AddFriendsScreen({super.key});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;

  final RxBool _contactsPermissionGranted = false.obs;
  final FriendsController _friendsController = Get.find<FriendsController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkInitialPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _friendsController.getRequests();
    });
  }

  Future<void> _checkInitialPermission() async {
    final status = await Permission.contacts.status;
    _contactsPermissionGranted.value = status.isGranted;
  }

  Future<void> _checkContactsPermission() async {
    final status = await Permission.contacts.request();
    _contactsPermissionGranted.value = status.isGranted;

    Get.snackbar(
      status.isGranted ? "Permission Granted" : "Access Denied",
      status.isGranted
          ? "You can now access your contacts."
          : "Contacts permission is required to invite friends.",
    );
  }

  /// Search users by name or email
  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      Get.snackbar("Empty Field", "Please enter a name or email.");
      return;
    }

    await _friendsController.searchUsers(query);
    final List<UserSearchResult> results = _friendsController.searchResults;

    if (results.isEmpty) {
      Get.snackbar("No Results", "No users found with \"$query\".");
      return;
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
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
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
          Obx(() => AddFriendsTab(
                emailController: _searchController,
                onCheckContactsPermission: _checkContactsPermission,
                onShareLink: _shareFollowLink,
                contactsPermissionGranted: _contactsPermissionGranted.value,
                onSearch: _performSearch, // 👈 Hook up search logic
              )),
          const FriendRequestsTab(),
        ],
      ),
    );
  }
}
