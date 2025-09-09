//
//  EditVisitView.swift
//  JustDad - Edit Visit Form
//
//  Edit existing visits with validation and delete functionality
//

import SwiftUI

struct EditVisitView: View {
    @Environment(\.dismiss) private var dismiss
    
    let visit: Visit
    let onSave: (Visit) -> Void
    let onDelete: () -> Void
    
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var location: String
    @State private var notes: String
    @State private var visitType: VisitType
    @State private var reminderMinutes: Int?
    @State private var isRecurring: Bool
    @State private var recurrenceRule: RecurrenceRule?
    
    @State private var showingDeleteAlert = false
    @State private var showingReminderPicker = false
    @State private var showingRecurrencePicker = false
    
    private var isValid: Bool {
        !title.isEmpty && startDate < endDate
    }
    
    init(visit: Visit, onSave: @escaping (Visit) -> Void, onDelete: @escaping () -> Void) {
        self.visit = visit
        self.onSave = onSave
        self.onDelete = onDelete
        
        // Initialize state from visit
        self._title = State(initialValue: visit.title)
        self._startDate = State(initialValue: visit.startDate)
        self._endDate = State(initialValue: visit.endDate)
        self._location = State(initialValue: visit.location ?? "")
        self._notes = State(initialValue: visit.notes ?? "")
        self._visitType = State(initialValue: visit.visitType)
        self._reminderMinutes = State(initialValue: visit.reminderMinutes)
        self._isRecurring = State(initialValue: visit.isRecurring)
        self._recurrenceRule = State(initialValue: visit.recurrenceRule)
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
                
                // Delete Section
                deleteSection
            }
            .navigationTitle(NSLocalizedString("edit_visit.title", comment: "Edit Visit"))
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
            .alert(
                NSLocalizedString("delete.visit.title", comment: "Delete Visit"),
                isPresented: $showingDeleteAlert
            ) {
                Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) { }
                Button(NSLocalizedString("delete", comment: "Delete"), role: .destructive) {
                    onDelete()
                }
            } message: {
                Text(NSLocalizedString("delete.visit.message", comment: "This action cannot be undone. The visit will be removed from your calendar."))
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
            .onChange(of: startDate) { newValue in
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
                ForEach(VisitType.allCases, id: \.self) { type in
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
    
    private var deleteSection: some View {
        Section {
            Button(action: { showingDeleteAlert = true }) {
                Label(NSLocalizedString("delete_visit", comment: "Delete Visit"), systemImage: "trash")
                    .foregroundColor(.red)
            }
        } footer: {
            Text(NSLocalizedString("delete.visit.warning", comment: "Deleting this visit will remove it from your calendar permanently."))
                .foregroundColor(.secondary)
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
        let updatedVisit = Visit(
            id: visit.id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            reminderMinutes: reminderMinutes,
            isRecurring: isRecurring,
            recurrenceRule: isRecurring ? (recurrenceRule ?? .weekly) : nil,
            visitType: visitType,
            eventKitIdentifier: visit.eventKitIdentifier
        )
        
        onSave(updatedVisit)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EditVisitView(
        visit: Visit(
            title: "Weekend with kids",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date(),
            location: "My place",
            notes: "Fun day planned",
            reminderMinutes: 60,
            visitType: .weekend
        ),
        onSave: { visit in
            print("Saving visit: \(visit.title)")
        },
        onDelete: {
            print("Deleting visit")
        }
    )
}
