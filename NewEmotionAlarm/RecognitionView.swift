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

                    Button(action: viewModel.startListening) {
                        Text("再度録音を開始")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                } else {
                    if viewModel.isListening {
                        Button(action: viewModel.stopListening) {
                            Text("停止する")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    } else {
                        Button(action: viewModel.startListening) {
                            Text("録音を開始")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }

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

