import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/auth/auth_gate.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs; // Track loading state

  final RxBool hasCompletedOnboarding = true.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
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

      // (Optional) Check if the user is new and perform additional actions
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        Get.snackbar("Welcome!", "Account created via Google sign-in.");
      } else {
        Get.snackbar("Success", "Logged in via Google!");
      }
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
}
