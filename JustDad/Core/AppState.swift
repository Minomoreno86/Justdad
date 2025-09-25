//
//  AppState.swift
//  JustDad - App state management
//
//  Global application state for JustDad
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AppState: ObservableObject {
    // MARK: - Accessibility
    @Published var accessibilityManager: AccessibilityManager
    
    // MARK: - Settings
    @Published var biometricAuthEnabled: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var visitRemindersEnabled: Bool = true
    @Published var emotionalCheckInEnabled: Bool = true
    @Published var emergencyAlertsEnabled: Bool = true
    @Published var darkModeEnabled: Bool = false
    @Published var textSize: TextSize = .medium
    @Published var hasCompletedOnboarding: Bool = false
    
    // MARK: - User Info
    @Published var userName: String = ""
    @Published var userAge: String = ""
    @Published var userProfileImageData: Data?
    
    // MARK: - Emergency
    @Published var emergencyContacts: [EmergencyContact] = []
    
    // MARK: - Data
    @Published var isDataExporting: Bool = false
    @Published var lastDataExport: Date?
    
    init() {
        self.accessibilityManager = AccessibilityManager.shared
        // Load saved state from UserDefaults if needed
        loadState()
    }
    
    private func loadState() {
        biometricAuthEnabled = UserDefaults.standard.bool(forKey: "biometricAuthEnabled")
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        visitRemindersEnabled = UserDefaults.standard.bool(forKey: "visitRemindersEnabled")
        emotionalCheckInEnabled = UserDefaults.standard.bool(forKey: "emotionalCheckInEnabled")
        emergencyAlertsEnabled = UserDefaults.standard.bool(forKey: "emergencyAlertsEnabled")
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        if let textSizeRawValue = UserDefaults.standard.string(forKey: "textSize"),
           let textSizeValue = TextSize(rawValue: textSizeRawValue) {
            textSize = textSizeValue
        }
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userAge = UserDefaults.standard.string(forKey: "userAge") ?? ""
        userProfileImageData = UserDefaults.standard.data(forKey: "userProfileImageData")
    }
    
    func saveState() {
        UserDefaults.standard.set(biometricAuthEnabled, forKey: "biometricAuthEnabled")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(visitRemindersEnabled, forKey: "visitRemindersEnabled")
        UserDefaults.standard.set(emotionalCheckInEnabled, forKey: "emotionalCheckInEnabled")
        UserDefaults.standard.set(emergencyAlertsEnabled, forKey: "emergencyAlertsEnabled")
        UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        UserDefaults.standard.set(textSize.rawValue, forKey: "textSize")
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userAge, forKey: "userAge")
        if let imageData = userProfileImageData {
            UserDefaults.standard.set(imageData, forKey: "userProfileImageData")
        }
    }
}

// MARK: - Supporting Types
// NOTE: EmergencyContact is now defined as a SwiftData @Model in CoreDataModels.swift
// This provides persistent storage with CoreData integration

// MARK: - Text Size Enum
enum TextSize: String, CaseIterable {
    case small = "small"
    case medium = "medium"
    case large = "large"
    case extraLarge = "extraLarge"
    
    var displayName: String {
        switch self {
        case .small: return "Pequeño"
        case .medium: return "Mediano"
        case .large: return "Grande"
        case .extraLarge: return "Extra Grande"
        }
    }
    
    var fontSize: Font {
        switch self {
        case .small: return .caption
        case .medium: return .body
        case .large: return .title3
        case .extraLarge: return .title2
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.2
        case .extraLarge: return 1.4
        }
    }
    
    var sizeCategory: ContentSizeCategory {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        case .extraLarge: return .extraLarge
        }
    }
}