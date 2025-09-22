//
//  LiberationLetterView.swift
//  JustDad - Liberation Letter Main View
//
//  Vista principal para el sistema de 21 días de Cartas de Liberación
//

import SwiftUI

struct LiberationLetterView: View {
    @StateObject private var liberationService = LiberationLetterService.shared
    @StateObject private var speechService = LiberationLetterSpeechService.shared
    @State private var selectedPhase: LiberationLetterPhase = .selfHealing
    @State private var showingLetterDetail = false
    @State private var selectedDay: Int = 1
    @State private var showingProgress = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1), .indigo.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Current Progress
                        currentProgressView
                        
                        // Phase Selection
                        phaseSelectionView
                        
                        // Letters Grid
                        lettersGridView
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Cartas de Liberación")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Progreso") {
                        showingProgress = true
                    }
                    .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showingLetterDetail) {
                if let letter = liberationService.getLetter(for: selectedDay) {
                    LiberationLetterDetailView(letter: letter)
                }
            }
            .sheet(isPresented: $showingProgress) {
                LiberationLetterProgressView()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(spacing: 8) {
                Text("21 Días de Liberación")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Libera emociones reprimidas a través de cartas terapéuticas guiadas por voz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Current Progress View
    private var currentProgressView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Progreso Actual")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Día \(liberationService.currentDay) de 21")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
            
            let overallProgress = liberationService.getOverallProgress()
            HStack {
                VStack(alignment: .leading) {
                    Text("Completadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(overallProgress.completedDays)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Promedio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatTime(overallProgress.averageCompletionTime))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Phase Selection View
    private var phaseSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fases de Liberación")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LiberationLetterPhase.allCases) { phase in
                        PhaseTabButton(
                            phase: phase,
                            isSelected: selectedPhase == phase,
                            progress: liberationService.getProgress(for: phase)
                        ) {
                            selectedPhase = phase
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Letters Grid View
    private var lettersGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Cartas de \(selectedPhase.title)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                let phaseProgress = liberationService.getProgress(for: selectedPhase)
                Text("\(phaseProgress.completedDays)/\(phaseProgress.totalDays)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(liberationService.getLetters(for: selectedPhase)) { letter in
                    LetterCard(
                        letter: letter,
                        isCompleted: liberationService.isDayCompleted(letter.day),
                        isCurrent: letter.day == liberationService.currentDay,
                        session: liberationService.getSession(for: letter.day)
                    ) {
                        selectedDay = letter.day
                        showingLetterDetail = true
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Helper Methods
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Phase Tab Button
struct PhaseTabButton: View {
    let phase: LiberationLetterPhase
    let isSelected: Bool
    let progress: LiberationLetterProgress
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? phase.color : Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: phase.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                VStack(spacing: 4) {
                    Text(phase.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .primary : .secondary)
                        .multilineTextAlignment(.center)
                    
                    Text(phase.dayRange)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Progress indicator
                    HStack(spacing: 2) {
                        ForEach(1...progress.totalDays, id: \.self) { index in
                            Circle()
                                .fill(index <= progress.completedDays ? phase.color : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            .frame(width: 120, height: 120)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? phase.color.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? phase.color : Color.gray.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Letter Card
struct LetterCard: View {
    let letter: LiberationLetter
    let isCompleted: Bool
    let isCurrent: Bool
    let session: LiberationLetterSession?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? .green : (isCurrent ? letter.phase.color : Color.gray.opacity(0.3)))
                            .frame(width: 40, height: 40)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        } else if isCurrent {
                            Text("\(letter.day)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(letter.day)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if let session = session, session.isCompleted {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatTime(session.completionTime))
                                .font(.caption2)
                                .foregroundColor(.green)
                            
                            if let emotionalState = session.emotionalState {
                                Image(systemName: emotionalState.icon)
                                    .font(.caption2)
                                    .foregroundColor(emotionalState.color)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(letter.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(letter.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Voice anchors preview
                if isCompleted {
                    HStack(spacing: 4) {
                        ForEach(Array(letter.voiceAnchors.prefix(2)), id: \.self) { anchor in
                            Text(anchor)
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(.blue.opacity(0.1))
                                )
                        }
                        
                        if letter.voiceAnchors.count > 2 {
                            Text("+\(letter.voiceAnchors.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCurrent ? letter.phase.color : (isCompleted ? .green : .white.opacity(0.2)),
                                lineWidth: isCurrent ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isCurrent ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isCurrent)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    LiberationLetterView()
}
