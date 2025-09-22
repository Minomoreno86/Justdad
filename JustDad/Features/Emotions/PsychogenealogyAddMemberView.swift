//
//  PsychogenealogyAddMemberView.swift
//  JustDad - Add Family Member View
//
//  Vista para agregar miembros de la familia
//  Created by Jorge Vasquez Rodriguez
//

import SwiftUI

enum FamilyEmotionalConnection: String, CaseIterable {
    case veryPositive = "very_positive"
    case positive = "positive"
    case neutral = "neutral"
    case negative = "negative"
    case veryNegative = "very_negative"
    case complicated = "complicated"
    
    var displayName: String {
        switch self {
        case .veryPositive: return "Muy Positiva"
        case .positive: return "Positiva"
        case .neutral: return "Neutral"
        case .negative: return "Negativa"
        case .veryNegative: return "Muy Negativa"
        case .complicated: return "Complicada"
        }
    }
    
    var color: Color {
        switch self {
        case .veryPositive: return .green
        case .positive: return .mint
        case .neutral: return .gray
        case .negative: return .orange
        case .veryNegative: return .red
        case .complicated: return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .veryPositive: return "heart.fill"
        case .positive: return "heart"
        case .neutral: return "circle"
        case .negative: return "heart.slash"
        case .veryNegative: return "heart.slash.fill"
        case .complicated: return "heart.text.square"
        }
    }
}

struct AddFamilyMemberView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var psychogenealogyService = PsychogenealogyService.shared
    
    @State private var name: String = ""
    @State private var relationship: RelationshipType = .parent
    @State private var birthDate: Date?
    @State private var deathDate: Date?
    @State private var hasPassedAway: Bool = false
    @State private var isPresent: Bool = true
    @State private var emotionalConnection: FamilyEmotionalConnection = .neutral
    @State private var notes: String = ""
    @State private var events: [FamilyEvent] = []
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.purple.opacity(0.8), .indigo.opacity(0.6), .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        headerView
                        basicInfoSection
                        datesSection
                        emotionalConnectionSection
                        eventsSection
                        notesSection
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Agregar Miembro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(events: $events)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50, weight: .medium))
                .foregroundColor(.white)
            
            Text("Nuevo Miembro de la Familia")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Agrega información sobre un miembro de tu familia para comenzar a identificar patrones transgeneracionales.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Información Básica")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Name
                VStack(alignment: .leading, spacing: 5) {
                    Text("Nombre")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    TextField("Nombre del familiar", text: $name)
                        .textFieldStyle(PsychogenealogyTextFieldStyle())
                }
                
                // Relationship
                VStack(alignment: .leading, spacing: 5) {
                    Text("Relación")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Picker("Relación", selection: $relationship) {
                        ForEach(RelationshipType.allCases, id: \.self) { rel in
                            Text(rel.displayName).tag(rel)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Present Toggle
                VStack(alignment: .leading, spacing: 5) {
                    Text("¿Está presente en tu vida?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        Toggle("Presente", isOn: $isPresent)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        
                        Spacer()
                        
                        Text(isPresent ? "Sí" : "No")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isPresent ? .green : .red)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Dates Section
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Fechas Importantes")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                // Birth Date
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gift.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        
                        Text("Fecha de Nacimiento")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("(opcional)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    DatePicker("Fecha de Nacimiento", selection: Binding(
                        get: { birthDate ?? Date() },
                        set: { birthDate = $0 }
                    ), displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .colorScheme(.dark)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Death Status Toggle
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: hasPassedAway ? "cross.fill" : "heart.fill")
                            .foregroundColor(hasPassedAway ? .red : .green)
                            .font(.system(size: 16))
                        
                        Text("Estado")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Toggle("", isOn: $hasPassedAway)
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                    }
                    
                    Text(hasPassedAway ? "Ha fallecido" : "Aún vive")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(hasPassedAway ? .red.opacity(0.8) : .green.opacity(0.8))
                        .padding(.leading, 24)
                }
                
                // Death Date (only if hasPassedAway is true)
                if hasPassedAway {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cross.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 16))
                            
                            Text("Fecha de Fallecimiento")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        DatePicker("Fecha de Fallecimiento", selection: Binding(
                            get: { deathDate ?? Date() },
                            set: { deathDate = $0 }
                        ), displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .colorScheme(.dark)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Emotional Connection Section
    private var emotionalConnectionSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Conexión Emocional")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text("¿Cómo es tu relación emocional con esta persona?")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(FamilyEmotionalConnection.allCases, id: \.self) { connection in
                    Button {
                        emotionalConnection = connection
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: connection.icon)
                                .font(.system(size: 20))
                                .foregroundColor(emotionalConnection == connection ? .white : connection.color)
                            
                            Text(connection.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(emotionalConnection == connection ? connection.color : Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(connection.color.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Events Section
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            eventsHeader
            eventsContent
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var eventsHeader: some View {
        HStack {
            Text("Eventos Familiares")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                showingAddEvent = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
        }
    }
    
    @ViewBuilder
    private var eventsContent: some View {
        if events.isEmpty {
            emptyEventsView
        } else {
            eventsList
        }
    }
    
    private var emptyEventsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 30))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No hay eventos registrados")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Los eventos son importantes para detectar patrones familiares")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var eventsList: some View {
        ForEach(events) { event in
            eventRow(event)
        }
    }
    
    private func eventRow(_ event: FamilyEvent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12))
                
                Text(event.kind.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let date = event.date {
                    Text(date, style: .date)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("Sin fecha")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            if !event.notes.isEmpty {
                Text(event.notes)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            HStack {
                Text("Severidad: \(event.severity)/5")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                if event.isSecret {
                    HStack(spacing: 4) {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 10))
                        Text("Secreto")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Notas Adicionales")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("Agrega notas sobre esta persona...", text: $notes, axis: .vertical)
                .textFieldStyle(PsychogenealogyTextFieldStyle())
                .lineLimit(4...8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            saveMember()
        } label: {
            Text("Guardar Miembro")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(name.isEmpty)
        .opacity(name.isEmpty ? 0.6 : 1.0)
    }
    
    // MARK: - Actions
    private func saveMember() {
        let member = FamilyMember(
            givenName: name,
            familyName: "",
            sex: relationship == .parent ? .male : .female,
            birthDate: birthDate,
            deathDate: hasPassedAway ? deathDate : nil, // Solo incluir deathDate si ha fallecido
            notes: notes,
            isPresent: isPresent
        )
        
        psychogenealogyService.addFamilyMember(member)
        dismiss()
    }
}

// MARK: - Add Event View
struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var events: [FamilyEvent]
    
    @State private var eventType: EventKind = .success
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var impact: Int = 3
    @State private var isSecret: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.purple.opacity(0.8), .indigo.opacity(0.6), .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        eventTypeSection
                        dateSection
                        descriptionSection
                        impactSection
                        secretSection
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Agregar Evento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(.white)
            
            Text("Nuevo Evento Familiar")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var eventTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Evento")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(EventKind.allCases, id: \.self) { eventKind in
                    Button {
                        self.eventType = eventKind
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(self.eventType == eventKind ? .white : .yellow)
                            Text(eventKind.rawValue.capitalized)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(self.eventType == eventKind ? Color.yellow : Color.white.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fecha del Evento")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            DatePicker("Fecha", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .colorScheme(.dark)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Descripción")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            TextField("Describe el evento...", text: $description, axis: .vertical)
                .textFieldStyle(PsychogenealogyTextFieldStyle())
                .lineLimit(3...6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Impacto")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach([1, 2, 3, 4, 5], id: \.self) { impact in
                    Button {
                        self.impact = impact
                    } label: {
                        Text("\(impact)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(self.impact == impact ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var secretSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("¿Es un secreto familiar?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            HStack {
                Toggle("Secreto familiar", isOn: $isSecret)
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                
                Spacer()
                
                Text(isSecret ? "Sí" : "No")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSecret ? .orange : .white.opacity(0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var saveButton: some View {
        Button {
            saveEvent()
        } label: {
            Text("Guardar Evento")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
        }
        .disabled(description.isEmpty)
        .opacity(description.isEmpty ? 0.6 : 1.0)
    }
    
    private func saveEvent() {
        let event = FamilyEvent(
            lineage: .paternal,
            kind: eventType,
            date: date,
            severity: impact,
            notes: description,
            isSecret: isSecret
        )
        
        events.append(event)
        dismiss()
    }
}

// MARK: - Text Field Style
struct PsychogenealogyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .foregroundColor(.white)
    }
}

#Preview {
    AddFamilyMemberView()
}
