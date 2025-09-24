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
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(router)
                    .journalModelContainer() // Add SwiftData container
            } else {
                OnboardingContainerView()
                    .environmentObject(router)
                    .journalModelContainer() // Add SwiftData container
            }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var selectedTab: Tab = .home
    @State private var showingSOSSheet = false
    
    enum Tab: String, CaseIterable {
        case home = "home"
        case agenda = "agenda" 
        case finance = "finance"
        case emotions = "emotions"
        
        var title: String {
            switch self {
            case .home: return NSLocalizedString("tab_home", comment: "")
            case .agenda: return NSLocalizedString("tab_agenda", comment: "")
            case .finance: return NSLocalizedString("tab_finance", comment: "")
            case .emotions: return NSLocalizedString("tab_emotions", comment: "")
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .agenda: return "calendar"
            case .finance: return "creditcard.fill"
            case .emotions: return "heart.fill"
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
            
            // Enhanced Floating SOS Button (only on Home tab)
            if selectedTab == .home {
                FloatingSOSButton {
                    showingSOSSheet = true
                }
            }
        }
        .sheet(isPresented: $showingSOSSheet) {
            SOSView()
        }
    }
}
