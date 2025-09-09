//
//  SimpleThemeManager.swift
//  SoloPapá - Simple Theme Management System
//
//  Basic light/dark mode switching
//

import SwiftUI

class SimpleThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    func toggleTheme() {
        isDarkMode.toggle()
    }
}
