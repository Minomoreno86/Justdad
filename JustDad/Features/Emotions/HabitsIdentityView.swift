//
//  HabitsIdentityView.swift
//  JustDad - Habit Identity System UI
//
//  Vista para gestionar y visualizar identidades de hábitos
//

import SwiftUI

struct HabitsIdentityView: View {
    @StateObject private var identityService = HabitsIdentityService.shared
    @State private var showingCreateIdentity = false
    @State private var showingIdentityDetail: HabitIdentity?
    @State private var selectedIdentity: HabitIdentity?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Identity Section
                    currentIdentitySection
                    
                    // Identity Progress Section
                    if let currentIdentity = identityService.currentIdentity {
                        identityProgressSection(for: currentIdentity)
                    }
                    
                    // All Identities Section
                    allIdentitiesSection
                    
                    // Suggestions Section
                    if !identityService.getIdentitySuggestions().isEmpty {
                        suggestionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Identidad de Hábitos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateIdentity = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingCreateIdentity) {
                CreateIdentityView { identity in
                    identityService.createIdentity(
                        name: identity.name,
                        description: identity.description,
                        category: identity.category,
                        targetHabits: identity.targetHabits
                    )
                }
            }
            .sheet(item: $showingIdentityDetail) { identity in
                IdentityDetailView(identity: identity)
            }
        }
    }
    
    // MARK: - Current Identity Section
    private var currentIdentitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mi Identidad Actual")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let currentIdentity = identityService.currentIdentity {
                CurrentIdentityCard(identity: currentIdentity) {
                    showingIdentityDetail = currentIdentity
                }
            } else {
                NoCurrentIdentityCard {
                    showingCreateIdentity = true
                }
            }
        }
    }
    
    // MARK: - Identity Progress Section
    private func identityProgressSection(for identity: HabitIdentity) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso de Identidad")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let progress = identityService.identityProgress[identity.id] {
                IdentityProgressCard(identity: identity, progress: progress)
            }
        }
    }
    
    // MARK: - All Identities Section
    private var allIdentitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Mis Identidades")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(identityService.identities.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(8)
            }
            
            if identityService.identities.isEmpty {
                EmptyIdentitiesCard {
                    showingCreateIdentity = true
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(identityService.identities) { identity in
                        IdentityCard(identity: identity) {
                            showingIdentityDetail = identity
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Suggestions Section
    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sugerencias para Ti")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(identityService.getIdentitySuggestions()) { suggestion in
                    IdentitySuggestionCard(suggestion: suggestion) {
                        identityService.createIdentity(
                            name: suggestion.title,
                            description: suggestion.description,
                            category: suggestion.category,
                            targetHabits: suggestion.supportingHabits
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Current Identity Card
struct CurrentIdentityCard: View {
    let identity: HabitIdentity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: identity.category.icon)
                        .font(.title2)
                        .foregroundColor(identity.category.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(identity.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Identidad Activa")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(identity.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                // Daily Affirmation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Afirmación del Día")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(HabitsIdentityService.shared.getDailyAffirmation())
                        .font(.body)
                        .foregroundColor(.primary)
                        .italic()
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(identity.category.color.opacity(0.1))
                        )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: identity.category.color.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(identity.category.color.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - No Current Identity Card
struct NoCurrentIdentityCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(.purple)
                
                Text("Define tu Identidad")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Los hábitos no son solo acciones, son la persona en la que te conviertes. Define quién quieres ser.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Crear mi primera identidad")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Identity Progress Card
struct IdentityProgressCard: View {
    let identity: HabitIdentity
    let progress: IdentityProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Fuerza de Identidad")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: progress.strength.icon)
                        .foregroundColor(progress.strength.color)
                    Text(progress.strength.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(progress.strength.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(progress.strength.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Progress Stats
            HStack(spacing: 16) {
                ProgressStatItem(
                    title: "Completados",
                    value: "\(progress.totalCompletions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                ProgressStatItem(
                    title: "Racha Promedio",
                    value: "\(progress.averageStreak) días",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ProgressStatItem(
                    title: "Consistencia",
                    value: "\(Int(progress.completionRate * 100))%",
                    icon: "chart.bar.fill",
                    color: .blue
                )
            }
            
            // Recent Evidence
            if !progress.evidence.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Evidencia Reciente")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(progress.evidence.prefix(3)) { evidence in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(evidence.strength.color)
                            
                            Text(evidence.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Progress Stat Item
struct ProgressStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Identity Card
struct IdentityCard: View {
    let identity: HabitIdentity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: identity.category.icon)
                    .font(.title2)
                    .foregroundColor(identity.category.color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(identity.category.color.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(identity.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(identity.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text("Creada \(identity.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if identity.isActive {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: identity.category.color.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(identity.category.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Empty Identities Card
struct EmptyIdentitiesCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.dashed")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text("No tienes identidades aún")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Las identidades son la base de los hábitos duraderos. Define quién quieres ser.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("Crear identidad")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Identity Suggestion Card
struct IdentitySuggestionCard: View {
    let suggestion: IdentitySuggestion
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: suggestion.category.icon)
                    .font(.title2)
                    .foregroundColor(suggestion.category.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 4) {
                        Text("Confianza:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(suggestion.confidence.title)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(suggestion.confidence.color)
                    }
                }
                
                Spacer()
                
                Button(action: onAccept) {
                    Text("Crear")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.purple)
                        )
                }
            }
            
            Text(suggestion.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            if !suggestion.supportingHabits.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hábitos que lo apoyan:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(suggestion.supportingHabits.joined(separator: " • "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Create Identity View
struct CreateIdentityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory = IdentityCategory.presentFather
    @State private var customName = ""
    @State private var customDescription = ""
    @State private var targetHabits: [String] = []
    @State private var newHabit = ""
    
    let onSave: (HabitIdentity) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información Básica") {
                    TextField("Nombre de la identidad", text: $name)
                    
                    TextField("Descripción", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(IdentityCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                VStack(alignment: .leading) {
                                    Text(category.title)
                                    Text(category.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }.tag(category)
                        }
                    }
                }
                
                if selectedCategory == .custom {
                    Section("Identidad Personalizada") {
                        TextField("Título personalizado", text: $customName)
                        TextField("Descripción personalizada", text: $customDescription, axis: .vertical)
                    }
                }
                
                Section("Hábitos Objetivo") {
                    ForEach(targetHabits, id: \.self) { habit in
                        HStack {
                            Text(habit)
                            Spacer()
                            Button("Eliminar") {
                                targetHabits.removeAll { $0 == habit }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        TextField("Agregar hábito objetivo", text: $newHabit)
                        Button("Agregar") {
                            if !newHabit.isEmpty {
                                targetHabits.append(newHabit)
                                newHabit = ""
                            }
                        }
                        .disabled(newHabit.isEmpty)
                    }
                }
                
                Section("Vista Previa") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Identidad: \(name.isEmpty ? "Mi nueva identidad" : name)")
                            .font(.headline)
                        
                        Text(description.isEmpty ? selectedCategory.description : description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        if !targetHabits.isEmpty {
                            Text("Hábitos objetivo: \(targetHabits.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemGray6))
                    )
                }
            }
            .navigationTitle("Nueva Identidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Crear") {
                        let finalName = selectedCategory == .custom && !customName.isEmpty ? customName : name
                        let finalDescription = selectedCategory == .custom && !customDescription.isEmpty ? customDescription : description
                        
                        let identity = HabitIdentity(
                            name: finalName,
                            description: finalDescription,
                            category: selectedCategory,
                            targetHabits: targetHabits,
                            createdAt: Date()
                        )
                        
                        onSave(identity)
                        dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

// MARK: - Identity Detail View
struct IdentityDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var identityService = HabitsIdentityService.shared
    let identity: HabitIdentity
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Identity Header
                    identityHeader
                    
                    // Progress Section
                    if let progress = identityService.identityProgress[identity.id] {
                        identityProgressDetail(progress)
                    }
                    
                    // Evidence Section
                    if let progress = identityService.identityProgress[identity.id], !progress.evidence.isEmpty {
                        evidenceSection(progress.evidence)
                    }
                    
                    // Affirmations Section
                    affirmationsSection
                }
                .padding()
            }
            .navigationTitle(identity.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        identityService.setCurrentIdentity(identity)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: identityService.currentIdentity?.id == identity.id ? "checkmark.circle.fill" : "circle")
                            Text(identityService.currentIdentity?.id == identity.id ? "Activa" : "Activar")
                        }
                    }
                    .foregroundColor(identityService.currentIdentity?.id == identity.id ? .green : .purple)
                }
            }
        }
    }
    
    private var identityHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: identity.category.icon)
                    .font(.title)
                    .foregroundColor(identity.category.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(identity.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(identity.category.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(identity.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            if !identity.targetHabits.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hábitos Objetivo")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(identity.targetHabits, id: \.self) { habit in
                            Text(habit)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(identity.category.color.opacity(0.1))
                                .foregroundColor(identity.category.color)
                                .cornerRadius(6)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
    
    private func identityProgressDetail(_ progress: IdentityProgress) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso de Identidad")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Strength Indicator
            HStack {
                Text("Fuerza:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: progress.strength.icon)
                        .foregroundColor(progress.strength.color)
                    
                    Text(progress.strength.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(progress.strength.color)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(progress.strength.color.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Progress Stats
            HStack(spacing: 16) {
                IdentityStatItem(
                    title: "Completados",
                    value: "\(progress.totalCompletions)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                IdentityStatItem(
                    title: "Racha Promedio",
                    value: "\(progress.averageStreak) días",
                    icon: "flame.fill",
                    color: .orange
                )
                
                IdentityStatItem(
                    title: "Consistencia",
                    value: "\(Int(progress.completionRate * 100))%",
                    icon: "chart.bar.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: identity.category.color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private func evidenceSection(_ evidence: [IdentityEvidence]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evidencia de Identidad")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(evidence) { evidenceItem in
                    EvidenceCard(evidence: evidenceItem)
                }
            }
        }
    }
    
    private var affirmationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Afirmaciones")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(identity.category.affirmations, id: \.self) { affirmation in
                    Text("• \(affirmation)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(identity.category.color.opacity(0.05))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - Supporting Views
struct IdentityStatItem: View {
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
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct EvidenceCard: View {
    let evidence: IdentityEvidence
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(evidence.strength.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(evidence.description)
                    .font(.body)
                
                HStack {
                    Text(evidence.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(evidence.strength.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(evidence.strength.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(evidence.strength.color.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: evidence.strength.color.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

#Preview {
    HabitsIdentityView()
}
