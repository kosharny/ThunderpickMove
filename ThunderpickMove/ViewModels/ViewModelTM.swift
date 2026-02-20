import Foundation
import Combine
import SwiftUI

class ViewModelTM: ObservableObject {
    @Published var userStats: UserStats
    @Published var journalEntries: [JournalEntry] = []
    @Published var activities: [Activity] = []
    @Published var currentTheme: ThemeType = .standard
    @Published var isOnboardingComplete: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingComplete, forKey: "isOnboardingComplete")
        }
    }
    
    // MARK: - Init
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.userStats = UserStats()
        self.isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        
        // Load Data
        loadData()
        
        // Seed Activities if empty
        if activities.isEmpty {
            seedActivities()
        }
        
        // Listen to Store Changes
        StoreManagerTM.shared.$purchasedProductIDs
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateCurrentTheme()
            }
            .store(in: &cancellables)
            
        StoreManagerTM.shared.$isLoaded
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateCurrentTheme()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Persistence
    private let statsKey = "userStats_tm"
    private let journalKey = "journal_tm"
    private let activitiesKey = "activities_tm"
    // themeKey handled by StorageServiceTM
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(userStats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            UserDefaults.standard.set(encoded, forKey: journalKey)
        }
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
        // Theme is saved via StorageServiceTM on change
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            self.userStats = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: journalKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            self.journalEntries = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            self.activities = decoded
        }
        
        // Load Theme
        if let savedThemeID = StorageServiceTM.shared.getSelectedThemeID(),
           let theme = ThemeType(rawValue: savedThemeID) {
            self.currentTheme = theme
            // Access validation will happen when StoreManager notifies changes
        } else {
            self.currentTheme = .standard
        }
    }
    
    // MARK: - Theme Logic
    
    func setTheme(_ theme: ThemeType) {
        if StoreManagerTM.shared.hasAccess(to: theme) {
            self.currentTheme = theme
            StorageServiceTM.shared.setSelectedTheme(id: theme.rawValue)
        }
    }
    
    func validateCurrentTheme() {
        guard StoreManagerTM.shared.isLoaded else { return } // Wait for IAP to load
        
        if !StoreManagerTM.shared.hasAccess(to: currentTheme) {
            // Revert to standard if access lost or not valid
            self.currentTheme = .standard
            StorageServiceTM.shared.setSelectedTheme(id: ThemeType.standard.rawValue)
        }
    }
    
    // MARK: - Daily Power Move Logic
    var currentDailyMove: DailyPowerMove {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % dailyMoves.count
        return dailyMoves[index]
    }
    
    var isDailyMoveCompleted: Bool {
        guard let lastDate = userStats.lastDailyMoveDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    var isDailyQuestCompleted: Bool {
        guard let lastDate = userStats.lastDailyQuestDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    private let dailyMoves: [DailyPowerMove] = [
        DailyPowerMove(id: 1, title: "Superhero Stance", description: "Stand with legs shoulder-width apart, hands on hips, chest out. Hold for 2 minutes to boost testosterone and lower cortisol.", imageName: "power_pose_superhero"),
        DailyPowerMove(id: 2, title: "Magnetic Gaze", description: "Practice soft but focused eye contact in the mirror. Don't blink excessively. Project warmth.", imageName: "magnetic_gaze_practice"),
        DailyPowerMove(id: 3, title: "The Steeple", description: "Place fingertips together like a steeple. Use this when listening to show confidence and intellect.", imageName: "steeppling_hands"),
        DailyPowerMove(id: 4, title: "Open Palms", description: "When speaking, keep palms open and visible. It signals honesty and trustworthiness.", imageName: "open_palms_gesture"),
        DailyPowerMove(id: 5, title: "Chin Lift", description: "Keep your chin parallel to the floor, not tucked down. Shows engagement and lack of fear.", imageName: "chin_lift"),
        DailyPowerMove(id: 6, title: "Slow Nod", description: "Nod slowly while listening. Fast nodding signals impatience; slow nodding signals 'I hear you and I am processing'.", imageName: "slow_nod"),
        DailyPowerMove(id: 7, title: "Shoulder Roll", description: "Roll shoulders up and back to reset posture. Keeps chest open and prevents slouching.", imageName: "shoulder_roll_back"),
        DailyPowerMove(id: 8, title: "Mirroring", description: "Subtly mimic the posture of someone you are talking to. Builds unconscious rapport.", imageName: "mirroring_intro"),
        DailyPowerMove(id: 9, title: "Space Claimer", description: "Spread your items or arms slightly wider on the table/chair. Occupy your space; don't shrink.", imageName: "space_claimer"),
        DailyPowerMove(id: 10, title: "Firm Handshake", description: "Visualize the web of your hand meeting the web of theirs. Firm but not crushing.", imageName: "firm_handshake_setup"),
        DailyPowerMove(id: 11, title: "Lean In", description: "Lean slightly forward when someone shares something important. Shows active listening.", imageName: "lean_in_interest"),
        DailyPowerMove(id: 12, title: "Lean Back", description: "Lean back and relax in your chair during a negotiation. Signals you are comfortable and not desperate.", imageName: "lean_back_power"),
        DailyPowerMove(id: 13, title: "The Pause", description: "Take a breath and pause for 2 seconds before answering a question. shows control.", imageName: "pause_before_speaking"),
        DailyPowerMove(id: 14, title: "Controlled Smile", description: "A slow, genuine smile separates you from nervous, quick smiling.", imageName: "controlled_smile"),
        DailyPowerMove(id: 15, title: "Purposeful Stride", description: "Take slightly longer strides than usual. Signals purpose and direction.", imageName: "walking_stride_length")
    ]
    
    // MARK: - Actions
    
    func performCheckIn(posture: Double, face: Double, energy: Double) {
        let averageScore = (posture + face + energy) / 3.0
        
        // Update Status based on score using granular calculation
        userStats.currentStatus = BodyStatus.from(score: averageScore)
        
        // Update Body Score slightly
        let scoreIncrease = Int(averageScore * 5)
        userStats.bodyScore = min(100, userStats.bodyScore + scoreIncrease)
        userStats.lastCheckInDate = Date()
        
        logActivity()
        saveData()
    }
    
    func completeDailyMove() {
        if !isDailyMoveCompleted {
            userStats.bodyScore = min(100, userStats.bodyScore + 10) // +10 for daily move
            userStats.activitiesCompleted += 1
            userStats.lastDailyMoveDate = Date()
            
            // Boost 'Posture' skill
            userStats.skillLevels[.posture, default: 0] = min(100, userStats.skillLevels[.posture, default: 0] + 5)
            
            logActivity()
            saveData()
        }
    }
    
    func completeDailyQuest() {
        if !isDailyQuestCompleted {
            userStats.bodyScore = min(100, userStats.bodyScore + 5)
            userStats.activitiesCompleted += 1
            userStats.lastDailyQuestDate = Date()
            
            // Boost 'Mimicry' skill
            userStats.skillLevels[.mimicry, default: 0] = min(100, userStats.skillLevels[.mimicry, default: 0] + 5)
            
            logActivity()
            saveData()
        }
    }
    
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        userStats.totalJournalEntries += 1
        
        // Boost 'Voice' skill if audio used, or 'Gestures' if photo used (simplified logic)
        if entry.audioPath != nil {
            userStats.skillLevels[.voice, default: 0] = min(100, userStats.skillLevels[.voice, default: 0] + 3)
        }
        
        logActivity()
        checkForBadges()
        saveData()
    }
    
    func deleteJournalEntry(at offsets: IndexSet) {
        journalEntries.remove(atOffsets: offsets)
        saveData()
    }
    
    func completeActivity(_ activity: Activity) {
        // Update stats
        userStats.activitiesCompleted += 1
        
        // Update specific skill based on activity type (Mock logic for now)
        switch activity.type {
        case .quest:
             userStats.skillLevels[.mimicry, default: 0] = min(100, userStats.skillLevels[.mimicry, default: 0] + 5)
        case .training:
             userStats.skillLevels[.posture, default: 0] = min(100, userStats.skillLevels[.posture, default: 0] + 5)
        case .battle:
             userStats.skillLevels[.gestures, default: 0] = min(100, userStats.skillLevels[.gestures, default: 0] + 5)
        }
        
        if let _ = activities.firstIndex(where: { $0.id == activity.id }) {
             // In a real app we'd mark this specific instance if it wasn't repeatable
             // For now just keep it available
        }
        
        logActivity()
        checkForBadges()
        saveData()
    }
    
    // MARK: - Logic Helpers
    
    private func logActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        userStats.activityHistory[today, default: 0] += 1
    }
    
    private func checkForBadges() {
        // 1. Writer: 5 Journal Entries
        if userStats.totalJournalEntries >= 5 && !userStats.unlockedBadges.contains("Writer") {
            userStats.unlockedBadges.append("Writer")
        }
        
        // 2. Steel Eyes: 10 Activities
        if userStats.activitiesCompleted >= 10 && !userStats.unlockedBadges.contains("Steel Eyes") {
            userStats.unlockedBadges.append("Steel Eyes")
        }
        
        // 3. Alpha: Score > 90
        if userStats.bodyScore >= 90 && !userStats.unlockedBadges.contains("Alpha") {
            userStats.unlockedBadges.append("Alpha")
        }
        
        // 4. Consistent: 3 days streak (Mock logic requires more data, simplified here to just > 15 activities)
        if userStats.activitiesCompleted >= 15 && !userStats.unlockedBadges.contains("Consistent") {
            userStats.unlockedBadges.append("Consistent")
        }
    }
    
    // MARK: - Media Helpers
    func saveImage(_ image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            return fileName
        }
        return nil
    }
    
    func saveAudio(from sourceURL: URL) -> String? {
        let fileName = UUID().uuidString + ".m4a"
        let destinationURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return fileName
        } catch {
            print("Error saving audio: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // unlockTheme removed, use setTheme instead
    
    func startProTrial() {
        // Logic to unlock pro features temporarily or permanently
        saveData()
    }
    
    // MARK: - Seeding
    private func seedActivities() {
        activities = [
            Activity(type: .quest, title: "Mirror Check", description: "Stand in front of a mirror and hold a power pose for 2 minutes.", difficulty: 1, isCompleted: false, xpReward: 10),
            Activity(type: .training, title: "Magnetic Walk", description: "Practice walking with purpose. Shoulders back, head high.", difficulty: 2, isCompleted: false, xpReward: 20),
            Activity(type: .battle, title: "Negotiation Face", description: "Keep a neutral expression while listening to intense music.", difficulty: 3, isCompleted: false, xpReward: 30)
        ]
    }
}
