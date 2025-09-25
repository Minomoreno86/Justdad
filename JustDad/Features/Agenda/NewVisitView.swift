//
//  NewVisitView.swift
//  JustDad - New Visit Creation Form
//
//  Comprehensive form for creating new visits with validation
//

import SwiftUI

struct NewVisitView: View {
    @Environment(\.dismiss) private var dismiss
    
    let initialDate: Date
    let onSave: (AgendaVisit) -> Void
    
    @State private var title = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var location = ""
    @State private var notes = ""
    @State private var visitType: AgendaVisitType = .general
    @State private var reminderMinutes: Int? = 30
    @State private var isRecurring = false
    @State private var recurrenceRule: RecurrenceRule? = nil
    
    @State private var showingReminderPicker = false
    @State private var showingRecurrencePicker = false
    
    private var isValid: Bool {
        !title.isEmpty && startDate < endDate
    }
    
    init(initialDate: Date = Date(), onSave: @escaping (AgendaVisit) -> Void) {
        self.initialDate = initialDate
        self.onSave = onSave
        
        // Initialize dates
        self._startDate = State(initialValue: initialDate)
        self._endDate = State(initialValue: Calendar.current.date(byAdding: .hour, value: 2, to: initialDate) ?? initialDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Information Section
                basicInformationSection
                
                // Date and Time Section
                dateTimeSection
                
                // Visit Type Section
                visitTypeSection
                
                // Location Section
                locationSection
                
                // Reminders Section
                remindersSection
                
                // Recurrence Section
                recurrenceSection
                
                // Notes Section
                notesSection
            }
            .navigationTitle(NSLocalizedString("new_visit.title", comment: "New Visit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "Save")) {
                        saveVisit()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Form Sections
    
    private var basicInformationSection: some View {
        Section {
            TextField(
                NSLocalizedString("visit.title.placeholder", comment: "Visit title"),
                text: $title
            )
            .autocorrectionDisabled()
        } header: {
            Text(NSLocalizedString("visit.basic_info", comment: "Basic Information"))
        }
    }
    
    private var dateTimeSection: some View {
        Section {
            DatePicker(
                NSLocalizedString("visit.start_date", comment: "Start Date"),
                selection: $startDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: startDate) { _, newValue in
                // Auto-adjust end date if it's before start date
                if endDate <= newValue {
                    endDate = Calendar.current.date(byAdding: .hour, value: 2, to: newValue) ?? newValue
                }
            }
            
            DatePicker(
                NSLocalizedString("visit.end_date", comment: "End Date"),
                selection: $endDate,
                in: startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
        } header: {
            Text(NSLocalizedString("visit.date_time", comment: "Date & Time"))
        } footer: {
            if startDate >= endDate {
                Label(
                    NSLocalizedString("visit.date_validation", comment: "End date must be after start date"),
                    systemImage: "exclamationmark.triangle"
                )
                .foregroundColor(.red)
                .font(.caption)
            }
        }
    }
    
    private var visitTypeSection: some View {
        Section {
            Picker(NSLocalizedString("visit.type", comment: "Visit Type"), selection: $visitType) {
                ForEach(AgendaVisitType.allCases, id: \.self) { type in
                    Label(type.displayName, systemImage: type.systemIcon)
                        .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
        } header: {
            Text(NSLocalizedString("visit.type_section", comment: "Visit Type"))
        }
    }
    
    private var locationSection: some View {
        Section {
            TextField(
                NSLocalizedString("visit.location.placeholder", comment: "Location (optional)"),
                text: $location
            )
            .autocorrectionDisabled()
        } header: {
            Text(NSLocalizedString("visit.location", comment: "Location"))
        }
    }
    
    private var remindersSection: some View {
        Section {
            HStack {
                Text(NSLocalizedString("visit.reminder", comment: "Reminder"))
                
                Spacer()
                
                Button(reminderText) {
                    showingReminderPicker = true
                }
                .foregroundColor(.blue)
            }
        } header: {
            Text(NSLocalizedString("visit.reminders", comment: "Reminders"))
        } footer: {
            Text(NSLocalizedString("visit.reminder.footer", comment: "Get notified before your visit starts"))
        }
        .sheet(isPresented: $showingReminderPicker) {
            ReminderPickerView(selectedMinutes: $reminderMinutes)
        }
    }
    
    private var recurrenceSection: some View {
        Section {
            Toggle(NSLocalizedString("visit.recurring", comment: "Recurring Visit"), isOn: $isRecurring)
            
            if isRecurring {
                HStack {
                    Text(NSLocalizedString("visit.repeat", comment: "Repeat"))
                    
                    Spacer()
                    
                    Button(recurrenceText) {
                        showingRecurrencePicker = true
                    }
                    .foregroundColor(.blue)
                }
            }
        } header: {
            Text(NSLocalizedString("visit.recurrence", comment: "Recurrence"))
        } footer: {
            if isRecurring {
                Text(NSLocalizedString("visit.recurrence.footer", comment: "This visit will repeat automatically"))
            }
        }
        .sheet(isPresented: $showingRecurrencePicker) {
            RecurrencePickerView(selectedRule: $recurrenceRule)
        }
    }
    
    private var notesSection: some View {
        Section {
            TextField(
                NSLocalizedString("visit.notes.placeholder", comment: "Additional notes (optional)"),
                text: $notes,
                axis: .vertical
            )
            .lineLimit(3...6)
        } header: {
            Text(NSLocalizedString("visit.notes", comment: "Notes"))
        }
    }
    
    // MARK: - Computed Properties
    
    private var reminderText: String {
        guard let reminderMinutes = reminderMinutes else {
            return NSLocalizedString("reminder.none", comment: "None")
        }
        
        if reminderMinutes < 60 {
            let format = NSLocalizedString("reminder.minutes", comment: "%d minutes before")
            return String(format: format, reminderMinutes)
        } else {
            let hours = reminderMinutes / 60
            let format = NSLocalizedString("reminder.hours", comment: "%d hours before")
            return String(format: format, hours)
        }
    }
    
    private var recurrenceText: String {
        recurrenceRule?.displayName ?? NSLocalizedString("recurrence.weekly", comment: "Weekly")
    }
    
    // MARK: - Actions
    
    private func saveVisit() {
        let visit = AgendaVisit(
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            reminderMinutes: reminderMinutes,
            isRecurring: isRecurring,
            recurrenceRule: isRecurring ? (recurrenceRule ?? .weekly) : nil,
            visitType: visitType
        )
        
        onSave(visit)
        dismiss()
    }
}

// MARK: - Reminder Picker View

struct ReminderPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMinutes: Int?
    
    private let reminderOptions: [(Int?, String)] = [
        (nil, NSLocalizedString("reminder.none", comment: "None")),
        (0, NSLocalizedString("reminder.at_time", comment: "At time of event")),
        (5, NSLocalizedString("reminder.5_minutes", comment: "5 minutes before")),
        (15, NSLocalizedString("reminder.15_minutes", comment: "15 minutes before")),
        (30, NSLocalizedString("reminder.30_minutes", comment: "30 minutes before")),
        (60, NSLocalizedString("reminder.1_hour", comment: "1 hour before")),
        (120, NSLocalizedString("reminder.2_hours", comment: "2 hours before")),
        (1440, NSLocalizedString("reminder.1_day", comment: "1 day before"))
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(reminderOptions, id: \.0) { option in
                    Button(action: {
                        selectedMinutes = option.0
                        dismiss()
                    }) {
                        HStack {
                            Text(option.1)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedMinutes == option.0 {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("select_reminder", comment: "Select Reminder"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "Done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Recurrence Picker View

struct RecurrencePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRule: RecurrenceRule?
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(RecurrenceRule.Frequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        selectedRule = RecurrenceRule(frequency: frequency)
                        dismiss()
                    }) {
                        HStack {
                            Text(frequency.displayName)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedRule?.frequency == frequency {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("select_recurrence", comment: "Select Recurrence"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("done", comment: "Done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewVisitView { visit in
        print("Saving visit: \(visit.title)")
    }
}
