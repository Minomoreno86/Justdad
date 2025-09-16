import SwiftUI

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
    
    init(repo: AgendaRepositoryProtocol) {
        _vm = StateObject(wrappedValue: AgendaViewModel(repo: repo))
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Professional Header with View Mode Selector
                    headerView
                    
                    // Main Calendar Content with proper scroll behavior
                    mainContentView
                        .clipped() // Prevent content overflow
                }
                .background(Color(.systemGroupedBackground))
                
                // Floating Action Button - properly positioned
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
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
        .actionSheet(isPresented: $showingViewModeSheet) {
            ActionSheet(
                title: Text("Vista del Calendario"),
                buttons: [
                    .default(Text("Vista Lista")) { viewMode = .list },
                    .default(Text("Vista Semana")) { viewMode = .week },
                    .default(Text("Vista Mes")) { viewMode = .month },
                    .cancel(Text("Cancelar"))
                ]
            )
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
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            // Top navigation bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Agenda")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if isEditMode {
                            Text("(\(selectedVisits.count) seleccionadas)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Edit mode toggle
                if viewMode == .list && !vm.allVisits.isEmpty {
                    Button(isEditMode ? "Cancelar" : "Editar") {
                        withAnimation {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedVisits.removeAll()
                            }
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                // View mode selector
                Button(action: { showingViewModeSheet = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModeIcon)
                        Text(viewModeText)
                            .font(.footnote)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemBlue).opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Bulk Actions Toolbar (only in edit mode)
            if isEditMode && !selectedVisits.isEmpty {
                bulkActionsToolbar
            }
            
            // Month navigation (for month view)
            if viewMode == .month {
                monthNavigationView
            }
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    // MARK: - Month Navigation
    private var monthNavigationView: some View {
        HStack {
            Button(action: vm.goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(monthYearText)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: vm.goToNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
                        ForEach(vm.allVisits.sorted(by: { $0.startDate < $1.startDate })) { visit in
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
        return formatter.string(from: vm.selectedDate).capitalized
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
        Button(action: { showingNewVisit = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color(.systemBlue))
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
    
    private var selectedDayEventsCard: some View {
        let dayEvents = vm.allVisits.filter { 
            Calendar.current.isDate($0.startDate, inSameDayAs: vm.selectedDate)
        }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Eventos del día")
                .font(.headline)
                .fontWeight(.semibold)
            
            if dayEvents.isEmpty {
                Text("No hay eventos programados")
                    .foregroundColor(.secondary)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(dayEvents, id: \.id) { visit in
                    Button(action: {
                        selectedVisit = visit
                        showingEditVisit = true
                    }) {
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
        .background(Color(.systemBackground))
        .cornerRadius(12)
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(timeRange(visit))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let notes = visit.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(visit.visitType.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(visitTypeColor(visit.visitType).opacity(0.2))
                        .foregroundColor(visitTypeColor(visit.visitType))
                        .cornerRadius(8)
                    
                    if !isEditMode {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            .scaleEffect(isSelected ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isSelected)
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

// MARK: - VisitDetailView
struct VisitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let visit: AgendaVisit
    let onEdit: (AgendaVisit) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(visit.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    Image(systemName: visitTypeIcon(visit.visitType))
                                    Text(visit.visitType.displayName)
                                }
                                .font(.subheadline)
                                .foregroundColor(visitTypeColor(visit.visitType))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(visitTypeColor(visit.visitType).opacity(0.1))
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Date & Time
                        DetailRow(
                            icon: "calendar",
                            title: "Fecha y Hora",
                            content: formatDateRange(visit.startDate, visit.endDate)
                        )
                        
                        // Location
                        if let location = visit.location, !location.isEmpty {
                            DetailRow(
                                icon: "location",
                                title: "Ubicación",
                                content: location
                            )
                        }
                        
                        // Notes
                        if let notes = visit.notes, !notes.isEmpty {
                            DetailRow(
                                icon: "note.text",
                                title: "Notas",
                                content: notes
                            )
                        }
                        
                        // Reminder
                        if let reminderMinutes = visit.reminderMinutes {
                            DetailRow(
                                icon: "bell",
                                title: "Recordatorio",
                                content: reminderText(reminderMinutes)
                            )
                        }
                        
                        // Recurrence
                        if visit.isRecurring {
                            DetailRow(
                                icon: "repeat",
                                title: "Repetición",
                                content: "Activa"
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Detalles de la Visita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Editar") {
                        onEdit(visit)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func visitTypeIcon(_ type: AgendaVisitType) -> String {
        switch type {
        case .medical: return "cross.fill"
        case .school: return "book.fill"
        case .activity: return "figure.run"
        case .weekend: return "house.fill"
        case .dinner: return "fork.knife"
        case .emergency: return "exclamationmark.triangle.fill"
        case .general: return "calendar"
        }
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
    
    private func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        
        let calendar = Calendar.current
        if calendar.isDate(start, inSameDayAs: end) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            
            return "\(dateFormatter.string(from: start))\n\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))"
        } else {
            return "\(formatter.string(from: start))\n\(formatter.string(from: end))"
        }
    }
    
    private func reminderText(_ minutes: Int) -> String {
        switch minutes {
        case 5: return "5 minutos antes"
        case 15: return "15 minutos antes"
        case 30: return "30 minutos antes"
        case 60: return "1 hora antes"
        case 120: return "2 horas antes"
        case 1440: return "1 día antes"
        default: return "\(minutes) minutos antes"
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
