//
//  JustDadApp.swift
//  JustDad - App for divorced fathers
//  Bundle ID: com.gynevia.justdad
//
//  Created by Jorge Vasquez rodriguez on 9/9/25.
//

import SwiftUI
import SwiftData

@main
struct JustDadApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var router = NavigationRouter()
    @StateObject private var appState = AppState()
    @StateObject private var securityService = SecurityService.shared
    @State private var isAuthenticated = false
    @State private var showingBiometricAuth = false
    @State private var showingWelcome = true
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                if showingWelcome {
                    WelcomeView()
                        .environmentObject(appState)
                        .environmentObject(securityService)
                        .onAppear {
                            // Show welcome screen for first-time users or when explicitly requested
                            print("WelcomeView appeared - showingWelcome: \(showingWelcome)")
                        }
                        .onChange(of: appState.userName) { _, newValue in
                            // If user has a name, they can proceed
                            if !newValue.isEmpty {
                                showingWelcome = false
                            }
                        }
                        .onChange(of: appState.userProfileImageData) { _, newValue in
                            // If user has profile data, they can proceed
                            if newValue != nil {
                                showingWelcome = false
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .init("WelcomeViewDismissed"))) { _ in
                            showingWelcome = false
                        }
                } else if appState.biometricAuthEnabled && !isAuthenticated {
                    BiometricAuthView(
                        isAuthenticated: $isAuthenticated,
                        onSuccess: {
                            isAuthenticated = true
                        }
                    )
                } else {
                    MainTabView()
                        .environmentObject(router)
                        .environmentObject(appState)
                        .environmentObject(securityService)
                        .journalModelContainer() // Add SwiftData container
                        .onAppear {
                            if appState.biometricAuthEnabled {
                                Task {
                                    let success = await securityService.authenticateWithBiometrics()
                                    if !success {
                                        showingBiometricAuth = true
                                    }
                                }
                            }
                        }
                }
            } else {
                OnboardingContainerView()
                    .environmentObject(router)
                    .environmentObject(appState)
                    .environmentObject(securityService)
                    .journalModelContainer() // Add SwiftData container
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "home"
        case agenda = "agenda" 
        case finance = "finance"
        case emotions = "emotions"
        case settings = "settings"
        
        var title: String {
            switch self {
            case .home: return NSLocalizedString("tab_home", comment: "")
            case .agenda: return NSLocalizedString("tab_agenda", comment: "")
            case .finance: return NSLocalizedString("tab_finance", comment: "")
            case .emotions: return NSLocalizedString("tab_emotions", comment: "")
            case .settings: return NSLocalizedString("tab_settings", comment: "")
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .agenda: return "calendar"
            case .finance: return "creditcard.fill"
            case .emotions: return "heart.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: Tab.home.icon)
                        Text(Tab.home.title)
                    }
                    .tag(Tab.home)
                
                // Agenda with repository injection
                AgendaView(repo: InMemoryAgendaRepository())
                    .tabItem {
                        Image(systemName: Tab.agenda.icon)
                        Text(Tab.agenda.title)
                    }
                    .tag(Tab.agenda)
                
                FinanceView()
                    .tabItem {
                        Image(systemName: Tab.finance.icon)
                        Text(Tab.finance.title)
                    }
                    .tag(Tab.finance)
                
                EmotionsView()
                    .tabItem {
                        Image(systemName: Tab.emotions.icon)
                        Text(Tab.emotions.title)
                    }
                    .tag(Tab.emotions)
                
                SettingsView()
                    .tabItem {
                        Image(systemName: Tab.settings.icon)
                        Text(Tab.settings.title)
                    }
                    .tag(Tab.settings)
                
            }
            .accentColor(SuperDesign.Tokens.colors.primary) // Using SuperDesign primary color
            .background(SuperDesign.Tokens.colors.surfaceGradient) // Professional gradient background
            .tabViewStyle(.automatic)
            .overlay(
                // Professional tab bar enhancement
                Rectangle()
                    .fill(SuperDesign.Tokens.colors.primary.opacity(0.1))
                    .frame(height: 1)
                    .animation(.easeInOut, value: selectedTab),
                alignment: .top
            )
        }
    }
}
