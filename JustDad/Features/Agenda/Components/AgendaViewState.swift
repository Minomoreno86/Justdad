//
//  AgendaViewState.swift
//  JustDad - Agenda View State Management
//
//  Centralized state management for AgendaView with all necessary properties
//  and computed values for filtering and display
//

import SwiftUI
import Foundation

@MainActor
class AgendaViewState: ObservableObject {
    // MARK: - Published Properties
    @Published var viewMode: CalendarViewMode = .month
    @Published var isEditMode = false
    @Published var selectedVisits: Set<UUID> = []
    @Published var showingNewVisit = false
    @Published var showingEditVisit = false
    @Published var showingVisitDetail = false
    @Published var showingViewModeSheet = false
    @Published var showingBulkDeleteAlert = false
    @Published var showingFilterSheet = false
    @Published var searchText = ""
    @Published var selectedFilter: VisitFilter = .all
    @Published var selectedVisit: AgendaVisit?
    
    // MARK: - Computed Properties
    var headerSubtitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date()) // This should be passed from the view model
    }
    
    var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: Date()).capitalized // This should be passed from the view model
    }
    
    // MARK: - Methods
    func toggleEditMode() {
        withAnimation(SuperDesign.Tokens.animation.easeInOut) {
            isEditMode.toggle()
            if !isEditMode {
                selectedVisits.removeAll()
            }
        }
    }
    
    func toggleSelection(_ id: UUID) {
        if selectedVisits.contains(id) {
            selectedVisits.remove(id)
        } else {
            selectedVisits.insert(id)
        }
    }
    
    func selectAllVisits(_ visitIds: [UUID]) {
        if selectedVisits.count == visitIds.count {
            selectedVisits.removeAll()
        } else {
            selectedVisits = Set(visitIds)
        }
    }
    
    func clearSelection() {
        selectedVisits.removeAll()
    }
    
    func setSelectedVisit(_ visit: AgendaVisit?) {
        selectedVisit = visit
    }
    
    func showNewVisit() {
        showingNewVisit = true
    }
    
    func showEditVisit(_ visit: AgendaVisit) {
        selectedVisit = visit
        showingEditVisit = true
    }
    
    func showVisitDetail(_ visit: AgendaVisit) {
        selectedVisit = visit
        showingVisitDetail = true
    }
    
    func dismissAllSheets() {
        showingNewVisit = false
        showingEditVisit = false
        showingVisitDetail = false
        showingViewModeSheet = false
        showingBulkDeleteAlert = false
        showingFilterSheet = false
        selectedVisit = nil
    }
}
