//
//  AdvancedSearchFilter.swift
//  JustDad - Advanced Search and Filter System
//
//  Professional advanced search and filtering capabilities with multiple criteria
//

import Foundation
import SwiftUI

// MARK: - Advanced Search Filter
struct AdvancedSearchFilter {
    // MARK: - Search Criteria
    var searchText: String = ""
    var selectedDateFilter: VisitFilter = .all
    var selectedVisitTypes: Set<AgendaVisitType> = []
    var selectedTimeRange: TimeRangeFilter = .all
    var selectedLocation: String = ""
    var hasNotes: Bool? = nil
    var isRecurring: Bool? = nil
    var sortBy: SortOption = .startDate
    var sortOrder: SortOrder = .ascending
    
    // MARK: - Computed Properties
    var hasActiveFilters: Bool {
        return !searchText.isEmpty ||
               selectedDateFilter != .all ||
               !selectedVisitTypes.isEmpty ||
               selectedTimeRange != .all ||
               !selectedLocation.isEmpty ||
               hasNotes != nil ||
               isRecurring != nil
    }
    
    var activeFilterCount: Int {
        var count = 0
        if !searchText.isEmpty { count += 1 }
        if selectedDateFilter != .all { count += 1 }
        if !selectedVisitTypes.isEmpty { count += 1 }
        if selectedTimeRange != .all { count += 1 }
        if !selectedLocation.isEmpty { count += 1 }
        if hasNotes != nil { count += 1 }
        if isRecurring != nil { count += 1 }
        return count
    }
    
    // MARK: - Filter Methods
    func filterVisits(_ visits: [AgendaVisit]) -> [AgendaVisit] {
        var filteredVisits = visits
        
        // Apply text search
        if !searchText.isEmpty {
            filteredVisits = filteredVisits.filter { visit in
                visit.title.localizedCaseInsensitiveContains(searchText) ||
                visit.location?.localizedCaseInsensitiveContains(searchText) == true ||
                visit.notes?.localizedCaseInsensitiveContains(searchText) == true ||
                visit.visitType.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply date filter
        filteredVisits = applyDateFilter(filteredVisits)
        
        // Apply visit type filter
        if !selectedVisitTypes.isEmpty {
            filteredVisits = filteredVisits.filter { selectedVisitTypes.contains($0.visitType) }
        }
        
        // Apply time range filter
        filteredVisits = applyTimeRangeFilter(filteredVisits)
        
        // Apply location filter
        if !selectedLocation.isEmpty {
            filteredVisits = filteredVisits.filter { visit in
                visit.location?.localizedCaseInsensitiveContains(selectedLocation) == true
            }
        }
        
        // Apply notes filter
        if let hasNotes = hasNotes {
            filteredVisits = filteredVisits.filter { visit in
                if hasNotes {
                    return visit.notes != nil && !visit.notes!.isEmpty
                } else {
                    return visit.notes == nil || visit.notes!.isEmpty
                }
            }
        }
        
        // Apply recurring filter
        if let isRecurring = isRecurring {
            filteredVisits = filteredVisits.filter { $0.isRecurring == isRecurring }
        }
        
        // Apply sorting
        return sortVisits(filteredVisits)
    }
    
    // MARK: - Private Methods
    private func applyDateFilter(_ visits: [AgendaVisit]) -> [AgendaVisit] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateFilter {
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
    
    private func applyTimeRangeFilter(_ visits: [AgendaVisit]) -> [AgendaVisit] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .all:
            return visits
        case .morning:
            return visits.filter { visit in
                let hour = calendar.component(.hour, from: visit.startDate)
                return hour >= 6 && hour < 12
            }
        case .afternoon:
            return visits.filter { visit in
                let hour = calendar.component(.hour, from: visit.startDate)
                return hour >= 12 && hour < 18
            }
        case .evening:
            return visits.filter { visit in
                let hour = calendar.component(.hour, from: visit.startDate)
                return hour >= 18 && hour < 22
            }
        case .night:
            return visits.filter { visit in
                let hour = calendar.component(.hour, from: visit.startDate)
                return hour >= 22 || hour < 6
            }
        }
    }
    
    private func sortVisits(_ visits: [AgendaVisit]) -> [AgendaVisit] {
        switch sortBy {
        case .startDate:
            return visits.sorted { visit1, visit2 in
                sortOrder == .ascending ? visit1.startDate < visit2.startDate : visit1.startDate > visit2.startDate
            }
        case .endDate:
            return visits.sorted { visit1, visit2 in
                sortOrder == .ascending ? visit1.endDate < visit2.endDate : visit1.endDate > visit2.endDate
            }
        case .title:
            return visits.sorted { visit1, visit2 in
                sortOrder == .ascending ? visit1.title < visit2.title : visit1.title > visit2.title
            }
        case .visitType:
            return visits.sorted { visit1, visit2 in
                sortOrder == .ascending ? visit1.visitType.displayName < visit2.visitType.displayName : visit1.visitType.displayName > visit2.visitType.displayName
            }
        case .duration:
            return visits.sorted { visit1, visit2 in
                let duration1 = visit1.endDate.timeIntervalSince(visit1.startDate)
                let duration2 = visit2.endDate.timeIntervalSince(visit2.startDate)
                return sortOrder == .ascending ? duration1 < duration2 : duration1 > duration2
            }
        }
    }
    
    // MARK: - Reset Methods
    mutating func resetAllFilters() {
        searchText = ""
        selectedDateFilter = .all
        selectedVisitTypes.removeAll()
        selectedTimeRange = .all
        selectedLocation = ""
        hasNotes = nil
        isRecurring = nil
        sortBy = .startDate
        sortOrder = .ascending
    }
    
    mutating func resetSearchOnly() {
        searchText = ""
    }
    
    mutating func resetFiltersOnly() {
        selectedDateFilter = .all
        selectedVisitTypes.removeAll()
        selectedTimeRange = .all
        selectedLocation = ""
        hasNotes = nil
        isRecurring = nil
    }
}

// MARK: - Time Range Filter
enum TimeRangeFilter: String, CaseIterable, Codable {
    case all = "Todo el día"
    case morning = "Mañana (6-12h)"
    case afternoon = "Tarde (12-18h)"
    case evening = "Noche (18-22h)"
    case night = "Madrugada (22-6h)"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .all: return "clock"
        case .morning: return "sunrise"
        case .afternoon: return "sun.max"
        case .evening: return "sunset"
        case .night: return "moon"
        }
    }
}

// MARK: - Sort Options
enum SortOption: String, CaseIterable, Codable {
    case startDate = "Fecha de inicio"
    case endDate = "Fecha de fin"
    case title = "Título"
    case visitType = "Tipo de visita"
    case duration = "Duración"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .startDate: return "calendar"
        case .endDate: return "calendar.badge.clock"
        case .title: return "textformat.abc"
        case .visitType: return "tag"
        case .duration: return "clock.arrow.circlepath"
        }
    }
}

// MARK: - Sort Order
enum SortOrder: String, CaseIterable, Codable {
    case ascending = "Ascendente"
    case descending = "Descendente"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .ascending: return "arrow.up"
        case .descending: return "arrow.down"
        }
    }
}

