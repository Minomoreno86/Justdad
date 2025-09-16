//
//  JustDadApp.swift
//  JustDad - App for divorced fathers
//  Bundle ID: com.gynevia.justdad
//
//  Created by Jorge Vasquez rodriguez on 9/9/25.
//

import SwiftUI

@main
struct JustDadApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var router = NavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(router)
            } else {
                OnboardingContainerView()
                    .environmentObject(router)
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
        case community = "community"
        
        var title: String {
            switch self {
            case .home: return NSLocalizedString("tab_home", comment: "")
            case .agenda: return NSLocalizedString("tab_agenda", comment: "")
            case .finance: return NSLocalizedString("tab_finance", comment: "")
            case .emotions: return NSLocalizedString("tab_emotions", comment: "")
            case .community: return NSLocalizedString("tab_community", comment: "")
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .agenda: return "calendar"
            case .finance: return "creditcard.fill"
            case .emotions: return "heart.fill"
            case .community: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
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
                
                CommunityView()
                    .tabItem {
                        Image(systemName: Tab.community.icon)
                        Text(Tab.community.title)
                    }
                    .tag(Tab.community)
            }
            .accentColor(.blue) // Using SuperDesign primary color
            .background(Color(red: 0.98, green: 0.98, blue: 1.0)) // Subtle background
            
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
