import Foundation
import Combine

@MainActor
final class AgendaViewModel: ObservableObject {
    @Published var currentMonth: Date
    @Published var selectedDate: Date
    @Published private(set) var visitsByDay: [Date: [AgendaVisit]] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Enhanced Loading States
    @Published private(set) var loadingState: LoadingState = .idle
    @Published private(set) var operationInProgress: OperationType? = nil
    @Published private(set) var lastError: Error? = nil
    @Published private(set) var retryCount: Int = 0
    
    // MARK: - Data Properties
    @Published private(set) var allVisits: [AgendaVisit] = []
    @Published private(set) var syncStatus: SyncStatus = .idle
    @Published private(set) var lastSyncDate: Date? = nil

    private let repo: AgendaRepositoryProtocol
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    private let cal = Calendar.current
    private let maxRetryAttempts = 3

    init(repo: AgendaRepositoryProtocol,
         initialMonth: Date = Date(),
         initialSelected: Date = Calendar.current.startOfDay(for: Date())) {
        self.repo = repo
        self.currentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: initialMonth)) ?? Date()
        self.selectedDate = Calendar.current.startOfDay(for: initialSelected)
        
        // Load initial data
        Task {
            await loadAllData()
        }
    }

    // MARK: - Data Loading
    func loadAllData() async {
        await performOperation(.loadMonth) { [self] in
            // Load all visits from the past year to the next year
            let startDate = cal.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            let endDate = cal.date(byAdding: .year, value: 1, to: Date()) ?? Date()
            let range = DateInterval(start: startDate, end: endDate)
            
            let visits = try await repo.getVisits(in: range)
            
            // Group visits by day
            var groupedVisits: [Date: [AgendaVisit]] = [:]
            for visit in visits {
                let day = cal.startOfDay(for: visit.startDate)
                groupedVisits[day, default: []].append(visit)
            }
            
            // Sort visits within each day
            for (day, dayVisits) in groupedVisits {
                groupedVisits[day] = dayVisits.sorted { $0.startDate < $1.startDate }
            }
            
            self.visitsByDay = groupedVisits
            self.allVisits = visitsByDay.values.flatMap { $0 } // Update allVisits
            
            // Schedule notifications for all visits
            await notificationService.rescheduleAllVisitReminders(for: allVisits)
        }
    }
    
    func loadMonth() async {
        await performOperation(.loadMonth) { [self] in
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: currentMonth))!
            let monthEnd = cal.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) ?? monthStart
            let range = DateInterval(start: monthStart.startOfDay(cal), end: monthEnd.endOfDay(cal))
            
            let visits = try await repo.getVisits(in: range)
            
            // Group visits by day
            var groupedVisits: [Date: [AgendaVisit]] = [:]
            for visit in visits {
                let day = cal.startOfDay(for: visit.startDate)
                groupedVisits[day, default: []].append(visit)
            }
            
            // Sort visits within each day
            for (day, dayVisits) in groupedVisits {
                groupedVisits[day] = dayVisits.sorted { $0.startDate < $1.startDate }
            }
            
            self.visitsByDay = groupedVisits
            self.allVisits = visitsByDay.values.flatMap { $0 } // Update allVisits
        }
    }
    
    // MARK: - CRUD Operations
    func addVisit(_ visit: AgendaVisit) async {
        await performOperation(.addVisit) { [self] in
            let savedVisit = try await repo.createVisit(visit)
            
            // Update local state
            let day = cal.startOfDay(for: savedVisit.startDate)
            visitsByDay[day, default: []].append(savedVisit)
            visitsByDay[day] = visitsByDay[day]?.sorted { $0.startDate < $1.startDate }
            
            // Update all visits
            allVisits = visitsByDay.values.flatMap { $0 }
            
            // Schedule notification for the new visit
            await notificationService.scheduleVisitReminder(for: savedVisit)
        }
    }
    
    func updateVisit(_ visit: AgendaVisit) async {
        await performOperation(.updateVisit) { [self] in
            let updatedVisit = try await repo.updateVisit(visit)
            
            // Remove from old day if date changed
            for (day, visits) in visitsByDay {
                if let index = visits.firstIndex(where: { $0.id == visit.id }) {
                    visitsByDay[day]?.remove(at: index)
                    if visitsByDay[day]?.isEmpty == true {
                        visitsByDay.removeValue(forKey: day)
                    }
                    break
                }
            }
            
            // Add to new day
            let newDay = cal.startOfDay(for: updatedVisit.startDate)
            visitsByDay[newDay, default: []].append(updatedVisit)
            visitsByDay[newDay] = visitsByDay[newDay]?.sorted { $0.startDate < $1.startDate }
            
            // Update all visits
            allVisits = visitsByDay.values.flatMap { $0 }
            
            // Reschedule notification for the updated visit
            await notificationService.cancelVisitReminder(for: visit.id)
            await notificationService.scheduleVisitReminder(for: updatedVisit)
        }
    }
    
    func deleteVisit(_ visit: AgendaVisit) async {
        await performOperation(.deleteVisit) { [self] in
            try await repo.deleteVisit(visit.id)
            
            // Remove from local state
            let day = cal.startOfDay(for: visit.startDate)
            if let index = visitsByDay[day]?.firstIndex(where: { $0.id == visit.id }) {
                visitsByDay[day]?.remove(at: index)
                if visitsByDay[day]?.isEmpty == true {
                    visitsByDay.removeValue(forKey: day)
                }
            }
            
            // Update all visits
            allVisits = visitsByDay.values.flatMap { $0 }
            
            // Cancel notification for the deleted visit
            await notificationService.cancelVisitReminder(for: visit.id)
        }
    }
    
    func deleteVisit(_ visitId: UUID) async {
        // Find the visit first
        if let visit = allVisits.first(where: { $0.id == visitId }) {
            await deleteVisit(visit)
        }
    }
    
    // MARK: - Navigation
    func goToPreviousMonth() {
        guard let previousMonth = cal.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        currentMonth = previousMonth
        Task { @MainActor in
            await loadMonth()
        }
    }
    
    func goToNextMonth() {
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = nextMonth
        Task { @MainActor in
            await loadMonth()
        }
    }
    
    // MARK: - Data Access
    func visits(for date: Date) -> [AgendaVisit] {
        let day = cal.startOfDay(for: date)
        return visitsByDay[day] ?? []
    }
    
    // Computed property removed - using @Published allVisits instead
    
    // MARK: - Enhanced Operation Management
    private func performOperation<T>(_ operation: OperationType, _ block: @escaping () async throws -> T) async {
        operationInProgress = operation
        loadingState = .loading
        isLoading = true
        lastError = nil
        
        do {
            _ = try await block()
            loadingState = .success
            retryCount = 0
        } catch {
            lastError = error
            loadingState = .error
            errorMessage = error.localizedDescription
            
            // Auto-retry logic
            if retryCount < maxRetryAttempts {
                retryCount += 1
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000)) // Exponential backoff
                await performOperation(operation, block)
                return
            }
        }
        
        operationInProgress = nil
        isLoading = false
    }
    
    // MARK: - Retry Operations
    func retryLastOperation() async {
        guard let operation = operationInProgress else { return }
        
        switch operation {
        case .loadMonth:
            await loadMonth()
        case .addVisit:
            // Retry would need the visit data, handled by caller
            break
        case .updateVisit:
            // Retry would need the visit data, handled by caller
            break
        case .deleteVisit:
            // Retry would need the visit ID, handled by caller
            break
        case .sync:
            await syncWithCalendar()
        }
    }
    
    // MARK: - Sync Operations
    func syncWithCalendar() async {
        await performOperation(.sync) { [self] in
            // Implement sync logic here
            // This would sync with EventKit
            try await Task.sleep(nanoseconds: 1_000_000_000) // Simulate sync
            lastSyncDate = Date()
            syncStatus = .success
        }
    }
}

// MARK: - Loading State Enum
enum LoadingState {
    case idle
    case loading
    case success
    case error
}

// MARK: - Operation Type Enum
enum OperationType {
    case loadMonth
    case addVisit
    case updateVisit
    case deleteVisit
    case sync
}

// MARK: - Sync Status Enum (using existing from BidirectionalSyncService)
// SyncStatus is already defined in BidirectionalSyncService.swift

// MARK: - Date Extensions
extension Date {
    func startOfDay(_ calendar: Calendar) -> Date {
        return calendar.startOfDay(for: self)
    }
    
    func endOfDay(_ calendar: Calendar) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return calendar.date(byAdding: components, to: calendar.startOfDay(for: self)) ?? self
    }
}
