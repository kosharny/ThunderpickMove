import SwiftUI
import Combine

struct PokerFaceGameViewTM: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModelTM
    
    @State private var timeRemaining = 30
    @State private var isPlaying = false
    @State private var isCompleted = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .stroke(viewModel.currentTheme.color.opacity(0.3), lineWidth: 10)
                        .frame(width: 150, height: 150)
                    
                    if isPlaying {
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / 30.0)
                            .stroke(viewModel.currentTheme.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1.0), value: timeRemaining)
                    } else {
                        Circle()
                            .stroke(viewModel.currentTheme.color, lineWidth: 10)
                            .frame(width: 150, height: 150)
                    }
                    
                    Image(systemName: "face.smiling.fill")
                        .font(.system(size: 60))
                        .foregroundColor(viewModel.currentTheme.color)
                        .opacity(isPlaying ? 0.5 : 1.0)
                }
                .glow(color: viewModel.currentTheme.color, radius: isPlaying ? 20 : 5)
                
                // Title & Instructions
                VStack(spacing: 12) {
                    Text("POKER FACE")
                        .font(.custom("Rajdhani-Bold", size: 36))
                        .foregroundColor(.white)
                    
                    Text("Maintain a completely neutral facial expression for 30 seconds. Do not smile, frown, or show emotion.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // Timer
                if isPlaying || isCompleted {
                    Text(isCompleted ? "SUCCESS" : "00:\(String(format: "%02d", timeRemaining))")
                        .font(.custom("Rajdhani-Bold", size: 48))
                        .foregroundColor(isCompleted ? .green : .white)
                        .glow(color: isCompleted ? .green : .clear)
                }
                
                Spacer()
                
                // Action Button
                if !isCompleted {
                    Button(action: {
                        if !isPlaying {
                            isPlaying = true
                        }
                    }) {
                        Text(isPlaying ? "HOLD IT..." : "START SCANNING")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(isPlaying ? Color.gray : viewModel.currentTheme.color)
                            .cornerRadius(16)
                            .glow(color: isPlaying ? .clear : viewModel.currentTheme.color)
                    }
                    .padding(.horizontal, 30)
                    .disabled(isPlaying)
                } else {
                    Button(action: {
                        finishGame()
                    }) {
                        Text("CLAIM REWARD")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.green)
                            .cornerRadius(16)
                            .glow(color: .green)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .padding(.bottom, 20)
        }
        .onReceive(timer) { _ in
            if isPlaying && timeRemaining > 0 {
                timeRemaining -= 1
            } else if isPlaying && timeRemaining == 0 {
                isPlaying = false
                isCompleted = true
            }
        }
    }
    
    private func finishGame() {
        // Create an activity to pass to ViewModel
        let activity = Activity(type: .training, title: "Poker Face", description: "Completed 30s session", difficulty: 1, isCompleted: true, xpReward: 20)
        viewModel.completeActivity(activity)
        dismiss()
    }
}
