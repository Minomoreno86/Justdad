//
//  AgendaView.swift
//  JustDad - Main Agenda View
//
//  Comprehensive calendar and visit management with EventKit integration
//

import SwiftUI

struct AgendaView: View {
    @StateObject private var router = NavigationRouter.shared
    @StateObject private var agendaRepository = InMemoryAgendaRepository()
    // @StateObject private var agendaRepository = EventKitAgendaRepository() // Use for full EventKit
    
    @State private var selectedDate = Date()
    @State private var currentViewMode: CalendarViewMode = .month
    @State private var visits: [AgendaVisit] = []
    @State private var isLoading = false
    @State private var showingNewVisitSheet = false
    @State private var showingPermissionAlert = false
    @State private var selectedVisit: AgendaVisit?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View Mode Picker
                viewModePicker
                
                // Main Content
                switch currentViewMode {
                case .month:
                    monthView
                case .week:
                    weekView
                case .list:
                    listView
                }
            }
            .navigationTitle(NSLocalizedString("agenda.title", comment: "Agenda"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: requestCalendarPermission) {
                            Label(
                                NSLocalizedString("agenda.sync_calendar", comment: "Sync with Calendar"),
                                systemImage: "arrow.triangle.2.circlepath"
                            )
                        }
                        
                        Button(action: goToToday) {
                            Label(
                                NSLocalizedString("agenda.go_to_today", comment: "Go to Today"),
                                systemImage: "calendar.circle"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewVisitSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewVisitSheet) {
                NewVisitView(
                    initialDate: selectedDate,
                    onSave: { visit in
                        Task { await createVisit(visit) }
                    }
                )
            }
            .sheet(item: $selectedVisit) { visit in
                EditVisitView(
                    visit: AgendaMapping.convertToVisit(from: visit),
                    onSave: { updatedVisit in
                        Task { await updateVisit(updatedVisit) }
                    },
                    onDelete: { _ in
                        Task { await deleteVisit(visit) }
                        selectedVisit = nil
                    }
                )
            }
            .alert(
                NSLocalizedString("agenda.permission.title", comment: "Calendar Access"),
                isPresented: $showingPermissionAlert
            ) {
                Button(NSLocalizedString("settings", comment: "Settings")) {
                    openSettings()
                }
                Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) { }
            } message: {
                Text(NSLocalizedString("agenda.permission.message", comment: "Enable calendar access in Settings to sync your visits."))
            }
            .task {
                await loadVisits()
            }
            .refreshable {
                await loadVisits()
            }
        }
    }
    
    // MARK: - View Mode Picker
    
    private var viewModePicker: some View {
        Picker(NSLocalizedString("agenda.view_mode", comment: "View Mode"), selection: $currentViewMode) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Label(mode.displayName, systemImage: mode.systemIcon)
                    .tag(mode)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    // MARK: - Month View
    
    private var monthView: some View {
        VStack(spacing: 16) {
            CalendarWidgetView(
                selectedDate: $selectedDate,
                visits: visits
            ) { date in
                selectedDate = date
            }
            
            // Selected date visits
            selectedDateVisitsSection
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Week View
    
    private var weekView: some View {
        VStack {
            // Week navigation header
            weekNavigationHeader
            
            // Week calendar grid (simplified)
            weekCalendarGrid
            
            // Selected date visits
            selectedDateVisitsSection
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - List View
    
    private var listView: some View {
        VisitListView(
            visits: visits,
            onVisitTap: { visit in
                selectedVisit = visit
            },
            onEditVisit: { visit in
                selectedVisit = visit
            },
            onDeleteVisit: { visit in
                Task { await deleteVisit(visit) }
            }
        )
    }
    
    // MARK: - Selected Date Visits Section
    
    private var selectedDateVisitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formatSelectedDate())
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !visitsForSelectedDate.isEmpty {
                    Text("\(visitsForSelectedDate.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            if visitsForSelectedDate.isEmpty {
                EmptyStateView(
                    title: NSLocalizedString("agenda.no_visits_today.title", comment: "No visits today"),
                    message: NSLocalizedString("agenda.no_visits_today.subtitle", comment: "Tap + to schedule a visit"),
                    actionTitle: NSLocalizedString("agenda.add_visit", comment: "Add Visit"),
                    action: { showingNewVisitSheet = true }
                )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(visitsForSelectedDate) { visit in
                        CompactVisitRow(visit: visit) {
                            selectedVisit = visit
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Week Navigation Header
    
    private var weekNavigationHeader: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(formatWeekRange())
                .font(.headline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Week Calendar Grid
    
    private var weekCalendarGrid: some View {
        HStack(spacing: 8) {
            ForEach(daysInCurrentWeek, id: \.self) { date in
                VStack(spacing: 4) {
                    Text(formatWeekdayShort(date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: { selectedDate = date }) {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.subheadline)
                            .fontWeight(Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .bold : .regular)
                            .foregroundColor(
                                Calendar.current.isDate(date, inSameDayAs: selectedDate) ? .blue : .primary
                            )
                            .frame(width: 32, height: 32)
                            .background(
                                Calendar.current.isDate(date, inSameDayAs: selectedDate) ? 
                                Color.blue.opacity(0.2) : Color.clear
                            )
                            .cornerRadius(16)
                    }
                    
                    // Visit indicator dots
                    if hasVisits(on: date) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Computed Properties
    
    private var visitsForSelectedDate: [AgendaVisit] {
        visits.filter { visit in
            Calendar.current.isDate(visit.startDate, inSameDayAs: selectedDate)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private var daysInCurrentWeek: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    // MARK: - Helper Methods
    
    private func hasVisits(on date: Date) -> Bool {
        visits.contains { visit in
            Calendar.current.isDate(visit.startDate, inSameDayAs: date)
        }
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }
    
    private func formatWeekRange() -> String {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? selectedDate
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private func formatWeekdayShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func goToToday() {
        withAnimation {
            selectedDate = Date()
        }
    }
    
    private func previousWeek() {
        withAnimation {
            selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextWeek() {
        withAnimation {
            selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Data Operations
    
    private func loadVisits() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loadedVisits = try await agendaRepository.getAllVisits()
            await MainActor.run {
                visits = loadedVisits
            }
        } catch {
            print("❌ Failed to load visits: \(error)")
        }
    }
    
    private func createVisit(_ visit: AgendaVisit) async {
        do {
            _ = try await agendaRepository.createVisit(visit)
            await loadVisits()
            showingNewVisitSheet = false
        } catch {
            print("❌ Failed to create visit: \(error)")
        }
    }
    
    private func updateVisit(_ visit: AgendaVisit) async {
        do {
            _ = try await agendaRepository.updateVisit(visit)
            await loadVisits()
            selectedVisit = nil
        } catch {
            print("❌ Failed to update visit: \(error)")
        }
    }
    
    private func deleteVisit(_ visit: AgendaVisit) async {
        do {
            try await agendaRepository.deleteVisit(withId: visit.id)
            await loadVisits()
        } catch {
            print("❌ Failed to delete visit: \(error)")
        }
    }
    
    private func requestCalendarPermission() {
        Task {
            do {
                try await agendaRepository.requestCalendarPermission()
                try await agendaRepository.syncWithEventKit()
                await loadVisits()
            } catch {
                await MainActor.run {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

// MARK: - Compact Visit Row

struct CompactVisitRow: View {
    let visit: AgendaVisit
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: visit.visitType.systemIcon)
                    .font(.title3)
                    .foregroundColor(Color(visit.visitType.color))
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(visit.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(formatTime(visit.startDate) + " - " + formatTime(visit.endDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if visit.isRecurring {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    AgendaView()
}
