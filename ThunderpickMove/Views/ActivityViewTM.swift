import SwiftUI

struct ActivityViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    @State private var showBattle = false
    
    // Move data out of body
    private let modules = [
        TrainingModule(title: "Poker Face", icon: "face.smiling.fill", color: .blue, description: "Control micro-expressions."),
        TrainingModule(title: "Magnetic Walk", icon: "figure.walk", color: .purple, description: "Master the stride of leaders."),
        TrainingModule(title: "Power Posing", icon: "star.fill", color: .orange, description: "2-min confidence boost.")
    ]
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    dailyQuestSection
                    trainingModulesSection
                    battleModeSection
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showBattle) {
            BattleModeView()
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        HStack {
            Text("ACTIVITY HEADQUARTERS")
                .font(.custom("Rajdhani-Bold", size: 34))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var dailyQuestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("DAILY QUEST")
                    .font(.headline)
                    .foregroundColor(viewModel.currentTheme.color)
                Spacer()
                Text("XP +50")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(viewModel.currentTheme.color.opacity(0.3))
                    .cornerRadius(5)
            }
            
            Text("Smile at 3 Strangers")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Practice open facial expressions to build rapport.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                // Action
            }) {
                Text("Accept Challenge")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.currentTheme.color)
                    .cornerRadius(12)
                    .glow(color: viewModel.currentTheme.color)
            }
        }
        .padding()
        .glass()
        .padding(.horizontal)
    }
    
    private var trainingModulesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TRAINING MODULES")
                .font(.custom("Rajdhani-Bold", size: 24))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        
            ForEach(modules) { module in
                HStack {
                    ZStack {
                        Circle()
                            .fill(module.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        Image(systemName: module.icon)
                            .font(.system(size: 24))
                            .foregroundColor(module.color)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(module.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(module.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Start module
                    }) {
                        Text("Start")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .glass()
                .padding(.horizontal)
            }
        }
    }
    
    private var battleModeSection: some View {
        VStack(spacing: 15) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .glow(color: .red)
            
            Text("BATTLE MODE")
                .font(.custom("Rajdhani-Bold", size: 28))
                .foregroundColor(.white)
            
            Text("Test your reading of body language in real-time scenarios.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Button(action: {
                showBattle = true
            }) {
                Text("ENTER ARENA")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red, lineWidth: 2)
                    )
                    .glow(color: .red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.red.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// Helper Structs
struct TrainingModule: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let description: String
}

struct BattleModeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Battle mode might want a specific intense background, but keeping theme consistency for now
            // Or maybe viewModel isn't available here easily? It is via EnvironmentObject if injected.
            // But BattleModeView doesn't have viewModel environment object declared in the file snippet I have?
            // Wait, previous file view showed it does NOT have @EnvironmentObject viewModel.
            // I should stick to a dark background or pass it. 
            Color.black.ignoresSafeArea() // Battle mode gets specific black background
            
            VStack {
                Text("BATTLE ARENA")
                    .font(.custom("Rajdhani-Bold", size: 30))
                    .foregroundColor(.red)
                    .padding()
                
                Spacer()
                
                Text("Scenario: Negotiation")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Your opponent crosses their arms. What does it mean?")
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(spacing: 15) {
                    Button("Defensiveness") { dismiss() }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                    Button("Relaxation") { dismiss() }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
        }
    }
}
