import Foundation
import SwiftUI
import Combine
import SwiftData

// Explicit imports for agenda types
// This ensures all AgendaVisit, AgendaVisitType, RecurrenceRule types are available

@MainActor
class EditVisitViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var title: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(3600)
    @Published var location: String = ""
    @Published var notes: String = ""
    @Published var reminderMinutes: Int = 15
    @Published var isRecurring: Bool = false
    @Published var recurrenceRule: RecurrenceRule = RecurrenceRule(frequency: .none)
    @Published var visitType: AgendaVisitType = .activity
    
    // UI State
    @Published var showingDatePicker: Bool = false
    @Published var showingTimePicker: Bool = false
    @Published var showingAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private var originalVisit: AgendaVisit?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isEditing: Bool {
        return originalVisit != nil
    }
    
    var hasChanges: Bool {
        guard let original = originalVisit else { return true }
        
        return title != original.title ||
               startDate != original.startDate ||
               endDate != original.endDate ||
               location != (original.location ?? "") ||
               notes != (original.notes ?? "") ||
               reminderMinutes != (original.reminderMinutes ?? 15) ||
               isRecurring != original.isRecurring ||
               visitType != original.visitType
    }
    
    var canSave: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
               !isLoading &&
               startDate < endDate
    }
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    convenience init(visit: AgendaVisit) {
        self.init()
        loadVisit(visit)
    }
    
    // Compatibility init for CoreData Visit
    convenience init(coreDataVisit: Visit) {
        self.init()
        let agendaVisit = AgendaVisit(coreData: coreDataVisit)
        loadVisit(agendaVisit)
    }
    
    // MARK: - Public Methods
    func loadVisit(_ visit: AgendaVisit) {
        originalVisit = visit
        
        title = visit.title
        startDate = visit.startDate
        endDate = visit.endDate
        location = visit.location ?? ""
        notes = visit.notes ?? ""
        reminderMinutes = visit.reminderMinutes ?? 15
        isRecurring = visit.isRecurring
        recurrenceRule = visit.recurrenceRule ?? RecurrenceRule(frequency: .none)
        visitType = visit.visitType
    }
    
    func createAgendaVisit() -> AgendaVisit {
        return AgendaVisit(
            id: originalVisit?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            reminderMinutes: reminderMinutes > 0 ? reminderMinutes : nil,
            isRecurring: isRecurring,
            recurrenceRule: isRecurring ? recurrenceRule : nil,
            visitType: visitType,
            eventKitIdentifier: originalVisit?.eventKitIdentifier
        )
    }
    
    func reset() {
        guard let original = originalVisit else {
            // New visit - reset to defaults
            title = ""
            startDate = Date()
            endDate = Date().addingTimeInterval(3600)
            location = ""
            notes = ""
            reminderMinutes = 15
            isRecurring = false
            recurrenceRule = RecurrenceRule(frequency: .none)
            visitType = .activity
            return
        }
        
        // Existing visit - reset to original values
        loadVisit(original)
    }
    
    func showAlert(message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Auto-adjust end date when start date changes
        $startDate
            .sink { [weak self] newStartDate in
                guard let self = self else { return }
                if self.endDate <= newStartDate {
                    self.endDate = newStartDate.addingTimeInterval(3600) // Add 1 hour
                }
            }
            .store(in: &cancellables)
        
        // Reset recurrence rule when isRecurring is turned off
        $isRecurring
            .sink { [weak self] isRecurring in
                guard let self = self else { return }
                if !isRecurring {
                    self.recurrenceRule = RecurrenceRule(frequency: .none)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Extensions
extension EditVisitViewModel {
    var reminderOptions: [Int] {
        return [0, 5, 10, 15, 30, 60, 120, 1440] // minutes
    }
    
    func reminderDisplayText(for minutes: Int) -> String {
        switch minutes {
        case 0: return NSLocalizedString("reminder.none", comment: "No reminder")
        case 5: return NSLocalizedString("reminder.5min", comment: "5 minutes before")
        case 10: return NSLocalizedString("reminder.10min", comment: "10 minutes before")
        case 15: return NSLocalizedString("reminder.15min", comment: "15 minutes before")
        case 30: return NSLocalizedString("reminder.30min", comment: "30 minutes before")
        case 60: return NSLocalizedString("reminder.1hour", comment: "1 hour before")
        case 120: return NSLocalizedString("reminder.2hours", comment: "2 hours before")
        case 1440: return NSLocalizedString("reminder.1day", comment: "1 day before")
        default: return "\(minutes) min"
        }
    }
}
