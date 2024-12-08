import Flutter
import UIKit
import home_widget

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 17, *) {
             HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
                 GeneratedPluginRegistrant.register(with: registry)
             }
        }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
