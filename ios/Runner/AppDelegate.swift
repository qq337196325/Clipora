import Flutter
import UIKit
//import receive_sharing_intent

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    //ReceiveSharingIntentPlugin.setAppGroup("group.com.guanshangyun.clipora") // 添加这行

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
