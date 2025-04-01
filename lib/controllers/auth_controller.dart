import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/auth/auth_gate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumi_learn_app/services/api_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs; // Track loading state

  final RxBool hasCompletedOnboarding = true.obs;
  RxBool isAuthInitialized = false.obs;

  @override
  void onReady() {
    super.onReady();
    _auth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      // Set the flag to true after receiving the first auth event.
      isAuthInitialized.value = true;
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    if (isLoading.value) return; // Prevent multiple requests
    isLoading.value = true; // Start loading

    try {
      // Check if email already exists before creating an account
      var signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        Get.snackbar("Error", "This email is already in use.");
        isLoading.value = false;
        return;
      }

      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If user is successfully created, update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
      }

      final token = await getIdToken();
      if (token == null) {
        print('No user token found.');
        return;
      }

      await ApiService.ensureUserExists(token,
          email: email, name: name, profilePicture: "");

      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  // Login Method
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.snackbar("Success", "Logged in successfully!");
      Get.offAll(() => AuthGate());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Google Sign-In Method
  Future<void> signInWithGoogle() async {
    if (isLoading.value) return;
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
          print('No user token found.');
          return;
        }

        await ApiService.ensureUserExists(
          token,
          email: user.email,
          name: user.displayName,
          profilePicture: "default",
        );

        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          Get.snackbar("Welcome!", "Account created via Google sign-in.");
        } else {
          Get.snackbar("Success", "Logged in via Google!");
        }
      }

      Get.offAll(() => AuthGate());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      // Check if Apple Sign In is available on the current device.
      if (!await SignInWithApple.isAvailable()) {
        Get.snackbar("Error", "Apple Sign-In is not available on this device.");
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
          print('No user token found.');
          return;
        }

        // Use the API service to ensure the user exists in your backend.
        // Use the fullName if available, or fallback to Firebase displayName.
        await ApiService.ensureUserExists(
          token,
          email: user
              .email, // might be null on subsequent logins, so consider a fallback.
          name: fullName ?? user.displayName ?? "User",
          profilePicture: "default",
        );

        // Notify user whether this is a new account.
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          Get.snackbar("Welcome!", "Account created via Apple Sign-In.");
        } else {
          Get.snackbar("Success", "Logged in via Apple!");
        }
      }

      // Navigate to your authenticated gate.
      Get.offAll(() => AuthGate());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Logout Method
  Future<void> signOut() async {
    await _auth.signOut();
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

  Future<void> updateProfilePicture(String imageUrl) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(imageUrl);
        await user.reload();
        firebaseUser.value = _auth.currentUser; // Refresh user instance

        Get.snackbar("Success", "Profile picture updated successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile picture: $e");
    }
  }
}
