//
//  EmotionsView.swift
//  SoloPapá - Emotional wellness tracking
//
//  Track mood, stress levels, and wellness activities
//

import SwiftUI

// MARK: - Tab Enum
enum Tab: String, CaseIterable {
    case home = "home"
    case agenda = "agenda"
    case finance = "finance"
    case emotions = "emotions"
    case journal = "journal"
    case community = "community"
    case analytics = "analytics"
}

struct EmotionsView: View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var journalingService = IntelligentJournalingService.shared
    @State private var emotionEntries: [MockEmotionEntry] = []
    @State private var showingMoodTest = false
    @State private var showingGuidedExercise = false
    @State private var selectedEmotion: EmotionalState? = nil
    @State private var showingAdvice = false
    @State private var showingParenthoodTest = false
    @State private var showingJournaling = false
    @State private var showingHabitsTracking = false
    @State private var showingGuidedExercises = false
    @State private var selectedTab: Tab = .emotions
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    currentMoodSection
                    wellnessToolsSection
                    recentEntriesSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Bienestar Emocional")
            .onAppear {
                journalingService.loadJournalEntries()
                journalingService.loadEmotionEntries()
                print("🔄 EmotionsView appeared - Journal entries: \(journalingService.journalEntries.count), Emotion entries: \(journalingService.emotionEntries.count)")
            }
            .sheet(isPresented: $showingMoodTest) {
                MoodTestSheet()
            }
            .sheet(isPresented: $showingGuidedExercise) {
                GuidedExerciseSheet()
            }
            .sheet(isPresented: $showingAdvice) {
                if let emotion = selectedEmotion {
                    EmotionalAdviceSheet(emotion: emotion)
                }
            }
            .sheet(isPresented: $showingParenthoodTest) {
                ParenthoodTestSelectionView()
            }
            .sheet(isPresented: $showingJournaling) {
                IntelligentJournalingView()
            }
            .sheet(isPresented: $showingHabitsTracking) {
                HabitsTrackingView()
            }
                   .sheet(isPresented: $showingGuidedExercises) {
                       GuidedExercisesView()
                   }
        }
    }
    
    // MARK: - Current Mood Section
    private var currentMoodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("¿Cómo te sientes hoy?")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                ForEach(EmotionalState.allCases) { emotion in
                    Button(action: {
                        selectedEmotion = emotion
                        showingAdvice = true
                        // Registrar la emoción con fecha y hora
                        journalingService.addEmotionEntry(emotion)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: emotion.icon)
                                .font(.title2)
                                .foregroundColor(emotion.color)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(emotion.color.opacity(0.1))
                                        .overlay(
                                            Circle()
                                                .stroke(emotion.color, lineWidth: 2)
                                        )
                                )
                            
                            Text(emotion.displayName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Wellness Tools Section
    private var wellnessToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Herramientas de Bienestar")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                WellnessCard(
                    title: "Test de Paternidad",
                    subtitle: "Evalúa tu preparación",
                    icon: "brain.head.profile",
                    color: .green
                ) {
                    showingParenthoodTest = true
                }

                WellnessCard(
                    title: "Ejercicios Guiados",
                    subtitle: "Meditación, respiración y más",
                    icon: "brain.head.profile",
                    color: .purple
                ) {
                    showingGuidedExercises = true
                }

                WellnessCard(
                    title: "Hábitos Atómicos",
                    subtitle: "Mejora tu rutina",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                ) {
                    showingHabitsTracking = true
                }

                       WellnessCard(
                           title: "Journaling",
                           subtitle: "Reflexiona y escribe",
                           icon: "book.pages",
                           color: .orange
                       ) {
                           showingJournaling = true
                       }

            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Entries Section
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Entradas Recientes")
                    .font(.headline)
                Spacer()
                Button("Ver todas") {
                    selectedTab = .journal
                }
            }
            .padding(.horizontal)
            
            if journalingService.journalEntries.isEmpty && journalingService.emotionEntries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No hay entradas aún")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Comienza registrando tus emociones o escribiendo en tu journal.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Mostrar entradas de journaling
                        ForEach(journalingService.journalEntries.prefix(3)) { entry in
                            RecentJournalEntryCard(entry: entry)
                        }
                        
                        // Mostrar entradas de emociones
                        ForEach(journalingService.emotionEntries.prefix(3)) { entry in
                            RecentEmotionEntryCard(emotionEntry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Supporting Views

// MARK: - Mock Emotion Entry
struct MockEmotionEntry: Identifiable {
    let id = UUID()
    var mood: Int // 1-5 scale
    var note: String?
    var date: Date
    
    static let sampleEntries: [MockEmotionEntry] = [
        MockEmotionEntry(
            mood: 4,
            note: "Feeling positive today after spending time with kids",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        ),
        MockEmotionEntry(
            mood: 3,
            note: "Neutral day, managing stress well",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        )
    ]
}

// MARK: - Professional Wellness Card Component
struct WellnessCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 24, height: 24)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weekly Summary Chart Placeholder
struct WeeklySummaryChart: View {
    var body: some View {
        VStack {
            Text("📊 Gráfico Semanal")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("TODO: Implementar gráfico de estado de ánimo semanal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Mood Test Sheet
struct MoodTestSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("🧠 Test de Estado Emocional")
                    .font(.title2)
                    .padding()
                
                Text("TODO: Implementar cuestionario rápido de bienestar emocional")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Test Emocional")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Guided Exercise Sheet
struct GuidedExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("🧘‍♂️ Ejercicio de Respiración")
                    .font(.title2)
                    .padding()
                
                Text("TODO: Implementar ejercicio de respiración guiada")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Ejercicio Guiado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Emotional Advice Sheet
struct EmotionalAdviceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var adviceService = EmotionalAdviceService.shared
    
    let emotion: EmotionalState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: emotion.icon)
                                .font(.title)
                                .foregroundColor(emotion.color)
                            
                            VStack(alignment: .leading) {
                                Text(emotion.displayName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Estado emocional actual")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(emotion.color.opacity(0.1))
                        )
                    }
                    
                    // Advice Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Consejos para ti")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(adviceService.getAdvice(for: emotion)) { advice in
                                AdviceCard(advice: advice)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Exercise Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ejercicios recomendados")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(adviceService.getExercises(for: emotion)) { exercise in
                                ExerciseCard(exercise: exercise)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Consejos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Advice Card
struct AdviceCard: View {
    let advice: EmotionalAdvice
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: advice.type.icon)
                .font(.title3)
                .foregroundColor(advice.type.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(advice.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(advice.content)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: advice.type.color.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(advice.type.color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: ExerciseRecommendation
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(exercise.duration)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                Text(exercise.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.blue.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Recent Journal Entry Card
struct RecentJournalEntryCard: View {
    let entry: JournalEntry
    @StateObject private var journalingService = IntelligentJournalingService.shared
    
    private var moodEmoji: String {
        switch entry.emotion {
        case .verySad: return "😢"
        case .sad: return "😔"
        case .neutral: return "😐"
        case .happy: return "😊"
        case .veryHappy: return "🎉"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(moodEmoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.prompt.text)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if entry.audioURL != nil {
                    Button(action: {
                        if journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id {
                            journalingService.stopAudio()
                        } else {
                            journalingService.playAudio(for: entry)
                        }
                    }) {
                        Image(systemName: journalingService.isPlaying && journalingService.currentPlayingEntry?.id == entry.id ? "stop.fill" : "play.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Text(entry.content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if !entry.tags.isEmpty {
                HStack {
                    ForEach(entry.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Recent Emotion Entry Card
struct RecentEmotionEntryCard: View {
    let emotionEntry: EmotionEntry
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: emotionEntry.timestamp, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoticon de la emoción
            VStack {
                Image(systemName: emotionEntry.emotion.icon)
                    .font(.title2)
                    .foregroundColor(emotionEntry.emotion.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(emotionEntry.emotion.color.opacity(0.1))
                    )
            }
            
            // Información de la entrada
            VStack(alignment: .leading, spacing: 4) {
                Text(emotionEntry.emotion.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let notes = emotionEntry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Indicador de tipo
            VStack {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(emotionEntry.emotion.color)
                
                Text("Emoción")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: emotionEntry.emotion.color.opacity(0.1), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(emotionEntry.emotion.color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    EmotionsView()
}