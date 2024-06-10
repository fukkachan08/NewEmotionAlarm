import SwiftUI
import UserNotifications

var sharedAppDelegate: AppDelegate?

@main
struct VoiceEmotionAlarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    override init() {
        super.init()
        sharedAppDelegate = self
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "AlarmNotification" || response.notification.request.identifier == "ImmediateNotification" {
            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = UIHostingController(rootView: RecognitionView(viewModel: RecognitionViewModel(selectedDate: Date(), isTomorrow: false, immediate: true)))
                    window.makeKeyAndVisible()
                    self.window = window
                }
            }
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func showHint() {
        print("showHint called")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hintVC = storyboard.instantiateViewController(withIdentifier: "HintViewController")
        print("HintViewController instantiated")
        if let rootVC = window?.rootViewController {
            rootVC.present(hintVC, animated: true, completion: {
                print("HintViewController presented")
            })
        } else {
            print("Root view controller not found")
        }
    }

    func showContentView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView())
            window.makeKeyAndVisible()
            self.window = window
        }
    }
    func scheduleAdditionalNotifications() {
            for i in 1...10 {
                let content = UNMutableNotificationContent()
                content.title = "起きろ！"
                content.body = "まだ起きていませんか？"
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(20 * i), repeats: false)
                let request = UNNotificationRequest(identifier: "RetryNotification_\(i)", content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling additional notification: \(error)")
                    } else {
                        print("Additional notification \(i) scheduled.")
                    }
                }
            }
        }
}

