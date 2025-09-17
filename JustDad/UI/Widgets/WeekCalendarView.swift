import SwiftUI

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    let visits: [AgendaVisit]
    let onVisitTap: (AgendaVisit) -> Void
    
    private let calendar = Calendar.current
    @State private var currentWeekStart: Date = Date()
    
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            // Week navigation header
            weekNavigationHeader
            
            // Week header with days
            weekHeaderView
            
            // Week timeline
            weekTimelineView
        }
        .padding(SuperDesign.Tokens.space.lg)
        .onAppear {
            updateCurrentWeekStart()
        }
        .onChange(of: selectedDate) { _, _ in
            updateCurrentWeekStart()
        }
    }
    
    // MARK: - Week Navigation Header
    private var weekNavigationHeader: some View {
        HStack {
            // Previous week button
            Button(action: previousWeek) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                    .frame(width: 32, height: 32)
                    .background(SuperDesign.Tokens.colors.primary.opacity(SuperDesign.Tokens.effects.opacitySubtle))
                    .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
            }
            
            Spacer()
            
            // Week range display
            VStack(spacing: 2) {
                Text(weekRangeText)
                    .font(SuperDesign.Tokens.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Text(weekYearText)
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
            
            Spacer()
            
            // Next week button
            Button(action: nextWeek) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                    .frame(width: 32, height: 32)
                    .background(SuperDesign.Tokens.colors.primary.opacity(SuperDesign.Tokens.effects.opacitySubtle))
                    .cornerRadius(SuperDesign.Tokens.effects.cornerRadiusSmall)
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
    
    private var weekHeaderView: some View {
        HStack(spacing: 0) {
            // Hour column header (empty space for alignment)
            Color.clear
                .frame(width: 40)
            
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: SuperDesign.Tokens.space.xs) {
                    // Day name
                    Text(dayFormatter.string(from: date))
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .fontWeight(.medium)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    
                    // Day number
                    Text(dayNumberFormatter.string(from: date))
                        .font(SuperDesign.Tokens.typography.titleMedium)
                        .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .semibold)
                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.surface : SuperDesign.Tokens.colors.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.primary : SuperDesign.Tokens.colors.surface)
                                .shadow(
                                    color: calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.primary.opacity(0.3) : Color.clear,
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDate = date
                            }
                        }
                    
                    // Today indicator
                    if calendar.isDateInToday(date) {
                        Circle()
                            .fill(SuperDesign.Tokens.colors.primary)
                            .frame(width: 4, height: 4)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SuperDesign.Tokens.space.sm)
                .background(
                    RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadiusSmall)
                        .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.primary.opacity(0.05) : Color.clear)
                )
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.sm)
    }
    
    private var weekTimelineView: some View {
        VStack(spacing: 0) {
            // Selected day header
            selectedDayHeader
            
            // Events for selected day
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: SuperDesign.Tokens.space.sm) {
                    ForEach(visitsForDate(date: selectedDate), id: \.id) { visit in
                        visitCardSelected(visit: visit)
                    }
                    
                    if visitsForDate(date: selectedDate).isEmpty {
                        emptyDayView
                    }
                }
                .padding(.horizontal, SuperDesign.Tokens.space.lg)
                .padding(.vertical, SuperDesign.Tokens.space.md)
            }
            .frame(height: 400)
        }
        .background(SuperDesign.Tokens.colors.surface)
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                .stroke(SuperDesign.Tokens.colors.primary, lineWidth: 2)
        )
    }
    
    // MARK: - Selected Day Header
    private var selectedDayHeader: some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            HStack {
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                    Text(dayFormatter.string(from: selectedDate))
                        .font(SuperDesign.Tokens.typography.labelMedium)
                        .fontWeight(.medium)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    
                    Text(dayNumberFormatter.string(from: selectedDate))
                        .font(SuperDesign.Tokens.typography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                }
                
                Spacer()
                
                // Today indicator
                if calendar.isDateInToday(selectedDate) {
                    VStack(spacing: SuperDesign.Tokens.space.xxs) {
                        Text("HOY")
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .fontWeight(.bold)
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                        
                        Circle()
                            .fill(SuperDesign.Tokens.colors.primary)
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            // Event count
            let eventCount = visitsForDate(date: selectedDate).count
            HStack {
                Text(eventCount == 1 ? "1 evento" : "\(eventCount) eventos")
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                
                Spacer()
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.vertical, SuperDesign.Tokens.space.md)
        .background(
            RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                .fill(SuperDesign.Tokens.colors.primary.opacity(0.05))
        )
    }
    
    // MARK: - Day Column Header (Legacy)
    private func dayColumnHeader(date: Date) -> some View {
        VStack(spacing: SuperDesign.Tokens.space.xs) {
            Text(dayFormatter.string(from: date))
                .font(SuperDesign.Tokens.typography.labelSmall)
                .fontWeight(.medium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            
            Text(dayNumberFormatter.string(from: date))
                .font(SuperDesign.Tokens.typography.titleMedium)
                .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .semibold)
                .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.primary : SuperDesign.Tokens.colors.textPrimary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.primary : SuperDesign.Tokens.colors.surface)
                        .shadow(
                            color: calendar.isDate(date, inSameDayAs: selectedDate) ? SuperDesign.Tokens.colors.primary.opacity(0.3) : Color.clear,
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                )
            
            // Today indicator
            if calendar.isDateInToday(date) {
                Circle()
                    .fill(SuperDesign.Tokens.colors.primary)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Empty Day View
    private var emptyDayView: some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 24))
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
            
            Text("Sin eventos")
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, SuperDesign.Tokens.space.lg)
    }
    
    // MARK: - Visit Card for Selected Day
    private func visitCardSelected(visit: AgendaVisit) -> some View {
        Button(action: { onVisitTap(visit) }) {
            HStack(spacing: SuperDesign.Tokens.space.md) {
                // Time and type indicator
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                    Text(timeFormatter.string(from: visit.startDate))
                        .font(SuperDesign.Tokens.typography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                    
                    HStack(spacing: SuperDesign.Tokens.space.xs) {
                        Circle()
                            .fill(visitTypeColor(visit.visitType))
                            .frame(width: 8, height: 8)
                        
                        Text(visitTypeText(visit.visitType))
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    }
                }
                .frame(width: 80, alignment: .leading)
                
                // Event details
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                    Text(visit.title)
                        .font(SuperDesign.Tokens.typography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    if let location = visit.location, !location.isEmpty {
                        HStack(spacing: SuperDesign.Tokens.space.xs) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 12))
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            
                            Text(location)
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    
                    // Duration
                    if visit.startDate != visit.endDate {
                        HStack(spacing: SuperDesign.Tokens.space.xs) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            
                            Text("Hasta \(timeFormatter.string(from: visit.endDate))")
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
            }
            .padding(SuperDesign.Tokens.space.lg)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                    .fill(SuperDesign.Tokens.colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                            .stroke(visitTypeColor(visit.visitType), lineWidth: 2)
                    )
                    .shadow(
                        color: visitTypeColor(visit.visitType).opacity(0.2),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Visit Card Horizontal (Legacy)
    private func visitCardHorizontal(visit: AgendaVisit) -> some View {
        Button(action: { onVisitTap(visit) }) {
            VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                // Time
                Text(timeFormatter.string(from: visit.startDate))
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .fontWeight(.medium)
                    .foregroundColor(SuperDesign.Tokens.colors.surface.opacity(0.9))
                
                // Title
                Text(visit.title)
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .fontWeight(.semibold)
                    .foregroundColor(SuperDesign.Tokens.colors.surface)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Location (if available)
                if let location = visit.location, !location.isEmpty {
                    Text(location)
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .foregroundColor(SuperDesign.Tokens.colors.surface.opacity(0.8))
                        .lineLimit(1)
                }
                
                // Visit type indicator
                HStack {
                    Circle()
                        .fill(SuperDesign.Tokens.colors.surface)
                        .frame(width: 6, height: 6)
                    
                    Text(visitTypeText(visit.visitType))
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .foregroundColor(SuperDesign.Tokens.colors.surface.opacity(0.8))
                }
            }
            .padding(SuperDesign.Tokens.space.xs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadiusSmall)
                    .fill(visitTypeColor(visit.visitType))
                    .shadow(
                        color: visitTypeColor(visit.visitType).opacity(0.3),
                        radius: 3,
                        x: 0,
                        y: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Visit Card (Legacy - keeping for compatibility)
    private func visitCard(visit: AgendaVisit, date: Date) -> some View {
        Button(action: { onVisitTap(visit) }) {
            VStack(alignment: .leading, spacing: 2) {
                Text(visit.title)
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .fontWeight(.medium)
                    .foregroundColor(SuperDesign.Tokens.colors.surface)
                    .lineLimit(1)
                
                if let location = visit.location, !location.isEmpty {
                    Text(location)
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .foregroundColor(SuperDesign.Tokens.colors.surface.opacity(0.8))
                        .lineLimit(1)
                }
                
                Text(timeFormatter.string(from: visit.startDate))
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.surface.opacity(0.7))
            }
            .padding(.horizontal, SuperDesign.Tokens.space.xs)
            .padding(.vertical, SuperDesign.Tokens.space.xxs)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadiusSmall)
                    .fill(visitTypeColor(visit.visitType))
                    .shadow(
                        color: visitTypeColor(visit.visitType).opacity(0.3),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Navigation Functions
    private func previousWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
            selectedDate = currentWeekStart
        }
    }
    
    private func nextWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? currentWeekStart
            selectedDate = currentWeekStart
        }
    }
    
    private func updateCurrentWeekStart() {
        currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
    }
    
    // MARK: - Computed Properties
    private var weekDays: [Date] {
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: currentWeekStart)
        }
    }
    
    private var weekRangeText: String {
        let startDate = currentWeekStart
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) ?? startDate
        
        let startFormatter = DateFormatter()
        startFormatter.dateFormat = "d"
        
        let endFormatter = DateFormatter()
        endFormatter.dateFormat = "d MMM"
        
        return "\(startFormatter.string(from: startDate)) - \(endFormatter.string(from: endDate))"
    }
    
    private var weekYearText: String {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        return yearFormatter.string(from: currentWeekStart)
    }
    
    private func visitTypeColor(_ type: AgendaVisitType) -> Color {
        switch type {
        case .medical: return SuperDesign.Tokens.colors.error
        case .school: return SuperDesign.Tokens.colors.info
        case .activity: return SuperDesign.Tokens.colors.success
        case .weekend: return SuperDesign.Tokens.colors.warning
        case .dinner: return SuperDesign.Tokens.colors.accent
        case .emergency: return SuperDesign.Tokens.colors.error
        case .general: return SuperDesign.Tokens.colors.primary
        }
    }
    
    private func visitsForDate(date: Date) -> [AgendaVisit] {
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }.sorted { $0.startDate < $1.startDate }
    }
    
    private func visitsForDateAndHour(date: Date, hour: Int) -> [AgendaVisit] {
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date) &&
            calendar.component(.hour, from: visit.startDate) == hour
        }
    }
    
    private func visitTypeText(_ type: AgendaVisitType) -> String {
        switch type {
        case .medical: return "Médico"
        case .school: return "Escuela"
        case .activity: return "Actividad"
        case .weekend: return "Fin de semana"
        case .dinner: return "Cena"
        case .emergency: return "Emergencia"
        case .general: return "General"
        }
    }
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    private let dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

#Preview {
    @Previewable @State var selectedDate = Date()
    
    WeekCalendarView(
        selectedDate: $selectedDate,
        visits: [],
        onVisitTap: { _ in }
    )
}
