import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var isTomorrow = false

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
                scheduleAdditionalNotifications(date: selectedDate, interval: 20, count: 10)
            }
        }
    }

    func scheduleAdditionalNotifications(date: Date, interval: TimeInterval, count: Int) {
        for i in 1...count {
            let triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval) * i, to: date)!
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate), repeats: false)
            let content = UNMutableNotificationContent()
            content.title = "起きろ！"
            content.body = "まだ起きていませんか？"
            content.sound = UNNotificationSound.default

            let request = UNNotificationRequest(identifier: "RetryNotification-\(i)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error adding retry notification \(i): \(error)")
                } else {
                    print("Retry notification \(i) scheduled at \(triggerDate)")
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
                scheduleAdditionalNotifications(date: Date().addingTimeInterval(1), interval: 20, count: 10)
            }
        }
    }
}

