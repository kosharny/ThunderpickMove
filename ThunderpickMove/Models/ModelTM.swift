import Foundation
import SwiftUI

// MARK: - Enums

enum ThemeType: String, Codable, CaseIterable, Identifiable {
    case standard // Free
    case neonCyber // Pro 1
    case stealthOps // Pro 2
    
    var id: String { self.rawValue }
    
    var isPremium: Bool {
        switch self {
        case .standard: return false
        case .neonCyber, .stealthOps: return true
        }
    }
    
    var productID: String? {
        switch self {
        case .standard: return nil
        case .neonCyber: return "premium_theme_neon"
        case .stealthOps: return "premium_theme_stealth"
        }
    }
    
    var color: Color {
        switch self {
        case .standard: return Color(hex: "9D00FF") // Electric Purple
        case .neonCyber: return Color(hex: "D200FF") // Neon Purple
        case .stealthOps: return Color(hex: "00A8FF") // Bright Blue
        }
    }
    var backgroundColor: Color {
        switch self {
        case .standard: return Color(hex: "1a0b2e") // Deep Purple (Darkest)
        case .neonCyber: return Color(hex: "2d1b4e") // Lighter Vibrant Purple
        case .stealthOps: return Color(hex: "2c2c2e") // Lighter Tactical Gray
        }
    }
}

enum BodyStatus: String, Codable {
    case collapsed = "Collapsed"       // 0-10%
    case guarded = "Guarded"           // 10-20%
    case invisible = "Invisible"       // 20-30%
    case observer = "Observer"         // 30-40%
    case neutral = "Neutral"           // 40-50%
    case steady = "Steady"             // 50-60%
    case present = "Present"           // 60-70%
    case magnetic = "Magnetic"         // 70-80%
    case dominant = "Dominant"         // 80-90%
    case alpha = "Alpha Mode"          // 90-100%
    
    // Fallback for logic
    static func from(score: Double) -> BodyStatus {
        switch score {
        case 0.0..<0.1: return .collapsed
        case 0.1..<0.2: return .guarded
        case 0.2..<0.3: return .invisible
        case 0.3..<0.4: return .observer
        case 0.4..<0.5: return .neutral
        case 0.5..<0.6: return .steady
        case 0.6..<0.7: return .present
        case 0.7..<0.8: return .magnetic
        case 0.8..<0.9: return .dominant
        default: return .alpha
        }
    }
}

enum MoodType: String, Codable, CaseIterable {
    case confidence = "Confidence"
    case stress = "Stress"
    case dominance = "Dominance"
}

enum ActivityType: String, Codable {
    case quest
    case training
    case battle
}

enum SkillType: String, Codable, CaseIterable {
    case mimicry = "Mimicry"
    case posture = "Posture" // Walk/Gait
    case gestures = "Gestures"
    case voice = "Voice"
}

// MARK: - Structs

struct JournalEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date
    var mood: MoodType
    var notes: String
    var photoPath: String?
    var audioPath: String?
    var voiceText: String? // Optional transcription
}

struct Activity: Identifiable, Codable {
    var id: UUID = UUID()
    var type: ActivityType
    var title: String
    var description: String
    var difficulty: Int // 1-3
    var isCompleted: Bool
    var xpReward: Int
}

// MARK: - Daily Power Move
struct DailyPowerMove: Identifiable, Codable {
    let id: Int // Day of year (1-365) to rotate
    let title: String
    let description: String
    let imageName: String
}

// MARK: - User Stats
struct UserStats: Codable {
    var bodyScore: Int = 0 // 0-100
    var currentStatus: BodyStatus = .neutral
    var totalJournalEntries: Int = 0
    var activitiesCompleted: Int = 0
    var activityHistory: [Date: Int] = [:] // Date (start of day) -> Count
    var lastCheckInDate: Date?
    var lastDailyMoveDate: Date?
    var lastDailyQuestDate: Date?
    var skillLevels: [SkillType: Int] = [ // 0-100
        .mimicry: 10,
        .posture: 10,
        .gestures: 10,
        .voice: 10
    ]
    var unlockedBadges: [String] = []
}

// MARK: - Helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
