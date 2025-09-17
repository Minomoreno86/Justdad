//
//  ContentView.swift
//  JustDad - Main app content view with navigation
//
//  Handles main navigation, onboarding flow, and SOS modal
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: Tab = .home
    @State private var showingSOSSheet = false
    
    enum Tab: String, CaseIterable {
        case home = "home"
        case agenda = "agenda" 
        case finance = "finance"
        case emotions = "emotions"
        case community = "community"
        case analytics = "analytics"
        
        var title: String {
            switch self {
            case .home: return NSLocalizedString("tab_home", comment: "")
            case .agenda: return NSLocalizedString("tab_agenda", comment: "")
            case .finance: return NSLocalizedString("tab_finance", comment: "")
            case .emotions: return NSLocalizedString("tab_emotions", comment: "")
            case .community: return NSLocalizedString("tab_community", comment: "")
            case .analytics: return NSLocalizedString("tab_analytics", comment: "")
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .agenda: return "calendar"
            case .finance: return "creditcard.fill"
            case .emotions: return "heart.fill"
            case .community: return "person.3.fill"
            case .analytics: return "chart.bar.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Image(systemName: Tab.home.icon)
                            Text(Tab.home.title)
                        }
                        .tag(Tab.home)
                    
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
                    
                    AnalyticsView()
                        .tabItem {
                            Image(systemName: Tab.analytics.icon)
                            Text(Tab.analytics.title)
                        }
                        .tag(Tab.analytics)
                }
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
