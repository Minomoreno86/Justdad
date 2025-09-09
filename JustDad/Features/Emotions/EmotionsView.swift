//
//  EmotionsView.swift
//  SoloPapá - Emotional wellness tracking
//
//  Track mood, stress levels, and wellness activities
//

import SwiftUI

struct EmotionsView: View {
    @StateObject private var router = NavigationRouter.shared
    @State private var emotionEntries: [MockEmotionEntry] = []
    @State private var showingMoodTest = false
    @State private var showingGuidedExercise = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current mood section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("¿Cómo te sientes hoy?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ForEach(["😔", "😐", "🙂", "😊", "😄"], id: \.self) { emoji in
                                Button(action: {
                                    // TODO: Save mood entry
                                }) {
                                    Text(emoji)
                                        .font(.largeTitle)
                                        .frame(width: 50, height: 50)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Quick actions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Herramientas de Bienestar")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            WellnessCard(
                                title: "Test Rápido",
                                subtitle: "Evalúa tu estado",
                                icon: "list.clipboard",
                                color: .green
                            ) {
                                showingMoodTest = true
                            }
                            
                            WellnessCard(
                                title: "Ejercicio Guiado",
                                subtitle: "Respiración y calma",
                                icon: "heart.circle",
                                color: .blue
                            ) {
                                showingGuidedExercise = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Weekly summary
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resumen de la Semana")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        WeeklySummaryChart()
                            .padding(.horizontal)
                    }
                    
                    // Recent entries
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Entradas Recientes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if emotionEntries.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "heart.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No hay entradas emocionales aún")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("Comienza registrando cómo te sientes hoy")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 50)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Bienestar Emocional")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Add new emotion entry
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingMoodTest) {
                MoodTestSheet()
            }
            .sheet(isPresented: $showingGuidedExercise) {
                GuidedExerciseSheet()
            }
        }
    }
}

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

// MARK: - Wellness Card Component
struct WellnessCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
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
        .background(Color(.systemGray6))
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

#Preview {
    EmotionsView()
}