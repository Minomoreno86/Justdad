//
//  ContentView.swift
//  SoloPapá - Main app content view with navigation
//
//  Handles main navigation, onboarding flow, and SOS modal
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showOnboarding = true
    @State private var selectedTab = 0
    @State private var showSOS = false
    
    var body: some View {
        ZStack {
            if showOnboarding {
                PlaceholderOnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    PlaceholderHomeView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Inicio")
                        }
                        .tag(0)
                    
                    PlaceholderAgendaView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Agenda")
                        }
                        .tag(1)
                    
                    PlaceholderFinanceView()
                        .tabItem {
                            Image(systemName: "dollarsign.circle")
                            Text("Finanzas")
                        }
                        .tag(2)
                    
                    PlaceholderEmotionsView()
                        .tabItem {
                            Image(systemName: "heart")
                            Text("Emociones")
                        }
                        .tag(3)
                    
                    PlaceholderCommunityView()
                        .tabItem {
                            Image(systemName: "person.3")
                            Text("Comunidad")
                        }
                        .tag(4)
                    
                    AnalyticsView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Analytics")
                        }
                        .tag(5)
                }
            }
        }
        .sheet(isPresented: $showSOS) {
            PlaceholderSOSView()
        }
    }
}

// Placeholder views
struct PlaceholderHomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Home")
                    .font(.largeTitle)
                Text("Vista principal en desarrollo")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Inicio")
        }
    }
}

struct PlaceholderAgendaView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Agenda")
                    .font(.largeTitle)
                Text("Vista de agenda en desarrollo")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Agenda")
        }
    }
}

struct PlaceholderFinanceView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Finanzas")
                    .font(.largeTitle)
                Text("Vista de finanzas en desarrollo")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Finanzas")
        }
    }
}

struct PlaceholderEmotionsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Emociones")
                    .font(.largeTitle)
                Text("Vista de emociones en desarrollo")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Emociones")
        }
    }
}

struct PlaceholderCommunityView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Comunidad")
                    .font(.largeTitle)
                Text("Vista de comunidad en desarrollo")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Comunidad")
        }
    }
}

struct PlaceholderOnboardingView: View {
    @State private var showOnboarding = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("¡Bienvenido a SoloPapá!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Tu app de apoyo para padres divorciados")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button("Comenzar") {
                showOnboarding = false
            }
            .font(.title2)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
    }
}

struct PlaceholderSOSView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("SOS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Vista de emergencias en desarrollo")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("SOS")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
