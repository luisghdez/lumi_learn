// whats_new_data.dart
// This file contains all update announcements for the What's New screen
// Add new updates to the top of the list

class UpdateData {
  final String title;
  final String subtitle;
  final String imagePath;
  final String version;
  final bool showImage;

  const UpdateData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.version,
    this.showImage = true,
  });
}

// All updates - add new updates at the top
final List<UpdateData> allUpdates = [
  // Version 2.0.0
  const UpdateData(
    title: "Update - Version 2.0.0",
    subtitle: "Major upgrade with AI Tutor & more!",
    imagePath: "assets/astronaut/teacher2.png",
    version: "2.0.0",
    showImage: true,
  ),
  
  // Version 1.0.0
  const UpdateData(
    title: "Update - Version 1.0.0",
    subtitle: "Welcome!",
    imagePath: "assets/images/welcome.png",
    version: "1.0.0",
    showImage: true,
  ),
  
  // Template for future updates:
  // const UpdateData(
  //   title: "Update - Version X.X.X",
  //   subtitle: "Brief description here",
  //   imagePath: "assets/path/to/image.png",
  //   version: "X.X.X",
  //   showImage: true,
  // ),
];