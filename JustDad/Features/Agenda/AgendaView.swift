import SwiftUI
import EventKit

struct AgendaView: View {
    // MARK: - Dependencies
    @StateObject private var vm: AgendaViewModel
    @StateObject private var viewState = AgendaViewState()
    @StateObject private var permissionService = EventKitPermissionService()
    @StateObject private var calendarService = CalendarManagementService.shared
    
    // MARK: - Permission States
    @State private var showingPermissionRequest = false
    @State private var showingCalendarSelection = false
    @State private var hasRequestedPermission = false
    
    // MARK: - Initialization
    init(repo: AgendaRepositoryProtocol) {
        _vm = StateObject(wrappedValue: AgendaViewModel(repo: repo))
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Professional gradient background
                SuperDesign.Tokens.colors.surfaceGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Professional Header with View Mode Selector
                    AgendaHeaderView(
                        viewMode: viewState.viewMode,
                        isEditMode: viewState.isEditMode,
                        selectedVisitsCount: viewState.selectedVisits.count,
                        headerSubtitle: viewState.headerSubtitle,
                        searchText: $viewState.searchText,
                        selectedFilter: viewState.selectedFilter,
                        showingViewModeSheet: $viewState.showingViewModeSheet,
                        showingFilterSheet: $viewState.showingFilterSheet,
                        onEditModeToggle: viewState.toggleEditMode,
                        onViewModeChange: { viewState.viewMode = $0 },
                        onFilterChange: { viewState.selectedFilter = $0 }
                    )
                    
                    // Main Calendar Content with proper scroll behavior
                    mainContentView
                        .clipped() // Prevent content overflow
                }
                
                // Floating Action Button - properly positioned
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        AgendaFloatingActionButton {
                            viewState.showNewVisit()
                        }
                        .padding(.trailing, SuperDesign.Tokens.space.lg)
                        .padding(.bottom, SuperDesign.Tokens.space.xl)
                    }
                }
                .allowsHitTesting(true) // Ensure button remains tappable
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            checkCalendarPermissions()
        }
        .onChange(of: permissionService.calendarPermissionStatus) { status in
            handlePermissionStatusChange(status)
        }
        .sheet(isPresented: $viewState.showingNewVisit) {
            NewVisitView { newVisit in
                Task {
                    await vm.addVisit(newVisit)
                }
            }
        }
        .sheet(isPresented: $viewState.showingEditVisit) {
            if let visit = viewState.selectedVisit {
                EditVisitView(
                    visit: visit,
                    onSave: { updatedVisit in
                        Task {
                            await vm.updateVisit(updatedVisit)
                        }
                        viewState.setSelectedVisit(nil)
                    },
                    onDelete: { visitToDelete in
                        Task {
                            await vm.deleteVisit(visitToDelete.id)
                        }
                        viewState.setSelectedVisit(nil)
                    }
                )
            }
        }
        .confirmationDialog("Vista del Calendario", isPresented: $viewState.showingViewModeSheet, titleVisibility: .visible) {
            Button("Vista Lista") { viewState.viewMode = .list }
            Button("Vista Semana") { viewState.viewMode = .week }
            Button("Vista Mes") { viewState.viewMode = .month }
            Button("Cancelar", role: .cancel) { }
        }
        .alert("Eliminar Visitas", isPresented: $viewState.showingBulkDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar \(viewState.selectedVisits.count) visitas", role: .destructive) {
                bulkDeleteVisits()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar \(viewState.selectedVisits.count) visitas? Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: $viewState.showingVisitDetail) {
            if let visit = viewState.selectedVisit {
                VisitDetailView(visit: visit) { visit in
                    editVisit(visit)
                }
            }
        }
        .confirmationDialog("Filtrar Visitas", isPresented: $viewState.showingFilterSheet, titleVisibility: .visible) {
            ForEach(VisitFilter.allCases, id: \.self) { filter in
                Button("\(filter.icon) \(filter.rawValue)") {
                    viewState.selectedFilter = filter
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
        .fullScreenCover(isPresented: $showingPermissionRequest) {
            CalendarPermissionView(
                onPermissionGranted: {
                    showingPermissionRequest = false
                    showingCalendarSelection = true
                },
                onPermissionDenied: {
                    showingPermissionRequest = false
                }
            )
        }
        .sheet(isPresented: $showingCalendarSelection) {
            CalendarSelectionView(
                onCalendarSelected: { selectedCalendar in
                    showingCalendarSelection = false
                    if let calendar = selectedCalendar {
                        Task {
                            // Store the selected calendar for future use
                            // The actual calendar selection will be handled by the EventKitAgendaRepository
                        }
                    }
                },
                onDismiss: {
                    showingCalendarSelection = false
                }
            )
        }
    }
    
    
    
    // MARK: - Main Content
    private var mainContentView: some View {
        PullToRefreshView {
            await refreshData()
        } content: {
            ZStack {
                switch viewState.viewMode {
                case .list:
                    AgendaListView(
                        visits: filteredVisits,
                        isEditMode: viewState.isEditMode,
                        selectedVisits: viewState.selectedVisits,
                        onVisitTap: editVisit,
                        onVisitLongPress: showVisitDetails,
                        onSelectionToggle: viewState.toggleSelection
                    )
                    .animatedTransition(type: .listTransition, duration: 0.4)
                case .week:
                    AgendaWeekView(
                        selectedDate: $vm.selectedDate,
                        visits: vm.allVisits,
                        onVisitTap: editVisit
                    )
                    .animatedTransition(type: .calendarTransition, duration: 0.4)
                case .month:
                    AgendaMonthView(
                        currentMonth: vm.currentMonth,
                        selectedDate: $vm.selectedDate,
                        visits: vm.allVisits,
                        onDateTap: { vm.selectedDate = $0 },
                        onVisitTap: editVisit,
                        onPreviousMonth: vm.goToPreviousMonth,
                        onNextMonth: vm.goToNextMonth
                    )
                    .animatedTransition(type: .calendarTransition, duration: 0.4)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: viewState.viewMode)
        }
    }
    
    
    // MARK: - Filtered Visits
    private var filteredVisits: [AgendaVisit] {
        AgendaVisitFilter.filterVisits(
            vm.allVisits,
            searchText: viewState.searchText,
            selectedFilter: viewState.selectedFilter
        )
    }
    
    
    // MARK: - Helper Functions
    private func showVisitDetails(_ visit: AgendaVisit) {
        viewState.showVisitDetail(visit)
    }
    
    private func bulkDeleteVisits() {
        Task {
            for visitId in viewState.selectedVisits {
                await vm.deleteVisit(visitId)
            }
            viewState.clearSelection()
            viewState.toggleEditMode()
        }
    }
    
    private func refreshData() async {
        await vm.loadMonth()
        await vm.syncWithCalendar()
    }

    private func timeRange(_ v: AgendaVisit) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: v.startDate)) - \(f.string(from: v.endDate))"
    }
    
    
    private func editVisit(_ visit: AgendaVisit) {
        viewState.showEditVisit(visit)
    }
    
    // MARK: - Permission Handling
    
    private func checkCalendarPermissions() {
        let status = permissionService.calendarPermissionStatus
        
        switch status {
        case .notDetermined:
            if !hasRequestedPermission {
                showingPermissionRequest = true
                hasRequestedPermission = true
            }
        case .authorized, .fullAccess, .writeOnly:
            // Permission granted, check if we need calendar selection
            Task {
                await checkCalendarSelection()
            }
        case .denied, .restricted:
            // Permission denied, user can continue without sync
            break
        @unknown default:
            break
        }
    }
    
    private func handlePermissionStatusChange(_ status: EKAuthorizationStatus) {
        switch status {
        case .authorized, .fullAccess, .writeOnly:
            // Permission granted, show calendar selection
            Task {
                await checkCalendarSelection()
            }
        case .denied, .restricted:
            // Permission denied, continue without sync
            break
        case .notDetermined:
            // Keep showing permission request if not already shown
            break
        @unknown default:
            break
        }
    }
    
    private func checkCalendarSelection() async {
        do {
            let calendars = try await calendarService.getAvailableCalendars()
            if calendars.isEmpty {
                // No calendars available, show selection to create one
                await MainActor.run {
                    showingCalendarSelection = true
                }
            } else {
                // Try to get or create JustDad calendar
                do {
                    _ = try await calendarService.getJustDadCalendar()
                } catch {
                    // JustDad calendar doesn't exist, show selection
                    await MainActor.run {
                        showingCalendarSelection = true
                    }
                }
            }
        } catch {
            // Error loading calendars, show selection
            await MainActor.run {
                showingCalendarSelection = true
            }
        }
    }
}


