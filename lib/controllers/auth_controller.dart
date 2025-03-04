import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lumi_learn_app/screens/auth/auth_gate.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool hasCompletedOnboarding = true.obs;

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

  // Sign Up Method
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.snackbar("Success", "Account created successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
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
