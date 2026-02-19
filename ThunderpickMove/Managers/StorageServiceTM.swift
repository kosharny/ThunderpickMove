import Foundation
import SwiftUI

class StorageServiceTM {
    static let shared = StorageServiceTM()
    
    private let premiumKey = "isPremium_tm"
    private let selectedThemeKey = "selectedThemeID_tm"
    
    // MARK: - Premium Status
    func isPremium() -> Bool {
        return UserDefaults.standard.bool(forKey: premiumKey)
    }
    
    func setPremium(_ status: Bool) {
        UserDefaults.standard.set(status, forKey: premiumKey)
    }
    
    // MARK: - Theme Selection
    func getSelectedThemeID() -> String? {
        return UserDefaults.standard.string(forKey: selectedThemeKey)
    }
    
    func setSelectedTheme(id: String) {
        UserDefaults.standard.set(id, forKey: selectedThemeKey)
    }
}
