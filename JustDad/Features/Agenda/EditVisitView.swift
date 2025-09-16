//
//  EditVisitView.swift
//  JustDad - Professional Visit Editing
//
//  Created by GitHub Copilot on 9/15/25.
//

import SwiftUI

struct EditVisitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var visitType: AgendaVisitType
    @State private var location: String
    @State private var notes: String
    @State private var reminderMinutes: Int?
    @State private var isRecurring: Bool
    @State private var showingDeleteAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    let visit: AgendaVisit
    let onSave: (AgendaVisit) -> Void
    let onDelete: (AgendaVisit) -> Void
    
    init(visit: AgendaVisit, onSave: @escaping (AgendaVisit) -> Void, onDelete: @escaping (AgendaVisit) -> Void) {
        self.visit = visit
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Initialize state with visit data
        _title = State(initialValue: visit.title)
        _startDate = State(initialValue: visit.startDate)
        _endDate = State(initialValue: visit.endDate)
        _visitType = State(initialValue: visit.visitType)
        _location = State(initialValue: visit.location ?? "")
        _notes = State(initialValue: visit.notes ?? "")
        _reminderMinutes = State(initialValue: visit.reminderMinutes)
        _isRecurring = State(initialValue: visit.isRecurring)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Basic Information Section
                Section("Información Básica") {
                    TextField("Título de la visita", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Picker("Tipo de visita", selection: $visitType) {
                        ForEach(AgendaVisitType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Date & Time Section
                Section("Fecha y Hora") {
                    DatePicker("Fecha y hora de inicio", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Fecha y hora de fin", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    
                    if startDate >= endDate {
                        Label("La hora de fin debe ser posterior a la de inicio", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // Location Section
                Section("Ubicación") {
                    TextField("Ubicación (opcional)", text: $location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Notes Section
                Section("Notas") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // Reminder Section
                Section("Recordatorio") {
                    Toggle("Activar recordatorio", isOn: Binding(
                        get: { reminderMinutes != nil },
                        set: { enabled in
                            reminderMinutes = enabled ? 15 : nil
                        }
                    ))
                    
                    if reminderMinutes != nil {
                        Picker("Tiempo de anticipación", selection: Binding(
                            get: { reminderMinutes ?? 15 },
                            set: { reminderMinutes = $0 }
                        )) {
                            Text("5 minutos").tag(5)
                            Text("15 minutos").tag(15)
                            Text("30 minutos").tag(30)
                            Text("1 hora").tag(60)
                            Text("2 horas").tag(120)
                            Text("1 día").tag(1440)
                        }
                    }
                }
                
                // Recurrence Section
                Section("Repetición") {
                    Toggle("Visita recurrente", isOn: $isRecurring)
                    
                    if isRecurring {
                        Text("Configuración de repetición disponible próximamente")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Danger Zone
                Section {
                    Button(action: { showingDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Eliminar Visita")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Editar Visita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveVisit()
                    }
                    .disabled(title.isEmpty || startDate >= endDate || isSaving)
                    .opacity(isSaving ? 0.6 : 1.0)
                }
            }
        }
        .alert("Eliminar Visita", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onDelete(visit)
                dismiss()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta visita? Esta acción no se puede deshacer.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: startDate) { newValue in
            // Auto-adjust end date if it becomes invalid
            if endDate <= newValue {
                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue) ?? newValue
            }
        }
    }
    
    private func saveVisit() {
        guard !title.isEmpty else {
            errorMessage = "El título es obligatorio"
            showingErrorAlert = true
            return
        }
        
        guard startDate < endDate else {
            errorMessage = "La fecha de fin debe ser posterior a la de inicio"
            showingErrorAlert = true
            return
        }
        
        isSaving = true
        
        let updatedVisit = AgendaVisit(
            id: visit.id, // Keep the same ID
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            location: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
            reminderMinutes: reminderMinutes,
            isRecurring: isRecurring,
            recurrenceRule: isRecurring ? RecurrenceRule() : nil,
            visitType: visitType,
            eventKitIdentifier: visit.eventKitIdentifier
        )
        
        onSave(updatedVisit)
        dismiss()
    }
}

// MARK: - Preview
struct EditVisitView_Previews: PreviewProvider {
    static var previews: some View {
        EditVisitView(
            visit: AgendaVisit(
                title: "Visita de ejemplo",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
                visitType: .weekend
            ),
            onSave: { _ in },
            onDelete: { _ in }
        )
    }
}

// MARK: - Preview
#Preview {
    EditVisitView(
        visit: AgendaVisit(
            id: UUID(),
            title: "Visita médica de ejemplo",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600), // 1 hora después
            location: "Hospital Central",
            notes: "Revisión general",
            reminderMinutes: 15,
            isRecurring: false,
            recurrenceRule: nil,
            visitType: .medical
        ),
        onSave: { _ in },
        onDelete: { _ in }
    )
}
