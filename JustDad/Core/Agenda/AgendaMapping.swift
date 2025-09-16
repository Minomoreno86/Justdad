import Foundation

/// Simplified bridge between AgendaVisit and Core Data Visit models.
/// Now both use AgendaVisitType, so mapping is direct and simple.
extension AgendaVisit {
    init(coreData v: Visit) {
        self.init(
            id: v.id,                           // UUID exists in both models
            title: v.title,
            startDate: v.startDate,
            endDate: v.endDate,
            location: v.location,
            notes: v.notes,
            // Advanced fields not yet in CoreData model:
            reminderMinutes: nil,               // TODO: add when exists in CD
            isRecurring: false,                 // TODO
            recurrenceRule: nil,                // TODO
            visitType: AgendaVisitType(rawValue: v.type) ?? .general,  // Convert String to enum
            eventKitIdentifier: nil             // TODO
        )
    }
}

extension Visit {
    /// Creates a Core Data Visit entity from an AgendaVisit.
    /// Uses only the confirmed init fields available today.
    convenience init(from av: AgendaVisit) {
        self.init(
            title: av.title,
            startDate: av.startDate,
            endDate: av.endDate,
            type: av.visitType.rawValue,        // Convert enum to String
            location: av.location,
            notes: av.notes
        )

        // Set the id if your @Model Visit has it
        self.id = av.id

        // TODO future fields (only when they exist in the CD model):
        // self.reminderMinutes = Int64(av.reminderMinutes ?? 0)
        // self.isRecurring = av.isRecurring
        // if let rule = av.recurrenceRule { ... }
        // self.eventKitIdentifier = av.eventKitIdentifier
    }
}

// Static utility functions for conversion
struct AgendaMapping {
    static func convertToVisit(from agendaVisit: AgendaVisit) -> Visit {
        return Visit(from: agendaVisit)
    }
    
    static func convertToAgendaVisit(from visit: Visit) -> AgendaVisit {
        return AgendaVisit(
            id: visit.id ?? UUID(),
            title: visit.title ?? "",
            startDate: visit.startDate ?? Date(),
            endDate: visit.endDate ?? Date(),
            location: visit.location,
            notes: visit.notes,
            reminderMinutes: nil,               // TODO: add when exists in CD
            isRecurring: false,                 // TODO
            recurrenceRule: nil,                // TODO
            visitType: AgendaVisitType(rawValue: visit.type) ?? .general,  // Convert String to enum
            eventKitIdentifier: nil             // TODO
        )
    }
}
