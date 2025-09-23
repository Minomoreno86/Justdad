//
//  ConflictSelfCareView.swift
//  JustDad - Conflict Self Care View
//
//  Self care practices for conflict wellness
//

import SwiftUI

struct ConflictSelfCareView: View {
    @StateObject private var service = ConflictWellnessService.shared
    @State private var selectedPractice: SelfCarePractice?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Daily Affirmation
                if let affirmation = service.currentAffirmation {
                    dailyAffirmationSection(affirmation)
                }
                
                // Practices Section
                practicesSection
                
                // Progress Section
                progressSection
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.purple)
            
            Text("Fortaleza del Padre")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Prácticas de autocuidado para mantener tu bienestar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func dailyAffirmationSection(_ affirmation: DailyAffirmation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Afirmación del Día")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(affirmation.text)
                .font(.body)
                .italic()
                .foregroundColor(.primary)
            
            Text("— \(affirmation.category)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var practicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prácticas de Autocuidado")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(ConflictWellnessContentPack.selfCarePractices) { practice in
                    SelfCarePracticeCard(practice: practice) {
                        service.recordSelfCareDay()
                    }
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu Progreso")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                ProgressCard(
                    title: "Días de Autocuidado",
                    value: "\(service.stats.selfCareDays)",
                    subtitle: "de 21 objetivo",
                    progress: Double(service.stats.selfCareDays) / 21.0,
                    color: .purple
                )
                
                ProgressCard(
                    title: "Racha Actual",
                    value: "\(service.stats.currentStreak)",
                    subtitle: "días consecutivos",
                    progress: Double(service.stats.currentStreak) / 21.0,
                    color: .blue
                )
            }
        }
    }
}

struct SelfCarePracticeCard: View {
    let practice: SelfCarePractice
    let onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: practice.icon)
                    .foregroundColor(Color(practice.color))
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(practice.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(practice.duration) • \(practice.frequency)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onComplete) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            Text(practice.description)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ConflictSelfCareView()
}
