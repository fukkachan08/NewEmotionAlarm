import SwiftUI

struct RecognitionView: View {
    @StateObject private var viewModel: RecognitionViewModel

    init(viewModel: RecognitionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            if viewModel.isWaitingForAPI {
                WaitingView(achievementPercentage: viewModel.achievementPercentage ?? 0)
            } else if viewModel.isAwake {
                SuccessView(onDismiss: resetView, achievementPercentage: viewModel.achievementPercentage ?? 0)
            } else {
                Text(viewModel.statusMessage)
                    .font(.headline)
                    .padding()

                if viewModel.isListening {
                    Text("録音終了まで: \(viewModel.countdown)秒")
                        .padding()
                    Text(viewModel.transcription)
                        .padding()
                }

                if let apiResult = viewModel.apiResult, !viewModel.isWaitingForAPI {
                    let achievementPercentage = viewModel.achievementPercentage ?? 0
                    Text("達成率: \(achievementPercentage)%")
                        .padding()
                        .foregroundColor(.white)
                }

                Button(action: {
                    if viewModel.isListening {
                        viewModel.stopListening()
                    } else {
                        viewModel.startListening()
                    }
                }) {
                    Text(viewModel.isListening ? "停止する" : "録音を開始")
                        .padding()
                        .background(viewModel.isListening ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                // ヒントボタンを追加
                Button(action: {
                    print("Hint button pressed")
                    if let appDelegate = sharedAppDelegate {
                        print("AppDelegate found")
                        appDelegate.showHint()
                    } else {
                        print("AppDelegate not found")
                    }
                }) {
                    Text("ヒント")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .padding()
        .onChange(of: viewModel.apiResult) { newValue in
            if let result = newValue {
                viewModel.isWaitingForAPI = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    viewModel.isWaitingForAPI = false
                    if result >= 0.6 {
                        viewModel.isAwake = true
                    } else {
                        viewModel.isAwake = false
                    }
                }
            }
        }
    }

    private func resetView() {
        viewModel.resetState()
    }
}

