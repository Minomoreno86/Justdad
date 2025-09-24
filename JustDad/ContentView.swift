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
    @State private var selectedTab: MainTabView.Tab = .home
    @State private var showingSOSSheet = false
    
    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: MainTabView.Tab.home.icon)
                            Text(MainTabView.Tab.home.title)
                        }
                        .tag(MainTabView.Tab.home)
                    
                    AgendaView(repo: InMemoryAgendaRepository())
                        .tabItem {
                            Image(systemName: MainTabView.Tab.agenda.icon)
                            Text(MainTabView.Tab.agenda.title)
                        }
                        .tag(MainTabView.Tab.agenda)
                    
                    FinanceView()
                        .tabItem {
                            Image(systemName: MainTabView.Tab.finance.icon)
                            Text(MainTabView.Tab.finance.title)
                        }
                        .tag(MainTabView.Tab.finance)
                    
                    EmotionsView()
                        .tabItem {
                            Image(systemName: MainTabView.Tab.emotions.icon)
                            Text(MainTabView.Tab.emotions.title)
                        }
                        .tag(MainTabView.Tab.emotions)
                    
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
