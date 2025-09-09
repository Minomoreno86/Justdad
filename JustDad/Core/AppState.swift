//
//  AppState.swift
//  JustDad - App state management
//
//  Global application state for JustDad
//

import Foundation
import Combine

class AppState: ObservableObject {
    // MARK: - Settings
    @Published var biometricAuthEnabled: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var darkModeEnabled: Bool = false
    @Published var hasCompletedOnboarding: Bool = false
    
    // MARK: - User Info
    @Published var userName: String = ""
    @Published var userAge: String = ""
    
    // MARK: - Emergency
    @Published var emergencyContacts: [EmergencyContact] = []
    
    // MARK: - Data
    @Published var isDataExporting: Bool = false
    @Published var lastDataExport: Date?
    
    init() {
        // Load saved state from UserDefaults if needed
        loadState()
    }
    
    private func loadState() {
        biometricAuthEnabled = UserDefaults.standard.bool(forKey: "biometricAuthEnabled")
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled") 
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        userAge = UserDefaults.standard.string(forKey: "userAge") ?? ""
    }
    
    func saveState() {
        UserDefaults.standard.set(biometricAuthEnabled, forKey: "biometricAuthEnabled")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(userAge, forKey: "userAge")
    }
}

// MARK: - Supporting Types
struct EmergencyContact: Identifiable, Codable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var relationship: String
}