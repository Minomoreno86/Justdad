//
//  AgendaVisitFilter.swift
//  JustDad - Agenda Visit Filter Component
//
//  Professional filtering logic for visits with search and date filtering capabilities
//

import Foundation

struct AgendaVisitFilter {
    // MARK: - Filter Methods
    static func filterVisits(
        _ visits: [AgendaVisit],
        searchText: String,
        selectedFilter: VisitFilter
    ) -> [AgendaVisit] {
        var filteredVisits = visits
        
        // Apply search filter
        if !searchText.isEmpty {
            filteredVisits = filteredVisits.filter { visit in
                visit.title.localizedCaseInsensitiveContains(searchText) ||
                visit.location?.localizedCaseInsensitiveContains(searchText) == true ||
                visit.notes?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply date filter
        filteredVisits = applyDateFilter(filteredVisits, filter: selectedFilter)
        
        // Sort by start date
        return filteredVisits.sorted(by: { $0.startDate < $1.startDate })
    }
    
    // MARK: - Private Methods
    private static func applyDateFilter(_ visits: [AgendaVisit], filter: VisitFilter) -> [AgendaVisit] {
        let calendar = Calendar.current
        let now = Date()
        
        switch filter {
        case .all:
            return visits
        case .today:
            return visits.filter { calendar.isDateInToday($0.startDate) }
        case .week:
            return visits.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear) }
        case .month:
            return visits.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }
        case .upcoming:
            return visits.filter { $0.startDate > now }
        case .past:
            return visits.filter { $0.endDate < now }
        }
    }
}
