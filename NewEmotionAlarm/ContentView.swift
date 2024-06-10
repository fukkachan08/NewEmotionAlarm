import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var isTomorrow = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            DatePicker("Select Alarm Time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
            
            HStack {
                Button(action: {
                    isTomorrow = false
                }) {
                    Text("今日")
                        .padding()
                        .background(isTomorrow ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: {
                    isTomorrow = true
                }) {
                    Text("明日")
                        .padding()
                        .background(isTomorrow ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }

            Button(action: scheduleNotification) {
                Text("アラームをセット")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("アラームセット完了"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Button(action: sendImmediateNotification) {
                Text("即時通知を送信")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }

    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "アラーム"
        content.body = "起きる時間です！"
        content.sound = UNNotificationSound.default

        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDate)
        if isTomorrow {
            dateComponents.day = Calendar.current.component(.day, from: Date()) + 1
        } else {
            dateComponents.day = Calendar.current.component(.day, from: Date())
        }
        dateComponents.month = Calendar.current.component(.month, from: Date())
        dateComponents.year = Calendar.current.component(.year, from: Date())

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "AlarmNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            } else {
                print("Notification scheduled: \(request.identifier) at \(dateComponents.hour!):\(dateComponents.minute!)")
                if let appDelegate = sharedAppDelegate {
                    appDelegate.scheduleAdditionalNotifications()
                }

                // ポップアップ表示
                DispatchQueue.main.async {
                    alertMessage = "アラームをセットしました。時間: \(dateComponents.hour!):\(String(format: "%02d", dateComponents.minute!))"
                    showingAlert = true
                }
            }
        }
    }

    func sendImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "テスト通知"
        content.body = "これは即時通知のテストです"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "ImmediateNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding immediate notification: \(error)")
            } else {
                print("Immediate notification scheduled")
                if let appDelegate = sharedAppDelegate {
                    appDelegate.scheduleAdditionalNotifications()
                }
            }
        }
    }
}

