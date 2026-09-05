import 'package:get/get.dart';

/// Temporary developer toggles.
///
/// Set [forceOnboardingPreview] to `true` to always show onboarding flow after login
/// for testing purposes. This ensures onboarding is always active for testing.
class DevFlags {
  static const bool forceOnboardingPreview = false;

  /// Shows the Talk to Lumi tester toggle on the lesson start panel.
  /// Turn this off before shipping.
  static const bool showTalkToLumiTester = true;

  /// When true, Start jumps to the Speak section and enables live Talk to Lumi.
  static final forceTalkToLumi = true.obs;
}
