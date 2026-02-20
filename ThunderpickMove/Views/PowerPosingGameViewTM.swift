import SwiftUI
import Combine

struct PowerPosingGameViewTM: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModelTM
    
    @State private var timeRemaining = 120 // 2 minutes
    @State private var isPlaying = false
    @State private var isCompleted = false
    
    // 10 levels of Power Posing
    struct PowerPose {
        let title: String
        let description: String
        let imageName: String
    }
    
    let poses: [PowerPose] = [
        PowerPose(title: "The Champion", description: "Stand tall, arms raised in a V shape, chin slightly up. Feel the victory.", imageName: "pose_champion"),
        PowerPose(title: "The CEO", description: "Lean back slightly in your chair, hands clasped behind your head, elbows wide.", imageName: "pose_ceo"),
        PowerPose(title: "The Wonder", description: "Stand with feet wide apart, hands firmly on hips, chest open and proud.", imageName: "pose_wonder"),
        PowerPose(title: "The Loomer", description: "Stand leaning forward slightly, hands planted firmly on a desk or table in front of you.", imageName: "pose_loomer"),
        PowerPose(title: "The Steeple", description: "Sit or stand, hands joined at the fingertips forming a steeple, elbows resting or relaxed.", imageName: "pose_steeple"),
        PowerPose(title: "The Expander", description: "Sit with legs stretched out to the front, arms draped over the back of adjacent chairs.", imageName: "pose_expander"),
        PowerPose(title: "The Percher", description: "Sit confidently on the edge of a desk or table, arms relaxed but open.", imageName: "pose_percher"),
        PowerPose(title: "The Star", description: "Stand with legs wide, arms stretched out to the sides. Take up as much space as possible.", imageName: "pose_star"),
        PowerPose(title: "The Pillar", description: "Stand perfectly straight, shoulders back, arms relaxed at sides, breathing deeply.", imageName: "pose_pillar"),
        PowerPose(title: "The Anchor", description: "Stand with feet shoulder-width apart, hands clasped loosely behind your back.", imageName: "pose_anchor")
    ]
    
    var currentPose: PowerPose {
        // Pseudo-random selection based on the day of the year so it changes daily
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return poses[dayOfYear % poses.count]
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
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
                    
                    
                    // Icon
                    ZStack {
                        Circle()
                            .stroke(viewModel.currentTheme.color.opacity(0.3), lineWidth: 10)
                            .frame(width: 180, height: 180)
                        
                        if isPlaying {
                            Circle()
                                .trim(from: 0, to: CGFloat(timeRemaining) / 120.0)
                                .stroke(viewModel.currentTheme.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1.0), value: timeRemaining)
                        } else {
                            Circle()
                                .stroke(viewModel.currentTheme.color, lineWidth: 10)
                                .frame(width: 180, height: 180)
                        }
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 80))
                            .foregroundColor(viewModel.currentTheme.color)
                            .opacity(isPlaying ? 0.5 : 1.0)
                            .scaleEffect(isPlaying ? 1.1 : 1.0)
                            .animation(isPlaying ? Animation.easeInOut(duration: 2).repeatForever() : .default, value: isPlaying)
                    }
                    .glow(color: viewModel.currentTheme.color, radius: isPlaying ? 30 : 10)
                    
                    // Hint Image (Placeholder)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )

                        Image(currentPose.imageName)
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 30)
                    
                    // Title & Instructions
                    VStack(spacing: 12) {
                        Text("POWER POSING: LEVEL \(poses.firstIndex(where: { $0.title == currentPose.title })! + 1)")
                            .font(.custom("Rajdhani-Bold", size: 24))
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        Text(currentPose.title)
                            .font(.custom("Rajdhani-Bold", size: 30))
                            .foregroundColor(.white)
                        
                        Text(currentPose.description)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    // Timer
                    if isPlaying || isCompleted {
                        Text(isCompleted ? "SUCCESS" : timeString(time: timeRemaining))
                            .font(.custom("Rajdhani-Bold", size: 56))
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
                            Text(isPlaying ? "HOLD..." : "START CHALLENGE")
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
                .frame(minHeight: UIScreen.main.bounds.height - 100)
                .padding(.bottom, 20)
            }
        }
        .onReceive(timer) { _ in
            if isPlaying && timeRemaining > 0 {
                timeRemaining -= 1
            } else if isPlaying && timeRemaining <= 0 {
                isPlaying = false
                isCompleted = true
            }
        }
    }
    
    private func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func finishGame() {
        let activity = Activity(type: .training, title: "Power Posing", description: "Held pose for 2 mins", difficulty: 3, isCompleted: true, xpReward: 50)
        viewModel.completeActivity(activity)
        dismiss()
    }
}
