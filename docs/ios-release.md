# iOS App Store Release Guide

This is the checklist for every App Store update. Follow the steps in order.

**Current shipping version:** `2.2.0+12`  
(`2.2.0` is the user-facing version. `12` is the App Store Connect build number.)

---

## Versioning rules

`pubspec.yaml` is the source of truth:

```yaml
version: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

| Part | When to bump | Example |
|---|---|---|
| **MAJOR** | Breaking change users will notice | `2.0.0` → `3.0.0` |
| **MINOR** | New features | `2.1.0` → `2.2.0` |
| **PATCH** | Bug fixes / small polish only | `2.2.0` → `2.2.1` |
| **BUILD_NUMBER** | **Every** App Store upload | `+12` → `+13` |

- The marketing version (`MAJOR.MINOR.PATCH`) is what users see in the App Store.
- The build number must always go **up by at least 1** from the last upload. Apple rejects reused or lower numbers, even if the previous build was cancelled or rejected.
- Do **not** change `RunnerTests` versions in `project.pbxproj` (`MARKETING_VERSION = 1.0`). Only the **Runner** target.

This release is a **minor** bump: `2.1.0+11` → `2.2.0+12`.

---

## Step-by-step

### 1. Confirm you are ready to ship

- Working tree should only contain release-related version bumps (and any last-minute fixes you intend to ship).
- You are on the branch you want to release from.
- You have a physical device or Simulator smoke-check of the main flows.

### 2. Bump version in `pubspec.yaml`

```yaml
version: 2.2.0+12
```

### 3. Sync `ios/Runner.xcodeproj/project.pbxproj`

These fields are hardcoded on the **Runner** target and override Flutter’s generated config. They appear **3 times each** (Debug, Profile, Release) and must all match `pubspec.yaml`.

| Field | This release |
|---|---|
| `FLUTTER_BUILD_NAME` | `2.2.0` |
| `FLUTTER_BUILD_NUMBER` | `12` |
| `CURRENT_PROJECT_VERSION` | `12` |
| `MARKETING_VERSION` | `2.2.0` |

Use find & replace **only** for the Runner values (`2.1.0` / `11`), not the test target (`1.0` / `1`).

Then run:

```bash
flutter pub get
```

That regenerates `ios/Flutter/Generated.xcconfig`. Do not edit that file by hand, and do not commit it if it is gitignored.

### 4. Verify the numbers match

```bash
grep -n "version:" pubspec.yaml | head -1
grep -n "FLUTTER_BUILD_NAME\|FLUTTER_BUILD_NUMBER\|CURRENT_PROJECT_VERSION\|MARKETING_VERSION" ios/Runner.xcodeproj/project.pbxproj
```

You should see `2.2.0` / `12` on Runner (three configs). Tests can stay at `1.0` / `1`.

### 5. Build the IPA

```bash
cd /path/to/lumi_learn
flutter build ipa
```

> **Important:** Use `flutter build ipa` instead of Xcode **Product → Archive**.
> Xcode Archive fails with “Module not found” because it builds in a clean environment
> where pod frameworks are not compiled in the right order. Flutter’s command handles
> that sequencing.

The archive lands at:

```text
build/ios/archive/Runner.xcarchive
```

### 6. Upload to App Store Connect

```bash
open build/ios/archive/Runner.xcarchive
```

In Organizer:

1. **Distribute App**
2. **App Store Connect**
3. **Upload**
4. Wait until the upload finishes without errors.

Processing on App Store Connect usually takes 5–20 minutes. The build appears under the app’s **iOS** version once it is ready.

### 7. Create / update the App Store version

In [App Store Connect](https://appstoreconnect.apple.com):

1. Open the **Lumi** app.
2. Create a new iOS version if one does not already exist for `2.2.0` (or select the existing `2.2.0` version).
3. Select the processed build **12**.
4. Fill in **What’s New** (user-facing; keep it short). Draft for this release:

   ```text
   • Talk with Lumi in real time
   • Download and share videos
   • Smoother video playback (skip, 2x hold, fullscreen)
   • Feed swipe between For You and Following
   • Speak lesson reliability and review feedback
   ```

5. Confirm screenshots, privacy, and age rating still match the app. Update them only if this release changes those surfaces.
6. **Add for Review** → **Submit to App Store**.

### 8. After submit

- Watch email / App Store Connect for “Waiting for Review” → “In Review” → “Pending Developer Release” or “Ready for Sale”.
- If Apple rejects the build, fix the issue, **increment the build number again** (for example `2.2.0+13`), rebuild, and upload. You can keep the same marketing version.

---

## Troubleshooting

### “Module 'audioplayers_darwin' not found” during Xcode Archive

Known build-order issue with `use_frameworks!` in Flutter projects.  
**Fix:** Use `flutter build ipa` as in step 5. Do not Archive from Xcode.

### Build number rejected by App Store Connect

The build number must be strictly greater than every previously uploaded build for this app. Increment `BUILD_NUMBER` in `pubspec.yaml` and the matching Runner fields in `project.pbxproj`, then rebuild.

### Upload succeeded but the build never appears

Wait for processing. If it still missing after ~30 minutes, check **App Store Connect → Activity** (or email) for a processing error, often missing compliance or an invalid icon.

### App Store Connect: “MinimumOSVersion too low” (13.0)

Warning only until **Spring 2027**. Apple will then require `IPHONEOS_DEPLOYMENT_TARGET` **15.0**. This does **not** block the current upload. To silence it on a later release, set `15.0` in:

- `ios/Podfile` (`platform :ios` and the `post_install` `IPHONEOS_DEPLOYMENT_TARGET`)
- Runner build settings in `ios/Runner.xcodeproj/project.pbxproj`

Then increment the **build number**, rebuild, and upload.

### “Upload Symbols Failed” for `WebRTC.framework`

Expected with Talk / `flutter_webrtc`. The vendor ships a prebuilt `WebRTC.framework` with **no dSYM**. Apple cannot attach symbols for that UUID. The app still uploads and can be submitted. Flutter/Dart crash symbols are unaffected. Do not bump the build number for this alone.
