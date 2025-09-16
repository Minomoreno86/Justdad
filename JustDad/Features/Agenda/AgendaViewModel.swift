import Foundation
import Combine

@MainActor
final class AgendaViewModel: ObservableObject {
    @Published var currentMonth: Date
    @Published var selectedDate: Date
    @Published private(set) var visitsByDay: [Date: [AgendaVisit]] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repo: AgendaRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let cal = Calendar.current

    init(repo: AgendaRepositoryProtocol,
         initialMonth: Date = Date(),
         initialSelected: Date = Calendar.current.startOfDay(for: Date())) {
        self.repo = repo
        self.currentMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: initialMonth)) ?? Date()
        self.selectedDate = Calendar.current.startOfDay(for: initialSelected)
        
        // Load initial data
        Task {
            await loadMonth()
        }
    }

    // MARK: - Data Loading
    func loadMonth() async {
        isLoading = true
        errorMessage = nil
        
        do {
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
        } catch {
            self.errorMessage = "Error loading visits: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - CRUD Operations
    func addVisit(_ visit: AgendaVisit) async {
        do {
            let savedVisit = try await repo.createVisit(visit)
            
            // Update local state
            let day = cal.startOfDay(for: savedVisit.startDate)
            visitsByDay[day, default: []].append(savedVisit)
            visitsByDay[day] = visitsByDay[day]?.sorted { $0.startDate < $1.startDate }
            
        } catch {
            errorMessage = "Error creating visit: \(error.localizedDescription)"
        }
    }
    
    func updateVisit(_ visit: AgendaVisit) async {
        do {
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
            
        } catch {
            errorMessage = "Error updating visit: \(error.localizedDescription)"
        }
    }
    
    func deleteVisit(_ visit: AgendaVisit) async {
        do {
            try await repo.deleteVisit(visit.id)
            
            // Remove from local state
            let day = cal.startOfDay(for: visit.startDate)
            if let index = visitsByDay[day]?.firstIndex(where: { $0.id == visit.id }) {
                visitsByDay[day]?.remove(at: index)
                if visitsByDay[day]?.isEmpty == true {
                    visitsByDay.removeValue(forKey: day)
                }
            }
            
        } catch {
            errorMessage = "Error deleting visit: \(error.localizedDescription)"
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
        Task {
            await loadMonth()
        }
    }
    
    func goToNextMonth() {
        guard let nextMonth = cal.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        currentMonth = nextMonth
        Task {
            await loadMonth()
        }
    }
    
    // MARK: - Data Access
    func visits(for date: Date) -> [AgendaVisit] {
        let day = cal.startOfDay(for: date)
        return visitsByDay[day] ?? []
    }
    
    var allVisits: [AgendaVisit] {
        visitsByDay.values.flatMap { $0 }
    }
}

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
