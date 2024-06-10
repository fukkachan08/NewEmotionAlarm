import SwiftUI

struct SuccessView: View {
    @Environment(\.presentationMode) var presentationMode
    var onDismiss: () -> Void
    var achievementPercentage: Int

    var body: some View {
        VStack {
            Spacer()
            Text("ハキハキ度合いが基準値を上回りました。")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            Text("達成率: \(achievementPercentage)%")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            Text("あなたは起きています")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                onDismiss()
                if let appDelegate = sharedAppDelegate {
                    appDelegate.showContentView()
                }
                cancelAllNotifications()
            }) {
                Text("通知を解除し最初の画面に戻る")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
    }
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

