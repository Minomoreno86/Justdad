//
//  GuidedExercisesView.swift
//  JustDad - Professional Guided Exercises
//
//  Advanced guided exercises interface
//

import SwiftUI

struct GuidedExercisesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exercisesService = GuidedExercisesService.shared
    @State private var selectedCategory: ExerciseCategory? = nil
    @State private var searchText = ""
    @State private var showingExerciseDetail = false
    @State private var selectedExercise: GuidedExercise? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Stats
                headerView
                
                // Category Filter
                categoryFilterView
                
                // Content
                if exercisesService.currentExercise != nil {
                    currentExerciseView
                } else {
                    exercisesListView
                }
            }
            .navigationTitle("Ejercicios Guiados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Estadísticas") {
                        // TODO: Show statistics
                    }
                }
            }
            .sheet(isPresented: $showingExerciseDetail) {
                if let exercise = selectedExercise {
                    ExerciseDetailView(exercise: exercise)
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tu Bienestar")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ejercicios profesionales para padres")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(exercisesService.totalCompletedExercises)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("Completados")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                StatCard(
                    title: "Esta Semana",
                    value: "\(weeklyCompletedCount)",
                    icon: "calendar",
                    color: .green
                )
                
                StatCard(
                    title: "Categoría Favorita",
                    value: exercisesService.favoriteCategory?.title ?? "N/A",
                    icon: "star.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Tiempo Total",
                    value: "\(totalMinutes) min",
                    icon: "clock",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Category Filter
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ExerciseCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        count: exercisesInCategory(category).count
                    ) {
                        selectedCategory = selectedCategory == category ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Current Exercise View
    private var currentExerciseView: some View {
        VStack(spacing: 20) {
            if let exercise = exercisesService.currentExercise {
                CurrentExerciseCard(exercise: exercise)
            }
        }
        .padding()
    }
    
    // MARK: - Exercises List View
    private var exercisesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Buscar ejercicios...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Exercises Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(filteredExercises) { exercise in
                        GuidedExerciseCard(exercise: exercise) {
                            selectedExercise = exercise
                            showingExerciseDetail = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredExercises: [GuidedExercise] {
        var exercises = exercisesService.exercises
        
        if let category = selectedCategory {
            exercises = exercises.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            exercises = exercises.filter { exercise in
                exercise.title.localizedCaseInsensitiveContains(searchText) ||
                exercise.description.localizedCaseInsensitiveContains(searchText) ||
                exercise.benefits.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return exercises
    }
    
    private var weeklyCompletedCount: Int {
        exercisesService.weeklyProgress.values.reduce(0, +)
    }
    
    private var totalMinutes: Int {
        Int(exercisesService.completedExercises.reduce(0) { $0 + $1.duration }) / 60
    }
    
    private func exercisesInCategory(_ category: ExerciseCategory) -> [GuidedExercise] {
        exercisesService.exercises.filter { $0.category == category }
    }
}

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let category: ExerciseCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                Text(category.title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(category.color.opacity(0.2))
                        .foregroundColor(category.color)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? category.color : Color(UIColor.systemGray5))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Exercise Card
struct GuidedExerciseCard: View {
    let exercise: GuidedExercise
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: exercise.category.icon)
                        .font(.title2)
                        .foregroundColor(exercise.category.color)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(exercise.difficulty.title)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(exercise.difficulty.color)
                        
                        Text("\(Int(exercise.duration / 60)) min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(exercise.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    // Benefits
                    HStack {
                        ForEach(exercise.benefits.prefix(2), id: \.self) { benefit in
                            Text(benefit)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(exercise.category.color.opacity(0.1))
                                .foregroundColor(exercise.category.color)
                                .cornerRadius(4)
                        }
                        
                        if exercise.benefits.count > 2 {
                            Text("+\(exercise.benefits.count - 2)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                HStack {
                    Text(exercise.category.title)
                        .font(.caption)
                        .foregroundColor(exercise.category.color)
                    
                    Spacer()
                    
                    if exercise.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding()
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: exercise.category.color.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(exercise.category.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Current Exercise Card
struct CurrentExerciseCard: View {
    let exercise: GuidedExercise
    @StateObject private var exercisesService = GuidedExercisesService.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Exercise Info
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: exercise.category.icon)
                        .font(.title)
                        .foregroundColor(exercise.category.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(exercise.category.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progreso")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(exercisesService.currentTime / 60)):\(String(format: "%02d", Int(exercisesService.currentTime.truncatingRemainder(dividingBy: 60)))) / \(Int(exercisesService.totalDuration / 60)):\(String(format: "%02d", Int(exercisesService.totalDuration.truncatingRemainder(dividingBy: 60))))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: exercise.category.color))
                }
            }
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    exercisesService.stopExercise()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    if exercisesService.isPlaying {
                        exercisesService.pauseExercise()
                    } else {
                        exercisesService.resumeExercise()
                    }
                }) {
                    Image(systemName: exercisesService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(exercise.category.color)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Exercise Detail View
struct ExerciseDetailView: View {
    let exercise: GuidedExercise
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exercisesService = GuidedExercisesService.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: exercise.category.icon)
                                .font(.largeTitle)
                                .foregroundColor(exercise.category.color)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(exercise.category.title)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Info Cards
                    HStack(spacing: 16) {
                        InfoCard(
                            title: "Duración",
                            value: "\(Int(exercise.duration / 60)) min",
                            icon: "clock",
                            color: .blue
                        )
                        
                        InfoCard(
                            title: "Dificultad",
                            value: exercise.difficulty.title,
                            icon: "chart.bar",
                            color: exercise.difficulty.color
                        )
                        
                        InfoCard(
                            title: "Categoría",
                            value: exercise.category.title,
                            icon: exercise.category.icon,
                            color: exercise.category.color
                        )
                    }
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Beneficios")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(exercise.benefits, id: \.self) { benefit in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(benefit)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.systemGray6))
                                )
                            }
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instrucciones")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(
                                            Circle()
                                                .fill(exercise.category.color)
                                        )
                                    
                                    Text(instruction)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    
                    // Start Button
                    Button(action: {
                        exercisesService.startExercise(exercise)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Comenzar Ejercicio")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(exercise.category.color)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Detalle del Ejercicio")
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

// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    GuidedExercisesView()
}
