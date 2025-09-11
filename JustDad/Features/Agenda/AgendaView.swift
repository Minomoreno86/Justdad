//
//  AgendaView.swift
//  JustDad - Professional Agenda View
//
//  Modern calendar and visit management with professional design and enhanced functionality
//

import SwiftUI

// MARK: - Supporting Types
enum VisitFilter: String, CaseIterable {
    case all = "Todas"
    case medical = "Médicas"
    case school = "Colegio"
    case personal = "Personal"
    case work = "Trabajo"
    
    var icon: String {
        switch self {
        case .all: return "calendar"
        case .medical: return "stethoscope"
        case .school: return "graduationcap"
        case .personal: return "heart.circle"
        case .work: return "briefcase"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .medical: return .red
        case .school: return .orange
        case .personal: return .green
        case .work: return .purple
        }
    }
}



// MARK: - Mock Data Structure
struct MockVisitAgenda: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let time: String
    let type: VisitFilter
    let location: String?
    let notes: String?
}

// MARK: - Main View
struct AgendaView: View {
    @State private var selectedDate = Date()
    @State private var currentViewMode: CalendarViewMode = .month
    @State private var visits: [MockVisitAgenda] = []
    @State private var isLoading = false
    @State private var showingNewVisitSheet = false
    @State private var showingPermissionAlert = false
    @State private var selectedVisit: MockVisitAgenda?
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedFilter: VisitFilter = .all
    
    // Animation state
    @State private var animateHeader = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Professional Background Gradient
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.blue.opacity(0.03),
                        Color.purple.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Professional Header Section
                    professionalHeader
                    
                    // Enhanced View Mode Picker
                    enhancedViewModePicker
                    
                    // Search and Filter Bar
                    searchAndFilterBar
                    
                    // Main Content with Enhanced Design
                    ZStack {
                        switch currentViewMode {
                        case .month:
                            enhancedMonthView
                        case .week:
                            enhancedWeekView
                        case .list:
                            enhancedListView
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: currentViewMode)
                }
            }
            //.navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingNewVisitSheet) {
                Text("Nueva Visita") // Placeholder
            }
            .sheet(item: $selectedVisit) { visit in
                Text("Editar Visita: \(visit.title)") // Placeholder
            }
            .sheet(isPresented: $showingFilters) {
                filtersSheet
            }
            .alert(
                "Acceso al calendario",
                isPresented: $showingPermissionAlert
            ) {
                Button("Configuración") {
                    openSettings()
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Para sincronizar con tu calendario, necesitamos acceso a EventKit.")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    animateHeader = true
                }
                loadMockData()
            }
        }
    }
    
    // MARK: - Computed Properties
    private var filteredVisits: [MockVisitAgenda] {
        visits.filter { visit in
            let matchesSearch = searchText.isEmpty || 
                               visit.title.localizedCaseInsensitiveContains(searchText) ||
                               (visit.location?.localizedCaseInsensitiveContains(searchText) ?? false)
            
            let matchesFilter = selectedFilter == .all || visit.type == selectedFilter
            
            return matchesSearch && matchesFilter
        }
    }
    
    private var visitsForSelectedDate: [MockVisitAgenda] {
        filteredVisits.filter { visit in
            Calendar.current.isDate(visit.date, inSameDayAs: selectedDate)
        }
    }
    
    private var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
        return calendar.date(from: components) ?? selectedDate
    }
    
    // MARK: - Date Formatters
    private let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    private let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM - d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    private let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    // MARK: - Helper Functions
    private func loadMockData() {
        visits = [
            MockVisitAgenda(
                title: "Pediatra - Revisión mensual",
                date: Date(),
                time: "10:00",
                type: .medical,
                location: "Hospital San Juan",
                notes: "Revisión rutinaria y vacunas"
            ),
            MockVisitAgenda(
                title: "Reunión profesores",
                date: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
                time: "16:30",
                type: .school,
                location: "Colegio ABC",
                notes: "Evaluación trimestral"
            ),
            MockVisitAgenda(
                title: "Parque con papá",
                date: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                time: "17:00",
                type: .personal,
                location: "Parque Central",
                notes: "Tiempo de calidad juntos"
            )
        ]
    }
    
    private func previousMonth() {
        withAnimation {
            selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextMonth() {
        withAnimation {
            selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
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
    
    private func hasVisitsForDay(_ day: Int) -> Bool {
        let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        guard let date = Calendar.current.date(from: DateComponents(year: components.year, month: components.month, day: day)) else {
            return false
        }
        return visits.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func requestCalendarPermission() {
        showingPermissionAlert = true
    }
    
    private func openSettings() {
        #if canImport(UIKit)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
        #endif
    }
}

// MARK: - Professional UI Components
extension AgendaView {
    
    // MARK: - Professional Header
    private var professionalHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mi Agenda")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Gestiona tus visitas y citas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Sync Button
                    Button(action: requestCalendarPermission) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    
                    // Add Button
                    Button(action: { showingNewVisitSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .scaleEffect(animateHeader ? 1.0 : 0.9)
        .opacity(animateHeader ? 1.0 : 0.0)
    }
    
    // MARK: - Enhanced View Mode Picker
    private var enhancedViewModePicker: some View {
        HStack(spacing: 0) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentViewMode = mode
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: mode.systemIcon)
                            .font(.caption)
                        Text(mode.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(currentViewMode == mode ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                currentViewMode == mode ?
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Color.clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Search and Filter Bar
    private var searchAndFilterBar: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Buscar visitas...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
            // Filter Button
            Button(action: { showingFilters = true }) {
                HStack(spacing: 4) {
                    Image(systemName: selectedFilter.icon)
                    if selectedFilter != .all {
                        Text(selectedFilter.rawValue)
                            .font(.caption)
                    }
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedFilter != .all ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedFilter != .all ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }
    
    // MARK: - Enhanced Month View
    private var enhancedMonthView: some View {
        VStack(spacing: 20) {
            // Professional Calendar Widget
            professionalCalendar
            
            // Selected Date Visits Section
            enhancedSelectedDateVisits
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Enhanced Week View
    private var enhancedWeekView: some View {
        VStack(spacing: 16) {
            // Week Header
            professionalWeekHeader
            
            // Week Grid
            professionalWeekGrid
            
            // Selected Date Visits
            enhancedSelectedDateVisits
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Enhanced List View
    private var enhancedListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if filteredVisits.isEmpty {
                    // Professional Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        VStack(spacing: 8) {
                            Text("No hay visitas")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(UIColor.label))
                            
                            Text("Crea tu primera visita para comenzar a organizar tu agenda")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingNewVisitSheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Crear nueva visita")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .padding(.horizontal, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    )
                } else {
                    ForEach(filteredVisits) { visit in
                        ProfessionalVisitCard(visit: visit) {
                            selectedVisit = visit
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Space for tab bar
        }
    }
    
    // MARK: - Professional Calendar
    private var professionalCalendar: some View {
        VStack(spacing: 16) {
            // Month/Year Header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            // Calendar Grid (simplified)
            VStack(spacing: 8) {
                // Day headers
                HStack {
                    ForEach(["L", "M", "X", "J", "V", "S", "D"], id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar days (simplified grid)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(1...30, id: \.self) { day in
                        Button(action: {
                            // Update selected date logic
                            let components = Calendar.current.dateComponents([.year, .month], from: selectedDate)
                            if let newDate = Calendar.current.date(from: DateComponents(year: components.year, month: components.month, day: day)) {
                                selectedDate = newDate
                            }
                        }) {
                            Text("\(day)")
                                .font(.subheadline)
                                .fontWeight(Calendar.current.component(.day, from: selectedDate) == day ? .bold : .regular)
                                .foregroundColor(Calendar.current.component(.day, from: selectedDate) == day ? .white : Color(UIColor.label))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(
                                            Calendar.current.component(.day, from: selectedDate) == day ?
                                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                            LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                )
                                .overlay(
                                    // Visit indicator
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 6, height: 6)
                                        .offset(x: 12, y: -12)
                                        .opacity(hasVisitsForDay(day) ? 1 : 0)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
    }
    
    // MARK: - Professional Week Header
    private var professionalWeekHeader: some View {
        HStack {
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text(weekFormatter.string(from: selectedDate))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
            
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Professional Week Grid
    private var professionalWeekGrid: some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { dayOffset in
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? Date()
                let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                
                VStack(spacing: 8) {
                    Text(weekdayFormatter.string(from: date))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.subheadline)
                            .fontWeight(isSelected ? .bold : .regular)
                            .foregroundColor(isSelected ? .white : Color(UIColor.label))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(
                                        isSelected ?
                                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Enhanced Selected Date Visits
    private var enhancedSelectedDateVisits: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Visitas para \(dayFormatter.string(from: selectedDate))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.label))
                
                Spacer()
                
                Text("\(visitsForSelectedDate.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
            
            if visitsForSelectedDate.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.6))
                    
                    Text("No hay visitas programadas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(visitsForSelectedDate) { visit in
                        ProfessionalVisitCard(visit: visit) {
                            selectedVisit = visit
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Filters Sheet
    private var filtersSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Filtrar visitas")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(VisitFilter.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            showingFilters = false
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: filter.icon)
                                    .font(.title2)
                                    .foregroundColor(selectedFilter == filter ? .white : .blue)
                                
                                Text(filter.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedFilter == filter ? .white : Color(UIColor.label))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        selectedFilter == filter ?
                                        LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                        LinearGradient(colors: [Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cerrar") {
                        showingFilters = false
                    }
                }
            }
        }
    }
}

// MARK: - Professional Visit Card Component
struct ProfessionalVisitCard: View {
    let visit: MockVisitAgenda
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Type Icon
                VStack {
                    Image(systemName: visit.type.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [visit.type.color, visit.type.color.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                    
                    Spacer()
                }
                
                // Visit Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(visit.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(UIColor.label))
                        
                        Spacer()
                        
                        Text(visit.time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    
                    if let location = visit.location {
                        HStack(spacing: 6) {
                            Image(systemName: "location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let notes = visit.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    AgendaView()
}
