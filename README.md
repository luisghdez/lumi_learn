# Lumi Learn

Welcome to **Lumi Learn**! This is a Flutter-based application. Follow these instructions to set up the project on your local machine.

## Getting Started

### Prerequisites

- Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- Ensure that Git is installed. If not, you can download it from [Git's website](https://git-scm.com/downloads).

### Setup Instructions

1. **Clone the Repository**

   Clone the repository from GitHub to your local machine using the following command:

   ```bash
   git clone git@github.com:luisghdez/lumi_learn.git
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

### API base URL (`LUMI_API_BASE_URL`)

All HTTP clients (including **podcasts**) use [`lib/application/services/api_config.dart`](lib/application/services/api_config.dart):

- **Default:** if you do not pass a define, the app uses **`https://lumilearnapp.com`** (prod) so a physical device works without extra setup.
- **Local backend** (API running on your machine — use the host the **phone/emulator** can reach, not always `localhost`):

  ```bash
  # iOS Simulator / desktop — API on same machine
  flutter run --dart-define=LUMI_API_BASE_URL=http://localhost:3000

  # Android emulator — special alias to the host machine
  flutter run --dart-define=LUMI_API_BASE_URL=http://10.0.2.2:3000

  # Physical phone on same Wi‑Fi as your computer (replace with your LAN IP)
  flutter run --dart-define=LUMI_API_BASE_URL=http://192.168.1.42:3000
  ```

If you see **`Connection refused` to `localhost`** on a real device, the phone is trying to open port 3000 **on itself** — use your machine’s LAN IP or the dev URL above.

### Run against the local API

Start the API first from the sibling `lumi-api` project with `npm run dev`.
Then run this app on the iOS Simulator with the local API explicitly selected:

```bash
flutter run -d 88A77B2E-73BD-4659-95CB-E41A59EED971 \
  --dart-define=LUMI_API_BASE_URL=http://localhost:3000
```

Stop the Flutter development session by pressing `q` in that terminal. The
Simulator app may remain installed, but it no longer has an attached dev
session. Stop the API separately with `Ctrl-C` in its terminal.

3. **Set up Firebase**

   ```bash
   flutterfire configure
   ```

4. **Run the project**

   ```bash
   flutter run
   ```

### Development device workflow

Use the iOS Simulator for the normal frontend development loop. It is the
fastest place to make changes, relaunch the app, inspect logs, and capture
screenshots or recordings.

When the app is already running through `flutter run`, prefer its interactive
restart controls for frontend-only changes:

- Press `r` for a **hot reload**, which keeps the current app state whenever
  possible.
- Press `R` for a **hot restart**, which restarts the Dart app and clears its
  in-memory state, without rebuilding the iOS app.

Use a fresh `flutter run` only when native iOS changes, dependency changes, or
an unavailable debug session require a rebuild.

### Local-backend unavailable check

To confirm the Simulator is using the local backend, run it with an explicit
host and device ID:

```bash
flutter run -d 88A77B2E-73BD-4659-95CB-E41A59EED971 \
  --dart-define=LUMI_API_BASE_URL=http://localhost:3000
```

If no service is listening on port 3000, requests are expected to fail. The app
shows its unavailable/empty error state (for example, **“Video Feed — Failed to
load videos.”**) rather than silently falling back to production. A fresh
Simulator app state may instead remain on profile onboarding while its initial
feed request fails; complete onboarding only when testing the authenticated
empty-feed screen.

Use the connected physical iPhone only when a change needs real-device
validation (for example permissions, camera, push notifications, networking,
performance, or touch behaviour). Keep the Simulator running; deploying to the
phone does not require shutting it down.

```bash
# Connected development iPhone
flutter run -d 00008140-000E55D930A2201C
```

Running this command installs/relaunches the debug build on the phone. Treat it
as a deliberate device-validation step, especially if the app is already open.
For backend work, configure `LUMI_API_BASE_URL` with a LAN-reachable server URL
as described above; a physical phone cannot reach your laptop's `localhost`.

## Releasing to the App Store

See [docs/ios-release.md](docs/ios-release.md) for the full step-by-step release checklist,
including how to update version numbers and build the IPA.

## Project Structure

   ```bash
    lib
    ├── models                    # Data models for the app
    ├── providers                 # State management files
    ├── screens                   # Screens of the app, each screen has its own folder
    │   ├── screen_name           # Folder for a specific screen
    │   │   ├── components        # Screen-specific components for this screen, made up of widgets
    │   │   ├── widgets           # Screen-specific widgets for this screen
    │   │   └── screen_name.dart  # Main file for the screen
    │   └── another_screen
    │       ├── components
    │       ├── widgets
    │       └── another_screen.dart
    ├── utils                     # Utility functions and helper classes
    ├── widgets                   # General-purpose widgets for the app
    └── main.dart                 # Entry point of the Flutter application
   ```
