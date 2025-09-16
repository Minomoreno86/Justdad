import SwiftUI
import EventKit

struct AgendaView: View {
    @StateObject private var vm: AgendaViewModel
    @State private var showingNewVisit = false
    @State private var showingEditVisit = false
    @State private var selectedVisit: AgendaVisit?
    @State private var viewMode: CalendarViewMode = .month
    @State private var showingViewModeSheet = false
    @State private var isEditMode = false
    @State private var selectedVisits: Set<UUID> = []
    @State private var showingBulkDeleteAlert = false
    @State private var showingVisitDetail = false
    @State private var searchText = ""
    @State private var selectedFilter: VisitFilter = .all
    @State private var showingFilterSheet = false
    
    enum VisitFilter: String, CaseIterable {
        case all = "Todos"
        case today = "Hoy"
        case week = "Esta semana"
        case month = "Este mes"
        case upcoming = "Próximos"
        case past = "Pasados"
        
        var icon: String {
            switch self {
            case .all: return "calendar"
            case .today: return "calendar.circle"
            case .week: return "calendar.day.timeline.leading"
            case .month: return "calendar.month"
            case .upcoming: return "calendar.badge.clock"
            case .past: return "clock.arrow.circlepath"
            }
        }
    }
    
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
                    headerView
                    
                    // Main Calendar Content with proper scroll behavior
                    mainContentView
                        .clipped() // Prevent content overflow
                }
                
                // Floating Action Button - properly positioned
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButton
                            .padding(.trailing, SuperDesign.Tokens.space.lg)
                            .padding(.bottom, SuperDesign.Tokens.space.xl)
                    }
                }
                .allowsHitTesting(true) // Ensure button remains tappable
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingNewVisit) {
            NewVisitView { newVisit in
                Task {
                    await vm.addVisit(newVisit)
                }
            }
        }
        .sheet(isPresented: $showingEditVisit) {
            if let visit = selectedVisit {
                EditVisitView(
                    visit: visit,
                    onSave: { updatedVisit in
                        Task {
                            await vm.updateVisit(updatedVisit)
                        }
                        selectedVisit = nil
                    },
                    onDelete: { visitToDelete in
                        Task {
                            await vm.deleteVisit(visitToDelete.id)
                        }
                        selectedVisit = nil
                    }
                )
            }
        }
        .confirmationDialog("Vista del Calendario", isPresented: $showingViewModeSheet, titleVisibility: .visible) {
            Button("Vista Lista") { viewMode = .list }
            Button("Vista Semana") { viewMode = .week }
            Button("Vista Mes") { viewMode = .month }
            Button("Cancelar", role: .cancel) { }
        }
        .alert("Eliminar Visitas", isPresented: $showingBulkDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar \(selectedVisits.count) visitas", role: .destructive) {
                bulkDeleteVisits()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar \(selectedVisits.count) visitas? Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: $showingVisitDetail) {
            if let visit = selectedVisit {
                VisitDetailView(visit: visit) { visit in
                    editVisit(visit)
                }
            }
        }
        .confirmationDialog("Filtrar Visitas", isPresented: $showingFilterSheet, titleVisibility: .visible) {
            ForEach(VisitFilter.allCases, id: \.self) { filter in
                Button("\(filter.icon) \(filter.rawValue)") {
                    selectedFilter = filter
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            // Top navigation bar with professional gradient
            HStack {
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                    HStack {
                        Text("📅 Agenda")
                            .font(SuperDesign.Tokens.typography.headlineLarge)
                            .fontWeight(.bold)
                            .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        
                        if isEditMode {
                            Text("(\(selectedVisits.count) seleccionadas)")
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                                .foregroundColor(SuperDesign.Tokens.colors.primary)
                                .padding(.horizontal, SuperDesign.Tokens.space.sm)
                                .padding(.vertical, SuperDesign.Tokens.space.xxs)
                                .background(SuperDesign.Tokens.colors.primaryLight)
                                .cornerRadius(12)
                        }
                    }
                    
                    Text(headerSubtitle)
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                }
                
                Spacer()
                
                // Edit mode toggle with enhanced styling
                if viewMode == .list && !vm.allVisits.isEmpty {
                    SuperButton(
                        title: isEditMode ? "Cancelar" : "Editar",
                        style: .secondary,
                        size: .small
                    ) {
                        withAnimation(SuperDesign.Tokens.animation.easeInOut) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedVisits.removeAll()
                            }
                        }
                    }
                }
                
                // View mode selector with enhanced styling
                SuperButton(
                    title: viewModeText,
                    icon: viewModeIcon,
                    style: .primary,
                    size: .small
                ) {
                    showingViewModeSheet = true
                }
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.top, SuperDesign.Tokens.space.lg)
            
            // Bulk Actions Toolbar (only in edit mode)
            if isEditMode && !selectedVisits.isEmpty {
                bulkActionsToolbar
            }
            
            // Month navigation (for month view) with enhanced styling
            if viewMode == .month {
                monthNavigationView
            }
            
            // Search bar (only in list mode)
            if viewMode == .list {
                searchBarView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(SuperDesign.Tokens.colors.surfaceElevated)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Month Navigation
    private var monthNavigationView: some View {
        HStack {
            SuperButton(
                title: "",
                icon: "chevron.left",
                style: .ghost,
                size: .medium
            ) {
                withAnimation(SuperDesign.Tokens.animation.spring) {
                    vm.goToPreviousMonth()
                }
            }
            
            Spacer()
            
            VStack(spacing: SuperDesign.Tokens.space.xxs) {
                Text(monthYearText)
                    .font(SuperDesign.Tokens.typography.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(SuperDesign.Tokens.colors.primaryGradient)
                
                // Professional indicator line
                Rectangle()
                    .fill(SuperDesign.Tokens.colors.primary)
                    .frame(height: 2)
                    .frame(maxWidth: 60)
                    .cornerRadius(1)
            }
            
            Spacer()
            
            SuperButton(
                title: "",
                icon: "chevron.right",
                style: .ghost,
                size: .medium
            ) {
                withAnimation(SuperDesign.Tokens.animation.spring) {
                    vm.goToNextMonth()
                }
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.bottom, SuperDesign.Tokens.space.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(SuperDesign.Tokens.colors.surface)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.08), radius: 4, x: 0, y: 1)
        )
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        Group {
            switch viewMode {
            case .list:
                visitListView
            case .week:
                weekView
            case .month:
                monthView
            }
        }
    }
    
    // MARK: - Day View
    private var dayView: some View {
        VStack(spacing: 16) {
            // Day selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(weekDays, id: \.self) { date in
                        DayButton(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: vm.selectedDate),
                            visitCount: vm.visits(for: date).count
                        ) {
                            vm.selectedDate = date
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Day events list
            dayEventsList
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Week View
    private var weekView: some View {
        ScrollView {
            VStack(spacing: 16) {
                WeekCalendarView(
                    selectedDate: $vm.selectedDate,
                    visits: vm.allVisits,
                    onVisitTap: editVisit
                )
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Add bottom padding to account for floating button
                Color.clear
                    .frame(height: 80)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Month View
    private var monthView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Enhanced Calendar
                EnhancedCalendarMonthView(
                    month: vm.currentMonth,
                    selectedDate: $vm.selectedDate,
                    visits: vm.allVisits,
                    onDateTap: { date in
                        vm.selectedDate = date
                    }
                )
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Selected day events with proper scroll
                selectedDayEventsCard
                    .padding(.horizontal, 20)
                
                // Add bottom padding to account for floating button
                Color.clear
                    .frame(height: 80)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - List View
    private var visitListView: some View {
        Group {
            if vm.allVisits.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No visits scheduled")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Text("Tap the + button to add your first visit")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredVisits.sorted(by: { $0.startDate < $1.startDate })) { visit in
                            VisitRowView(
                                visit: visit,
                                isEditMode: isEditMode,
                                isSelected: selectedVisits.contains(visit.id),
                                onTap: {
                                    if isEditMode {
                                        toggleSelection(visit.id)
                                    } else {
                                        editVisit(visit)
                                    }
                                },
                                onLongPress: {
                                    if !isEditMode {
                                        showVisitDetails(visit)
                                    }
                                }
                            )
                        }
                        
                        // Add bottom padding to account for floating button
                        Color.clear
                            .frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    // MARK: - Search Bar View
    private var searchBarView: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                
                TextField("Buscar visitas...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, SuperDesign.Tokens.space.md)
            .padding(.vertical, SuperDesign.Tokens.space.sm)
            .background(SuperDesign.Tokens.colors.surfaceSecondary)
            .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
            
            // Filter button
            SuperButton(
                title: "",
                icon: "line.3.horizontal.decrease.circle",
                style: .secondary,
                size: .small
            ) {
                showingFilterSheet = true
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.bottom, SuperDesign.Tokens.space.md)
    }
    
    // MARK: - Filtered Visits
    private var filteredVisits: [AgendaVisit] {
        let calendar = Calendar.current
        let now = Date()
        
        var visits = vm.allVisits
        
        // Apply search filter
        if !searchText.isEmpty {
            visits = visits.filter { visit in
                visit.title.localizedCaseInsensitiveContains(searchText) ||
                visit.location?.localizedCaseInsensitiveContains(searchText) == true ||
                visit.notes?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply date filter
        switch selectedFilter {
        case .all:
            break
        case .today:
            visits = visits.filter { calendar.isDateInToday($0.startDate) }
        case .week:
            visits = visits.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear) }
        case .month:
            visits = visits.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }
        case .upcoming:
            visits = visits.filter { $0.startDate > now }
        case .past:
            visits = visits.filter { $0.endDate < now }
        }
        
        return visits.sorted(by: { $0.startDate < $1.startDate })
    }
    
    // MARK: - Bulk Actions Toolbar
    private var bulkActionsToolbar: some View {
        HStack {
            Button("Seleccionar todo") {
                if selectedVisits.count == vm.allVisits.count {
                    selectedVisits.removeAll()
                } else {
                    selectedVisits = Set(vm.allVisits.map { $0.id })
                }
            }
            .foregroundColor(.blue)
            
            Spacer()
            
            Button(action: { showingBulkDeleteAlert = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Eliminar")
                }
                .foregroundColor(.red)
            }
            .disabled(selectedVisits.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    // MARK: - Helper Functions
    private func toggleSelection(_ id: UUID) {
        if selectedVisits.contains(id) {
            selectedVisits.remove(id)
        } else {
            selectedVisits.insert(id)
        }
    }
    
    private func showVisitDetails(_ visit: AgendaVisit) {
        selectedVisit = visit
        showingVisitDetail = true
    }
    
    private func bulkDeleteVisits() {
        Task {
            for visitId in selectedVisits {
                await vm.deleteVisit(visitId)
            }
            selectedVisits.removeAll()
            isEditMode = false
        }
    }

    private func timeRange(_ v: AgendaVisit) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return "\(f.string(from: v.startDate)) - \(f.string(from: v.endDate))"
    }
    
    // MARK: - Computed Properties
    private var headerSubtitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: vm.selectedDate)
    }
    
    private var viewModeIcon: String {
        switch viewMode {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.leading"
        case .list: return "list.bullet"
        }
    }
    
    private var viewModeText: String {
        switch viewMode {
        case .month: return "Mes"
        case .week: return "Semana"
        case .list: return "Lista"
        }
    }
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: vm.currentMonth).capitalized
    }
    
    private var weekDays: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: vm.selectedDate) else {
            return []
        }
        
        var dates: [Date] = []
        var currentDate = weekInterval.start
        
        for _ in 0..<7 {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    private var dayEventsList: some View {
        let dayEvents = vm.allVisits.filter { 
            Calendar.current.isDate($0.startDate, inSameDayAs: vm.selectedDate)
        }
        
        return LazyVStack(spacing: 12) {
            if dayEvents.isEmpty {
                Text("No hay eventos para este día")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                ForEach(dayEvents, id: \.id) { visit in
                    Button(action: { editVisit(visit) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(visit.title)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text(timeRange(visit))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if let location = visit.location {
                                    Text(location)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if visit.id != dayEvents.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
    }
    
    private func editVisit(_ visit: AgendaVisit) {
        selectedVisit = visit
        showingEditVisit = true
    }
    
    private var floatingActionButton: some View {
        ZStack {
            // Enhanced shadow ring
            Circle()
                .fill(SuperDesign.Tokens.colors.primary.opacity(0.2))
                .frame(width: 64, height: 64)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
            
            // Main FAB with SuperDesign
            SuperFAB(icon: "plus", size: .large) {
                withAnimation(SuperDesign.Tokens.animation.spring) {
                    showingNewVisit = true
                }
            }
            .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }
    
    private var selectedDayEventsCard: some View {
        let dayEvents = vm.allVisits.filter { 
            Calendar.current.isDate($0.startDate, inSameDayAs: vm.selectedDate)
        }
        
        return VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            HStack {
                Text("✨ Eventos del día")
                    .font(SuperDesign.Tokens.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(SuperDesign.Tokens.colors.primaryGradient)
                
                Spacer()
                
                Text("\(dayEvents.count)")
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, SuperDesign.Tokens.space.sm)
                    .padding(.vertical, SuperDesign.Tokens.space.xxs)
                    .background(SuperDesign.Tokens.colors.primary)
                    .cornerRadius(12)
            }
            
            if dayEvents.isEmpty {
                VStack(spacing: SuperDesign.Tokens.space.sm) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                    
                    Text("No hay eventos programados")
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SuperDesign.Tokens.space.lg)
            } else {
                ForEach(dayEvents, id: \.id) { visit in
                    Button(action: {
                        selectedVisit = visit
                        showingEditVisit = true
                    }) {
                        HStack(spacing: SuperDesign.Tokens.space.md) {
                            // Color indicator
                            RoundedRectangle(cornerRadius: 3)
                                .fill(SuperDesign.Tokens.colors.primary)
                                .frame(width: 4, height: 40)
                            
                            VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                                Text(visit.title)
                                    .font(SuperDesign.Tokens.typography.bodyMedium)
                                    .fontWeight(.semibold)
                                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                                    .lineLimit(1)
                                
                                Text(timeRange(visit))
                                    .font(SuperDesign.Tokens.typography.bodySmall)
                                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                                
                                if let location = visit.location {
                                    HStack(spacing: SuperDesign.Tokens.space.xxs) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                                            .font(.caption)
                                        Text(location)
                                            .font(SuperDesign.Tokens.typography.bodySmall)
                                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                                .font(.caption)
                        }
                        .padding(.vertical, SuperDesign.Tokens.space.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(SuperDesign.Tokens.colors.surfaceSecondary)
                                .opacity(0.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .superCard()
    }
}

// MARK: - VisitRowView
struct VisitRowView: View {
    let visit: AgendaVisit
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Selection indicator in edit mode
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                    Text(visit.title)
                        .font(SuperDesign.Tokens.typography.titleSmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        .lineLimit(1)
                    
                    Text(timeRange(visit))
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    
                    if let notes = visit.notes, !notes.isEmpty {
                        Text(notes)
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: SuperDesign.Tokens.space.xxs) {
                    Text(visit.visitType.displayName)
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .padding(.horizontal, SuperDesign.Tokens.space.sm)
                        .padding(.vertical, SuperDesign.Tokens.space.xxs)
                        .background(visitTypeColor(visit.visitType).opacity(0.15))
                        .foregroundColor(visitTypeColor(visit.visitType))
                        .cornerRadius(SuperDesign.Tokens.space.sm)
                    
                    if !isEditMode {
                        Image(systemName: "chevron.right")
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                    }
                }
            }
            .superCard()
            .scaleEffect(isSelected ? 0.98 : 1.0)
            .animation(SuperDesign.Tokens.animation.easeInOut, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture {
            onLongPress()
        }
    }
    
    private func timeRange(_ visit: AgendaVisit) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return "\(formatter.string(from: visit.startDate)) - \(formatter.string(from: visit.endDate))"
    }
    
    private func visitTypeColor(_ type: AgendaVisitType) -> Color {
        switch type {
        case .medical: return .red
        case .school: return .blue
        case .activity: return .green
        case .weekend: return .orange
        case .dinner: return .purple
        case .emergency: return .pink
        case .general: return .gray
        }
    }
}

// MARK: - DetailRow
struct DetailRow: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

fileprivate struct NewVisitPlaceholderView: View {
    var onSave: (AgendaVisit) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var start = Date()
    @State private var end = Date().addingTimeInterval(3600)
    @State private var location = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    DatePicker("Start", selection: $start)
                    DatePicker("End", selection: $end)
                    TextField("Location", text: $location)
                }
            }
            .navigationTitle("New Visit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let v = AgendaVisit(
                            title: title.isEmpty ? "Untitled" : title,
                            startDate: start,
                            endDate: end,
                            location: location.isEmpty ? nil : location,
                            notes: nil,
                            reminderMinutes: nil,
                            isRecurring: false,
                            recurrenceRule: nil,
                            visitType: .activity,
                            eventKitIdentifier: nil
                        )
                        onSave(v); dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - External Component References
// Using external widgets:
// - EnhancedCalendarMonthView from UI/Widgets/EnhancedCalendarMonthView.swift
// - WeekCalendarView from UI/Widgets/WeekCalendarView.swift

// MARK: - DayButton Component
struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let visitCount: Int
    let action: () -> Void
    
    private let calendar = Calendar.current
    private let today = Date()
    
    var isToday: Bool {
        calendar.isDate(date, inSameDayAs: today)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Day number
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(textColor)
                
                // Day name
                Text(dayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Visit count indicator
                if visitCount > 0 {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                        .overlay(
                            Text("\(visitCount)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                                .opacity(visitCount > 1 ? 1 : 0)
                        )
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return Color.blue.opacity(0.1)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var borderWidth: CGFloat {
        isSelected || isToday ? 2 : 1
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date).uppercased()
    }
}
