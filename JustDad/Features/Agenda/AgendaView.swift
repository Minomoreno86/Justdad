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
    
    // MARK: - Advanced Search
    @State private var advancedSearchFilter = AdvancedSearchFilter()
    
    // MARK: - Sync Status
    @StateObject private var syncStatusManager = SyncStatusManager.shared
    
    // MARK: - Notifications
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingNotificationSettings = false
    @State private var defaultReminderMinutes: Int? = 15
    
    // MARK: - Initialization
    init(repo: AgendaRepositoryProtocol) {
        _vm = StateObject(wrappedValue: AgendaViewModel(repo: repo))
    }

    var body: some View {
        NavigationView {
            mainViewContent
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
        .sheet(isPresented: $showingNotificationSettings) {
            notificationSettingsSheet
        }
    }
    
    // MARK: - Main View Content
    private var mainViewContent: some View {
        ZStack {
            // Professional gradient background
            SuperDesign.Tokens.colors.surfaceGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Search Section
                searchSection
                
                // Stats Section
                statsSection
                
                // Sync Status Section
                syncStatusSection
                
                // Main Content
                mainContentView
                    .clipped()
            }
            
            // Floating Action Button
            floatingActionButton
        }
        .navigationBarHidden(true)
        .overlay(syncNotificationOverlay)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
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
            onFilterChange: { viewState.selectedFilter = $0 },
            onSyncTap: {
                syncStatusManager.startSync()
            },
            onNotificationSettingsTap: {
                showingNotificationSettings = true
            }
        )
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        AdvancedSearchView(searchFilter: $advancedSearchFilter)
            .padding(.bottom, SuperDesign.Tokens.space.xs)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        SearchStatsView(
            totalVisits: vm.allVisits.count,
            filteredVisits: filteredVisits.count,
            searchFilter: advancedSearchFilter
        )
    }
    
    // MARK: - Sync Status Section
    @ViewBuilder
    private var syncStatusSection: some View {
        if syncStatusManager.isVisible {
            SyncStatusIndicator(
                syncStatus: syncStatusManager.syncService.syncStatus,
                lastSyncDate: syncStatusManager.syncService.lastSyncDate,
                onSyncTap: {
                    syncStatusManager.startSync()
                },
                onRetryTap: {
                    syncStatusManager.retrySync()
                }
            )
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
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
        .allowsHitTesting(true)
    }
    
    // MARK: - Sync Notification Overlay
    private var syncNotificationOverlay: some View {
        SyncNotificationOverlay(
            onSyncTap: {
                syncStatusManager.startSync()
            },
            onRetryTap: {
                syncStatusManager.retrySync()
            }
        )
    }
    
    // MARK: - Notification Settings Sheet
    private var notificationSettingsSheet: some View {
        NavigationView {
            VStack(spacing: SuperDesign.Tokens.space.lg) {
                // Header
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
                    Text("Configuración de Notificaciones")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                    
                    Text("Configura cuándo quieres recibir recordatorios para tus visitas")
                        .font(.body)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Reminder Settings
                ReminderSettingsView(reminderMinutes: $defaultReminderMinutes)
                
                Spacer()
            }
            .padding(SuperDesign.Tokens.space.lg)
            .background(SuperDesign.Tokens.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        showingNotificationSettings = false
                    }
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                }
            }
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
                        onSelectionToggle: viewState.toggleSelection,
                        onEdit: editVisit,
                        onDelete: deleteVisit,
                        onDuplicate: duplicateVisit,
                        onShare: shareVisit,
                        onToggleFavorite: toggleFavorite,
                        onArchive: archiveVisit
                    )
                    .animatedTransition(type: .listTransition, duration: 0.4)
                case .week:
                    AgendaWeekView(
                        selectedDate: $vm.selectedDate,
                        visits: filteredVisits,
                        onVisitTap: editVisit
                    )
                    .animatedTransition(type: .calendarTransition, duration: 0.4)
                case .month:
                    AgendaMonthView(
                        currentMonth: vm.currentMonth,
                        selectedDate: $vm.selectedDate,
                        visits: filteredVisits,
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
        // Use advanced search filter if it has active filters, otherwise use basic filter
        if advancedSearchFilter.hasActiveFilters {
            return advancedSearchFilter.filterVisits(vm.allVisits)
        } else {
            return AgendaVisitFilter.filterVisits(
                vm.allVisits,
                searchText: viewState.searchText,
                selectedFilter: viewState.selectedFilter
            )
        }
    }
    
    
    // MARK: - Helper Functions
    private func showVisitDetails(_ visit: AgendaVisit) {
        viewState.showVisitDetail(visit)
    }
    
    private func deleteVisit(_ visit: AgendaVisit) {
        Task {
            await vm.deleteVisit(visit.id)
        }
    }
    
    private func duplicateVisit(_ visit: AgendaVisit) {
        // TODO: Implement duplicate visit
    }
    
    private func shareVisit(_ visit: AgendaVisit) {
        // TODO: Implement share visit
    }
    
    private func toggleFavorite(_ visit: AgendaVisit) {
        // TODO: Implement toggle favorite
    }
    
    private func archiveVisit(_ visit: AgendaVisit) {
        // TODO: Implement archive visit
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


