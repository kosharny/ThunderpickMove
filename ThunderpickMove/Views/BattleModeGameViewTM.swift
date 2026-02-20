import SwiftUI

struct BattleQuestion {
    let scenario: String
    let description: String
    let options: [String]
    let correctAnswer: String
}

struct BattleModeGameViewTM: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: ViewModelTM
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var isCompleted = false
    @State private var selectedAnswer: String? = nil
    @State private var showFeedback = false
    
    // Pool of questions to draw from
    static let allQuestions: [BattleQuestion] = [
        // Set 1
        BattleQuestion(scenario: "Negotiation", description: "Your opponent crosses their arms and leans back. What does it mean?", options: ["Defensiveness / Closed off", "Relaxation / Comfort", "High interest", "Dominance"], correctAnswer: "Defensiveness / Closed off"),
        BattleQuestion(scenario: "First Impression", description: "A person you just met gives a quick, one-second eyebrow raise.", options: ["Surprise / Fear", "Anger", "Acknowledgement / Recognition", "Confusion"], correctAnswer: "Acknowledgement / Recognition"),
        BattleQuestion(scenario: "Sales Meeting", description: "The prospect starts tapping their fingers or foot repeatedly.", options: ["Deep thought", "Impatience / Boredom", "Agreement", "Excitement"], correctAnswer: "Impatience / Boredom"),
        BattleQuestion(scenario: "Interview", description: "The interviewer mirrors your posture and gestures.", options: ["Mockery", "Rapport and Agreement", "Hostility", "Boredom"], correctAnswer: "Rapport and Agreement"),
        BattleQuestion(scenario: "Dating", description: "Your date touches their neck or collarbone frequently.", options: ["Relaxation", "Nervousness or Pacifying", "Excitement", "Anger"], correctAnswer: "Nervousness or Pacifying"),
        BattleQuestion(scenario: "Networking", description: "Someone stands with their hands on their hips, thumbs pointing forward.", options: ["Submission", "Inquisitiveness", "Dominance or Readiness", "Fatigue"], correctAnswer: "Dominance or Readiness"),
        BattleQuestion(scenario: "Presentation", description: "The audience member tilts their head, exposing their neck.", options: ["Disagreement", "Boredom", "Interest and Engagement", "Hostility"], correctAnswer: "Interest and Engagement"),
        BattleQuestion(scenario: "Conflict", description: "A coworker rubs their eyes while you're explaining your idea.", options: ["Deceit or Doubt", "Agreement", "Excitement", "Physical exhaustion only"], correctAnswer: "Deceit or Doubt"),
        BattleQuestion(scenario: "Leadership", description: "A manager speaks with their palms facing up.", options: ["Authoritative command", "Submission or Honesty", "Aggression", "Deception"], correctAnswer: "Submission or Honesty"),
        BattleQuestion(scenario: "Public Speaking", description: "The speaker hides their hands in their pockets or behind their back.", options: ["High confidence", "Relaxation", "Hidden agenda or Nervousness", "Aggression"], correctAnswer: "Hidden agenda or Nervousness"),
        
        // Set 2
        BattleQuestion(scenario: "Negotiation", description: "The client suddenly steeples their fingers (fingertips touching, palms apart).", options: ["Confusion", "High confidence / Superiority", "Nervousness", "Boredom"], correctAnswer: "High confidence / Superiority"),
        BattleQuestion(scenario: "First Impression", description: "A handshake where their palm is facing downward.", options: ["Equality", "Submissiveness", "Dominance attempting control", "Nervousness"], correctAnswer: "Dominance attempting control"),
        BattleQuestion(scenario: "Sales Meeting", description: "The prospect rubs the back of their neck.", options: ["Frustration or Negative emotion", "Deep agreement", "Excitement", "Relaxation"], correctAnswer: "Frustration or Negative emotion"),
        BattleQuestion(scenario: "Interview", description: "The candidate frequently touches their nose while answering a question.", options: ["Honesty", "Potential deceit or Anxiety", "Confidence", "Boredom"], correctAnswer: "Potential deceit or Anxiety"),
        BattleQuestion(scenario: "Dating", description: "Your date maintains prolonged, unblinking eye contact.", options: ["Warmth", "Aggression or Intense interest", "Boredom", "Confusion"], correctAnswer: "Aggression or Intense interest"),
        BattleQuestion(scenario: "Networking", description: "A person's feet are pointed towards the door while talking to you.", options: ["Deep engagement", "Desire to leave the conversation", "Aggression", "Relaxation"], correctAnswer: "Desire to leave the conversation"),
        BattleQuestion(scenario: "Presentation", description: "An audience member rests their chin on their thumb, index finger pointing up.", options: ["Boredom", "Critical evaluation", "Absolute agreement", "Confusion"], correctAnswer: "Critical evaluation"),
        BattleQuestion(scenario: "Conflict", description: "A coworker physically steps back after you make a statement.", options: ["Agreement", "Disagreement or Shock", "Excitement", "Relaxation"], correctAnswer: "Disagreement or Shock"),
        BattleQuestion(scenario: "Leadership", description: "A CEO stands taking up maximum space, legs wide, chest out.", options: ["Nervousness", "Submission", "Alpha/Power posing", "Fatigue"], correctAnswer: "Alpha/Power posing"),
        BattleQuestion(scenario: "Public Speaking", description: "The speaker grips the podium edges so tightly their knuckles are white.", options: ["Passion", "Confidence", "Extreme anxiety or suppressed anger", "Relaxation"], correctAnswer: "Extreme anxiety or suppressed anger"),
        
        // Set 3 ...
        BattleQuestion(scenario: "Negotiation", description: "The opponent suddenly uncrosses their arms and leans forward.", options: ["Increasing defensiveness", "Shift to agreement/interest", "Boredom", "Hostility"], correctAnswer: "Shift to agreement/interest"),
        BattleQuestion(scenario: "First Impression", description: "A person smiles, but only their mouth moves, not their eyes.", options: ["Genuine happiness", "Fake or polite 'Pan Am' smile", "Surprise", "Fear"], correctAnswer: "Fake or polite 'Pan Am' smile")
    ]
    
    // Generate 10 daily questions
    var questions: [BattleQuestion] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        // Use the day to seed the selection to keep it consistent for the day
        var seededQuestions: [BattleQuestion] = []
        let poolSize = Self.allQuestions.count
        
        for i in 0..<10 {
            // Pseudo-random but deterministic for the day
            let index = (dayOfYear * 7 + i * 13) % poolSize
            seededQuestions.append(Self.allQuestions[index])
        }
        
        return seededQuestions
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Intense background for battle mode
            
            VStack {
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
                    
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(viewModel.currentTheme.color)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
                .padding()
                
                if !isCompleted {
                    // Progress
                    ProgressView(value: Double(currentQuestionIndex), total: Double(questions.count))
                        .tint(viewModel.currentTheme.color)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("BATTLE ARENA")
                        .font(.custom("Rajdhani-Bold", size: 30))
                        .foregroundColor(viewModel.currentTheme.color)
                        .glow(color: viewModel.currentTheme.color, radius: 10)
                        .padding(.bottom, 20)
                    
                    let question = questions[currentQuestionIndex]
                    
                    VStack(spacing: 15) {
                        Text("Scenario: \(question.scenario)")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        Text(question.description)
                            .font(.title3)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(minHeight: 120)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Options
                    VStack(spacing: 15) {
                        ForEach(question.options, id: \.self) { option in
                            Button(action: {
                                handleAnswer(option)
                            }) {
                                Text(option)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonColor(for: option))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedAnswer == option ? viewModel.currentTheme.color : Color.clear, lineWidth: 2)
                                    )
                            }
                            .disabled(showFeedback)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                } else {
                    // Completion Screen
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)
                            .glow(color: .yellow)
                        
                        Text("BATTLE COMPLETE")
                            .font(.custom("Rajdhani-Bold", size: 40))
                            .foregroundColor(.white)
                        
                        Text("You scored \(score) out of \(questions.count)")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button(action: finishGame) {
                            Text("CLAIM XP")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(viewModel.currentTheme.color)
                                .cornerRadius(16)
                                .glow(color: viewModel.currentTheme.color)
                        }
                        .padding(.horizontal, 30)
                    }
                }
            }
        }
    }
    
    private func buttonColor(for option: String) -> Color {
        if !showFeedback {
            return Color.white.opacity(0.1)
        }
        let correctAnswer = questions[currentQuestionIndex].correctAnswer
        if option == correctAnswer {
            return Color.green.opacity(0.5)
        } else if option == selectedAnswer && option != correctAnswer {
            return Color.red.opacity(0.5)
        }
        return Color.white.opacity(0.1)
    }
    
    private func handleAnswer(_ answer: String) {
        selectedAnswer = answer
        showFeedback = true
        
        let correct = answer == questions[currentQuestionIndex].correctAnswer
        if correct {
            score += 1
            // Optional haptic
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswer = nil
                showFeedback = false
            } else {
                isCompleted = true
            }
        }
    }
    
    private func finishGame() {
        // Calculate XP based on score
        let xpGained = score * 15
        
        // Pass to ViewModel
        let activity = Activity(type: .battle, title: "Body Language Battle", description: "Completed a battle session", difficulty: 2, isCompleted: true, xpReward: xpGained)
        viewModel.completeActivity(activity)
        
        // Boost Body score or specific skill based on performance here
        if score == questions.count {
             viewModel.userStats.bodyScore = min(100, viewModel.userStats.bodyScore + 5)
        }
        
        dismiss()
    }
}
