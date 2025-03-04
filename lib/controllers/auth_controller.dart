import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/auth/auth_gate.dart';

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

  // Logout Method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
