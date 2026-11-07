/// Temporary developer toggles.
///
/// Set [forceOnboardingPreview] to `true` to always show onboarding flow after login
/// for testing purposes. This ensures onboarding is always active for testing.
class DevFlags {
  static const bool forceOnboardingPreview = bool.fromEnvironment(
    'FORCE_ONBOARDING_PREVIEW',
    defaultValue: false,
  );
}
