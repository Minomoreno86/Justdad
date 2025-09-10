import SwiftUI
import SwiftData

struct EditVisitView: View {
    @StateObject private var viewModel = EditVisitViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Optional CoreData Visit for editing existing visits
    private let coreDataVisit: Visit?
    
    // Callbacks for visit operations
    let onSave: ((AgendaVisit) -> Void)?
    let onDelete: ((UUID) -> Void)?
    
    // MARK: - Initializers
    init(
        visit: Visit? = nil,
        onSave: ((AgendaVisit) -> Void)? = nil,
        onDelete: ((UUID) -> Void)? = nil
    ) {
        self.coreDataVisit = visit
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    titleSection
                    datesSection
                    locationSection
                    visitTypeSection
                    recurrenceSection
                    reminderSection
                    notesSection
                }
                .padding()
            }
            .navigationTitle(viewModel.isEditing ? "Editar Visita" : "Nueva Visita")
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
                    .disabled(!viewModel.canSave)
                    .fontWeight(.semibold)
                }
                
                if viewModel.isEditing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Eliminar", role: .destructive) {
                            deleteVisit()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showingAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.alertMessage)
            }
            .onAppear {
                if let coreDataVisit = coreDataVisit {
                    viewModel.loadVisit(AgendaVisit(coreData: coreDataVisit))
                }
            }
        }
    }
    
    // MARK: - View Sections
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Título")
                .font(.headline)
            
            TextField("Título de la visita", text: $viewModel.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fechas y Horarios")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Inicio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $viewModel.startDate)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Fin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $viewModel.endDate)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ubicación")
                .font(.headline)
            
            TextField("Ubicación (opcional)", text: $viewModel.location)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var visitTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Visita")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(AgendaVisitType.allCases, id: \.self) { type in
                    VisitTypeButton(
                        type: type,
                        isSelected: viewModel.visitType == type
                    ) {
                        viewModel.visitType = type
                    }
                }
            }
        }
    }
    
    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Repetir visita", isOn: $viewModel.isRecurring)
                .font(.headline)
            
            if viewModel.isRecurring {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frecuencia")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Frecuencia", selection: $viewModel.recurrenceRule.frequency) {
                        ForEach(RecurrenceRule.Frequency.allCases, id: \.self) { frequency in
                            if frequency != .none {
                                Text(frequency.displayName).tag(frequency)
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recordatorio")
                .font(.headline)
            
            Picker("Recordatorio", selection: $viewModel.reminderMinutes) {
                ForEach(viewModel.reminderOptions, id: \.self) { minutes in
                    Text(viewModel.reminderDisplayText(for: minutes)).tag(minutes)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notas")
                .font(.headline)
            
            TextField("Notas adicionales (opcional)", text: $viewModel.notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Actions
    private func saveVisit() {
        let agendaVisit = viewModel.createAgendaVisit()
        
        // Call the provided save callback
        onSave?(agendaVisit)
        
        // For CoreData integration, create/update Visit entity
        if let coreDataVisit = coreDataVisit {
            // Update existing Visit
            updateCoreDataVisit(coreDataVisit, with: agendaVisit)
        } else {
            // Create new Visit
            let newVisit = Visit(from: agendaVisit)
            modelContext.insert(newVisit)
        }
        
        // Save context
        do {
            try modelContext.save()
            dismiss()
        } catch {
            viewModel.showAlert(message: "Error al guardar: \(error.localizedDescription)")
        }
    }
    
    private func deleteVisit() {
        guard let coreDataVisit = coreDataVisit else { return }
        
        // Call the provided delete callback
        onDelete?(coreDataVisit.id)
        
        // Delete from CoreData
        modelContext.delete(coreDataVisit)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            viewModel.showAlert(message: "Error al eliminar: \(error.localizedDescription)")
        }
    }
    
    private func updateCoreDataVisit(_ visit: Visit, with agendaVisit: AgendaVisit) {
        visit.title = agendaVisit.title
        visit.startDate = agendaVisit.startDate
        visit.endDate = agendaVisit.endDate
        visit.location = agendaVisit.location
        visit.notes = agendaVisit.notes
        
        // Direct mapping - no conversion needed anymore!
        visit.type = agendaVisit.visitType
        
        visit.updatedAt = Date()
    }
}

// MARK: - Supporting Views
struct VisitTypeButton: View {
    let type: AgendaVisitType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.systemIcon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color(type.color))
                
                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(type.color) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(type.color), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    EditVisitView()
}
