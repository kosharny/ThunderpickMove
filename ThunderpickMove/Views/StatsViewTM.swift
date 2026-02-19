import SwiftUI

struct StatsViewTM: View {
    @EnvironmentObject var viewModel: ViewModelTM
    
    var body: some View {
        ZStack {
            viewModel.currentTheme.backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    HStack {
                        Text("PERFORMANCE DATA")
                            .font(.custom("Rajdhani-Bold", size: 34))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Skill Tree (Hexagon Style)
                    VStack(alignment: .leading, spacing: 15) {
                        Text("SKILL TREE")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        HStack(spacing: 15) {
                            SkillNode(title: "Face", level: viewModel.userStats.skillLevels[.mimicry] ?? 0, color: .blue)
                            SkillNode(title: "Walk", level: viewModel.userStats.skillLevels[.posture] ?? 0, color: .purple)
                            SkillNode(title: "Voice", level: viewModel.userStats.skillLevels[.voice] ?? 0, color: .orange)
                            SkillNode(title: "Gestures", level: viewModel.userStats.skillLevels[.gestures] ?? 0, color: .green)
                        }
                    }
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    
                    // Heatmap
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ACTIVITY HEATMAP (LAST 28 DAYS)")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                            ForEach(0..<28) { i in
                                Rectangle()
                                    .fill(heatmapColor(for: i))
                                    .frame(height: 20)
                                    .cornerRadius(2)
                            }
                        }
                    }
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    
                    // Comparison Graph (Real Data)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ANALYSIS: CONFIDENCE VS STRESS")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        HStack(alignment: .bottom, spacing: 12) {
                            if viewModel.journalEntries.isEmpty {
                                Text("No journal data yet.")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, minHeight: 100)
                            } else {
                                ForEach(getLast7Days(), id: \.self) { day in
                                    VStack {
                                        Spacer()
                                        let stats = getStats(for: day)
                                        HStack(spacing: 2) {
                                            // Confidence Bar
                                            Rectangle()
                                                .fill(viewModel.currentTheme.color)
                                                .frame(width: 8, height: max(4, CGFloat(stats.confidence) * 10))
                                            
                                            // Stress Bar
                                            Rectangle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: max(4, CGFloat(stats.stress) * 10))
                                        }
                                        Text(day.formatted(.dateTime.weekday(.narrow)))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    
                    // Badges
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ACHIEVEMENTS")
                            .font(.headline)
                            .foregroundColor(viewModel.currentTheme.color)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                BadgeView(name: "Writer", icon: "pencil.circle.fill", unlocked: viewModel.userStats.unlockedBadges.contains("Writer"), themeColor: viewModel.currentTheme.color)
                                BadgeView(name: "Steel Eyes", icon: "eye.fill", unlocked: viewModel.userStats.unlockedBadges.contains("Steel Eyes"), themeColor: viewModel.currentTheme.color)
                                BadgeView(name: "Alpha", icon: "crown.fill", unlocked: viewModel.userStats.unlockedBadges.contains("Alpha"), themeColor: viewModel.currentTheme.color)
                                BadgeView(name: "Consistent", icon: "flame.fill", unlocked: viewModel.userStats.unlockedBadges.contains("Consistent"), themeColor: viewModel.currentTheme.color)
                            }
                        }
                    }
                    .padding()
                    .glass()
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func heatmapColor(for index: Int) -> Color {
        // Calculate date for this index (0 = 28 days ago, 27 = today)
        let dayOffset = index - 27
        if let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) {
            let startOfDay = Calendar.current.startOfDay(for: date)
            let count = viewModel.userStats.activityHistory[startOfDay] ?? 0
            
            if count == 0 { return Color.white.opacity(0.1) }
            // Intensity based on count (cap at 5 for max brightness)
            let intensity = min(Double(count) / 5.0, 1.0)
            return viewModel.currentTheme.color.opacity(0.3 + intensity * 0.7)
        }
        return Color.white.opacity(0.1)
    }
    
    func getLast7Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var days: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                days.append(date)
            }
        }
        return days.reversed()
    }
    
    func getStats(for date: Date) -> (confidence: Int, stress: Int) {
        let calendar = Calendar.current
        let entries = viewModel.journalEntries.filter { calendar.isDate($0.date, inSameDayAs: date) }
        let confidence = entries.filter { $0.mood == .confidence || $0.mood == .dominance }.count
        let stress = entries.filter { $0.mood == .stress }.count
        return (confidence, stress)
    }
}

struct SkillNode: View {
    let title: String
    let level: Int
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(color, lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Text("\(level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .glow(color: color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct BadgeView: View {
    let name: String
    let icon: String
    let unlocked: Bool
    var themeColor: Color = .tmAccent // Default for preview/fallback
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(unlocked ? themeColor : .gray)
                .glow(color: unlocked ? themeColor : .clear)
                .padding()
                .background(Circle().fill(Color.white.opacity(0.1)))
            
            Text(name)
                .font(.caption)
                .foregroundColor(unlocked ? .white : .gray)
                .multilineTextAlignment(.center)
        }
        .opacity(unlocked ? 1.0 : 0.4)
        .grayscale(unlocked ? 0.0 : 1.0)
    }
}
