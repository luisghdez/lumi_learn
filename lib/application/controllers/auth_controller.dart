import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/application/controllers/course_controller.dart';
import 'package:lumi_learn_app/application/controllers/friends_controller.dart';
import 'package:lumi_learn_app/application/services/deeplink.dart';
import 'package:lumi_learn_app/screens/auth/auth_gate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumi_learn_app/application/services/api_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum UserRole { student, teacher }

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs; // Track loading state
  Rxn<UserRole> userRole = Rxn<UserRole>();

  /// Shown under login / sign-up fields (replaces snackbars).
  final RxString authFormError = ''.obs;

  void clearAuthFormError() {
    authFormError.value = '';
  }

  final RxBool hasCompletedOnboarding = false.obs;
  RxBool isAuthInitialized = false.obs;

  final RxString activeProductId = ''.obs;

  RxMap<String, dynamic> userDoc = <String, dynamic>{}.obs;
  RxInt streakCount = 0.obs;
  RxInt xpCount = 0.obs;
  RxInt courseSlotsUsed = 0.obs;
  RxInt maxCourseSlots = 2.obs;
  RxInt friendCount = 0.obs;
  RxString name = 'User'.obs;
  RxString timezone = ''.obs;

  RxBool isPremium = false.obs;
  RxString subscriptionPlanType = ''.obs; // 'monthly', 'yearly', or empty

  @override
  void onReady() {
    super.onReady();
    _auth.authStateChanges().listen((User? user) async {
      isAuthInitialized.value = false;
      firebaseUser.value = user;

      try {
        if (user != null) {
          // Link RevenueCat to Firebase user UID
          await Purchases.logIn(user.uid);
          await updateProStatus();

          await fetchUserData();
        } else {
          // Clear out userDoc when logged out
          userDoc.value = {};
        }
      } finally {
        isAuthInitialized.value = true;
      }
    });
  }

  Future<bool> checkIfUserIsPro() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final proEntitlement = customerInfo.entitlements.all['Pro'];
      final isActive = proEntitlement?.isActive ?? false;

      if (isActive && proEntitlement != null) {
        // Get the product identifier to determine plan type
        final productId = proEntitlement.productIdentifier.toLowerCase();

        // Determine if it's monthly or yearly based on product identifier
        if (productId.contains('month')) {
          subscriptionPlanType.value = 'monthly';
        } else if (productId.contains('year') || productId.contains('annual')) {
          subscriptionPlanType.value = 'yearly';
        } else {
          subscriptionPlanType.value = 'unknown';
        }
      } else {
        subscriptionPlanType.value = '';
      }

      return isActive;
    } catch (e) {
      subscriptionPlanType.value = '';
      return false;
    }
  }

  Future<void> updateProStatus() async {
    isPremium.value = await checkIfUserIsPro();
  }

  Future<void> fetchUserData() async {
    try {
      final token = await getIdToken();
      if (token == null) {
        return;
      }

      final userId = firebaseUser.value!.uid;
      final response =
          await ApiService.getUserData(token: token, userId: userId);
      final data = jsonDecode(response.body);
      final userData = data['user'] as Map<String, dynamic>? ?? {};
      final hasOnboardingField = userData.containsKey('hasCompletedOnboarding');
      if (!hasOnboardingField) {
        userData['hasCompletedOnboarding'] = true;
        data['user'] = userData;
      }

      userDoc.value = data;
      streakCount.value = userData['streakCount'] ?? 0;
      xpCount.value = userData['xpCount'] ?? 0;
      courseSlotsUsed.value = userData['courseSlotsUsed'] ?? 0;
      maxCourseSlots.value = userData['maxCourseSlots'] ?? 2;
      friendCount.value = userData['friendCount'] ?? 0;
      name.value = userData['name'] ?? '';
      hasCompletedOnboarding.value = hasOnboardingField
          ? userData['hasCompletedOnboarding'] == true
          : true;
      final serverTimezone = userData['timezone'] ?? '';

      // Get the current device timezone
      final currentTimezone = await getIanaTimezoneId();

      // If timezone is empty or different from current timezone, update it
      if (serverTimezone.isEmpty || serverTimezone != currentTimezone) {
        await ApiService.updateUserTimezone(token, currentTimezone);
        timezone.value = currentTimezone;
      } else {
        timezone.value = serverTimezone;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Login Method
  Future<void> login(String email, String password) async {
    clearAuthFormError();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _navigateToAuthGate();
    } catch (e) {
      authFormError.value = _authFailureMessage(e);
    }
  }

  // Google Sign-In Method
  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;
    clearAuthFormError();
    isLoading.value = true;
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the user cancels the sign-in, return early.
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Sign in with Firebase using the credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // If sign-in is successful, check Firestore doc
      if (userCredential.user != null) {
        final User user = userCredential.user!;

        final token = await getIdToken();
        if (token == null) {
          authFormError.value =
              'Couldn\'t complete Google sign-in. Please try again.';
          return;
        }

        // Get the user's timezone
        final timezone = await getIanaTimezoneId();

        await ApiService.ensureUserExists(
          token,
          email: user.email,
          name: user.displayName,
          profilePicture: "default",
          timezone: timezone,
        );
      }

      _navigateToAuthGate();
    } catch (e) {
      authFormError.value = _authFailureMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    if (isLoading.value) return;
    clearAuthFormError();
    isLoading.value = true;
    try {
      // Check if Apple Sign In is available on the current device.
      if (!await SignInWithApple.isAvailable()) {
        authFormError.value =
            'Sign in with Apple isn\'t available on this device.';
        isLoading.value = false;
        return;
      }

      // Request Apple credentials.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Extract the full name if available (only provided on first sign-up)
      String? fullName;
      if (appleCredential.givenName != null) {
        fullName =
            "${appleCredential.givenName} ${appleCredential.familyName ?? ''}"
                .trim();
      }

      // Create an OAuth credential for Firebase.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        // Note: authorizationCode is used as the accessToken in this case.
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential.
      UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      if (userCredential.user != null) {
        final User user = userCredential.user!;

        // If we got a fullName from Apple (first login), update Firebase user's display name.
        if (fullName != null) {
          await user.updateDisplayName(fullName);
          await user.reload();
        }

        // Retrieve the ID token.
        final token = await getIdToken();
        if (token == null) {
          authFormError.value =
              'Couldn\'t complete Apple sign-in. Please try again.';
          return;
        }

        // Get the user's timezone
        final timezone = await getIanaTimezoneId();

        // Use the API service to ensure the user exists in your backend.
        // Use the fullName if available, or fallback to Firebase displayName.
        await ApiService.ensureUserExists(
          token,
          email: user
              .email, // might be null on subsequent logins, so consider a fallback.
          name: fullName ?? user.displayName ?? "User",
          profilePicture: "default",
          timezone: timezone,
        );
      }

      _navigateToAuthGate();
    } catch (e) {
      authFormError.value = _authFailureMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Logout Method
  Future<void> signOut() async {
    await _auth.signOut();
    await Purchases.logOut();

    // Clean up deep link handler
    DeepLinkHandler.instance.dispose();

    if (Get.isRegistered<CourseController>()) {
      Get.delete<CourseController>(force: true);
    }

    if (Get.isRegistered<FriendsController>()) {
      Get.delete<FriendsController>(force: true);
    }
    _clearUserState();
  }

  Future<String?> getIdToken() async {
    final user = firebaseUser.value;
    if (user == null) {
      // User not logged in, or still being loaded
      return null;
    }

    // Return the user's ID token (forceRefresh = false in this example)
    return await user.getIdToken();
  }

  Future<void> updateProfilePicture(int avatarId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.updatePhotoURL(avatarId.toString());
      await user.reload();
      firebaseUser.value = _auth.currentUser;

      final token = await getIdToken();
      if (token == null) {
        return;
      }

      await ApiService.updateUserProfilePicture(token, avatarId);

      // Get.snackbar("Success", "Profile picture updated!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile picture: $e");
    }
  }

  Future<bool> updateDisplayName(
    String newName, {
    bool showSuccessMessage = true,
  }) async {
    try {
      final token = await getIdToken();
      if (token == null) {
        return false;
      }

      name.value = newName;

      await ApiService.updateUserName(token, newName);

      if (showSuccessMessage) {
        Get.snackbar("Success", "Username updated!");
      }
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to update display name: $e");
      return false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      // 1) Re-auth the user (already in your code).

      // 2) Call your server to remove user data
      final token = await getIdToken();
      if (token == null) {
        print('No user token found.');
        return;
      }

      await ApiService.deleteUserData(token); // hypothetical endpoint

      // 3) Optionally log out from RevenueCat
      await Purchases.logOut();

      // 4) Finally delete the user in Firebase
      await user?.delete();

      _navigateToAuthGate();
      Get.snackbar("Account Deleted", "Your account has been deleted.");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete account: ${e.toString()}");
    }
  }

  Future<void> completeOnboarding() async {
    // Update local state
    hasCompletedOnboarding.value = true;
    userDoc.update('user', (value) {
      if (value is Map<String, dynamic>) {
        return {
          ...value,
          'hasCompletedOnboarding': true,
        };
      }
      return value;
    }, ifAbsent: () => {'hasCompletedOnboarding': true});

    // Send backend request to update onboarding status
    try {
      final token = await getIdToken();
      if (token != null) {
        await ApiService.updateOnboardingStatus(token, true);
      }
    } catch (e) {
      print('Error updating onboarding status: $e');
      // Continue even if API call fails
    }
  }

  /// Fade into post-auth shell (onboarding “Make it yours”, main app, or splash).
  void _navigateToAuthGate() {
    clearAuthFormError();
    Get.offAll<void>(
      () => AuthGate(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _clearUserState() {
    // Firebase user
    firebaseUser.value = null;

    // Your user data
    userDoc.clear();

    // Reset all the counts / flags
    hasCompletedOnboarding.value = false;
    streakCount.value = 0;
    xpCount.value = 0;
    courseSlotsUsed.value = 0;
    maxCourseSlots.value = 2; // or whatever your default is
    friendCount.value = 0;
    isPremium.value = false;
    subscriptionPlanType.value = '';
    timezone.value = '';

    // If you want to reset loading / init flags:
    isAuthInitialized.value = false;
    isLoading.value = false;
    authFormError.value = '';

    // If you want to reset user role
    userRole.value = null; // <-- add this!
  }

  //classrooms add, teacher student
  void setUserRole(UserRole role) {
    userRole.value = role;
  }
}

String _authFailureMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address isn\'t valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method isn\'t enabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists for this email with a different sign-in method.';
      case 'credential-already-in-use':
        return 'This sign-in is already linked to another account.';
      default:
        final m = e.message;
        if (m != null && m.length < 120) return m;
        return 'Couldn\'t sign you in. Please try again.';
    }
  }
  return 'Couldn\'t sign you in. Please try again.';
}

Future<String> getIanaTimezoneId() async {
  final info = await FlutterTimezone.getLocalTimezone();
  return info.identifier; // e.g. "America/Chicago"
}
