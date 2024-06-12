import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var isTomorrow = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isAlarmSet = false

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
                    .background(isAlarmSet ?Color.gray : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("完了"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            Button(action: cancelAllNotifications) {
                Text("アラームをキャンセル")
                    .padding()
                    .background(isAlarmSet ?Color.red : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("アラームキャンセル"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Button(action: sendImmediateNotification) {
                Text("デモを開始")
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
        content.body = "⚠️起きる時間です！⚠️"
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
                    appDelegate.scheduleAdditionalNotifications(alarmDateComponents: dateComponents)
                }

                DispatchQueue.main.async {
                    alertMessage = "\(dateComponents.hour!):\(String(format: "%02d", dateComponents.minute!)) にアラームをセットしました\nおやすみなさい！"
                    showingAlert = true
                    isAlarmSet = true
                }
            }
        }
    }

    func sendImmediateNotification() {
        let content = UNMutableNotificationContent()
        content.title = "デモ通知"
        content.body = "おはようございます"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "ImmediateNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding immediate notification: \(error)")
            } else {
                print("Immediate notification scheduled")
                if let appDelegate = sharedAppDelegate {
                    let now = Date().addingTimeInterval(1)
                    let alarmDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
                    appDelegate.scheduleAdditionalNotifications(alarmDateComponents: alarmDateComponents)
                }
            }
        }
    }
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DispatchQueue.main.async {
            alertMessage = "目覚ましをキャンセルしました。"
            showingAlert = true
            isAlarmSet = false
        }
        print("CancelByButton")
    }
}

