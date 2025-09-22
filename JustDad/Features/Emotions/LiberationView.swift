//
//  LiberationView.swift
//  JustDad - Liberation and Emotional Healing View
//
//  Vista simple para técnicas de liberación emocional
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

struct LiberationView: View {
    @StateObject private var liberationService = LiberationService.shared
    @State private var selectedTechnique: LiberationService.LiberationTechnique?
    @State private var showingTechniqueDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Techniques Grid
                    techniquesGridView
                    
                    // Recent Sessions
                    if !liberationService.liberationSessions.isEmpty {
                        recentSessionsView
                    }
                }
                .padding()
            }
            .navigationTitle("Liberación")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingTechniqueDetail) {
                if let technique = selectedTechnique {
                    LiberationTechniqueDetailView(technique: technique)
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bird.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Liberación Emocional")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Libera cargas emocionales, resentimientos y patrones que ya no te sirven. Encuentra paz y renovación a través de técnicas de sanación profunda.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    // MARK: - Techniques Grid View
    private var techniquesGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Técnicas de Liberación")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(LiberationService.LiberationTechnique.allCases) { technique in
                    LiberationTechniqueCard(technique: technique) {
                        selectedTechnique = technique
                        showingTechniqueDetail = true
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Sessions View
    private var recentSessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sesiones Recientes")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(liberationService.liberationSessions.prefix(5)) { session in
                        LiberationSessionCard(session: session)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Liberation Technique Card
struct LiberationTechniqueCard: View {
    let technique: LiberationService.LiberationTechnique
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: technique.icon)
                        .font(.title2)
                        .foregroundColor(technique.color)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(technique.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(technique.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(technique.estimatedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Liberation Session Card
struct LiberationSessionCard: View {
    let session: LiberationService.LiberationSession
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: session.date, relativeTo: Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: session.technique.icon)
                    .font(.caption)
                    .foregroundColor(session.technique.color)
                
                Text(session.technique.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(session.notes)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                // Progress indicator
                HStack(spacing: 2) {
                    ForEach(1...10, id: \.self) { index in
                        Circle()
                            .fill(index <= session.progress ? session.technique.color : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                
                Spacer()
                
                Text("\(session.progress)/10")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
        )
        .frame(width: 200)
    }
}

#Preview {
    LiberationView()
}
