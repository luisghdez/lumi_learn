import UIKit
import Flutter
import Photos
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Needed for background isolates to register plugins
    LocalNotificationsPluginRegistrant.setPluginRegistrantCallback()

    // Set the notification center delegate
    UNUserNotificationCenter.current().delegate = self

    GeneratedPluginRegistrant.register(with: self)

    let videoLibraryChannel = FlutterMethodChannel(
      name: "com.lumilearnapp/video_library",
      binaryMessenger: window?.rootViewController as! FlutterBinaryMessenger
    )
    videoLibraryChannel.setMethodCallHandler { call, result in
      guard call.method == "saveVideoToPhotos" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard
        let arguments = call.arguments as? [String: Any],
        let filePath = arguments["filePath"] as? String
      else {
        result(FlutterError(
          code: "invalid_arguments",
          message: "A video file path is required.",
          details: nil
        ))
        return
      }

      self.saveVideoToPhotos(at: URL(fileURLWithPath: filePath), result: result)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func saveVideoToPhotos(at fileURL: URL, result: @escaping FlutterResult) {
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      result(FlutterError(
        code: "file_not_found",
        message: "The downloaded video could not be found.",
        details: nil
      ))
      return
    }

    requestPhotosAddPermission { granted in
      guard granted else {
        result(FlutterError(
          code: "photos_permission_denied",
          message: "Allow Photos access to save this video.",
          details: nil
        ))
        return
      }

      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
      }) { success, error in
        DispatchQueue.main.async {
          if success {
            result(nil)
          } else {
            result(FlutterError(
              code: "save_failed",
              message: error?.localizedDescription ?? "The video could not be saved.",
              details: nil
            ))
          }
        }
      }
    }
  }

  private func requestPhotosAddPermission(completion: @escaping (Bool) -> Void) {
    if #available(iOS 14, *) {
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        completion(status == .authorized || status == .limited)
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        completion(status == .authorized)
      }
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate {
  // Foreground presentation
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }

  // Tapped notification
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}
