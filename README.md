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

2. **Install Dependencies**
   ```bash
   flutter pub get

3. ***Run the Project***
   ```bash
    flutter run

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





