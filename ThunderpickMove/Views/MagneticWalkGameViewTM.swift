import SwiftUI
import Combine

struct MagneticWalkGameViewTM: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModelTM
    
    @State private var timeRemaining = 60
    @State private var isPlaying = false
    @State private var isCompleted = false
    
    // Pulse animation
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Pace timer for pulse (e.g. 100 steps per min = 0.6s per step)
    let paceTimer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()
    
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
                
                // Icon & Pulse
                ZStack {
                    if isPlaying {
                        Circle()
                            .fill(viewModel.currentTheme.color.opacity(pulseOpacity))
                            .frame(width: 150, height: 150)
                            .scaleEffect(pulseScale)
                    }
                    
                    Circle()
                        .stroke(viewModel.currentTheme.color, lineWidth: 5)
                        .frame(width: 150, height: 150)
                        
                    Image(systemName: "figure.walk")
                        .font(.system(size: 60))
                        .foregroundColor(viewModel.currentTheme.color)
                }
                .glow(color: viewModel.currentTheme.color, radius: 10)
                
                // Title & Instructions
                VStack(spacing: 12) {
                    Text("MAGNETIC WALK")
                        .font(.custom("Rajdhani-Bold", size: 36))
                        .foregroundColor(.white)
                    
                    Text(isPlaying ? "Match your strides to the pulse. Keep your shoulders back and head up." : "Sync your pace to build presence and authority.")
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
                        Text(isPlaying ? "TRACKING..." : "START PACING")
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
            } else if isPlaying && timeRemaining <= 0 {
                isPlaying = false
                isCompleted = true
            }
        }
        .onReceive(paceTimer) { _ in
            guard isPlaying else { return }
            
            // Trigger haptic if needed: let impact = UIImpactFeedbackGenerator(style: .medium); impact.impactOccurred()
            
            withAnimation(.easeOut(duration: 0.5)) {
                pulseScale = 1.5
                pulseOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                pulseScale = 1.0
                pulseOpacity = 0.5
            }
        }
    }
    
    private func finishGame() {
        let activity = Activity(type: .training, title: "Magnetic Walk", description: "Completed 1m pace tracking", difficulty: 2, isCompleted: true, xpReward: 30)
        viewModel.completeActivity(activity)
        dismiss()
    }
}
