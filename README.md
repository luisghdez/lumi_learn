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

- **Default:** if you do not pass a define, the app uses **`https://lumi-api-dev.onrender.com`** so a physical device works without pointing at your laptop.
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

3. **Set up Firebase**

   ```bash
   flutterfire configure
   ```

4. **Run the project**

   ```bash
   flutter run
   ```

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

