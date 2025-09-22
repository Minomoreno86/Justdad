import SwiftUI

// MARK: - Member Edit View
struct MemberEditView: View {
    let member: FamilyMember
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @Environment(\.dismiss) private var dismiss
    
    @State private var givenName: String
    @State private var familyName: String
    @State private var birthDate: Date?
    @State private var deathDate: Date?
    @State private var sex: Sex
    @State private var notes: String
    @State private var showingDatePicker = false
    @State private var datePickerType: DatePickerType = .birth
    
    enum DatePickerType {
        case birth, death
    }
    
    init(member: FamilyMember, psychogenealogyService: PsychogenealogyService) {
        self.member = member
        self.psychogenealogyService = psychogenealogyService
        self._givenName = State(initialValue: member.givenName)
        self._familyName = State(initialValue: member.familyName)
        self._birthDate = State(initialValue: member.birthDate)
        self._deathDate = State(initialValue: member.deathDate)
        self._sex = State(initialValue: member.sex)
        self._notes = State(initialValue: member.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Personal") {
                    HStack {
                        Text("Nombre")
                        Spacer()
                        TextField("Nombre", text: $givenName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Apellido")
                        Spacer()
                        TextField("Apellido", text: $familyName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Sexo", selection: $sex) {
                        Text("Hombre").tag(Sex.male)
                        Text("Mujer").tag(Sex.female)
                    }
                }
                
                Section("Fechas") {
                    Button("Fecha de Nacimiento") {
                        datePickerType = .birth
                        showingDatePicker = true
                    }
                    .foregroundColor(.primary)
                    
                    if let birthDate = birthDate {
                        HStack {
                            Text("Nacimiento")
                            Spacer()
                            Text(birthDate, style: .date)
                                .foregroundColor(.secondary)
                            Button("Eliminar") {
                                self.birthDate = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    Button("Fecha de Fallecimiento") {
                        datePickerType = .death
                        showingDatePicker = true
                    }
                    .foregroundColor(.primary)
                    
                    if let deathDate = deathDate {
                        HStack {
                            Text("Fallecimiento")
                            Spacer()
                            Text(deathDate, style: .date)
                                .foregroundColor(.secondary)
                            Button("Eliminar") {
                                self.deathDate = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Notas") {
                    TextField("Notas adicionales...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Eventos") {
                    Text("Los eventos se gestionan desde el servicio principal")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("Editar Miembro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(
                date: datePickerType == .birth ? $birthDate : $deathDate,
                title: datePickerType == .birth ? "Fecha de Nacimiento" : "Fecha de Fallecimiento"
            )
        }
    }
    
    private func saveChanges() {
        // Update member with new values
        let updatedMember = FamilyMember(
            givenName: givenName,
            familyName: familyName,
            sex: sex,
            birthDate: birthDate,
            deathDate: deathDate,
            notes: notes,
            tags: member.tags,
            isAlive: member.isAlive,
            isPresent: member.isPresent
        )
        
        psychogenealogyService.updateMember(updatedMember)
        dismiss()
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var date: Date?
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate: Date = Date()
    @State private var hasDate: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(title)
                    .font(.headline)
                    .padding()
                
                Toggle("Tiene \(title.lowercased())", isOn: $hasDate)
                    .padding(.horizontal)
                
                if hasDate {
                    DatePicker(
                        "Seleccionar fecha",
                        selection: $tempDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding()
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        date = hasDate ? tempDate : nil
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let existingDate = date {
                tempDate = existingDate
                hasDate = true
            }
        }
    }
}


// MARK: - Preview
#Preview {
    MemberEditView(
        member: FamilyMember(
            givenName: "Juan",
            familyName: "Pérez",
            sex: .male,
            birthDate: Date(),
            deathDate: nil,
            notes: "Padre de familia",
            tags: [],
            isAlive: true,
            isPresent: true
        ),
        psychogenealogyService: PsychogenealogyService.shared
    )
}
