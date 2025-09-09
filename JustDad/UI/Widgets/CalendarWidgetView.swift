//
//  CalendarWidgetView.swift
//  JustDad - Calendar Widget Component
//
//  Modern calendar widget with visit highlighting and navigation
//

import SwiftUI

struct CalendarWidgetView: View {
    @Binding var selectedDate: Date
    @State private var currentMonth: Date = Date()
    
    let visits: [Visit]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    init(
        selectedDate: Binding<Date>,
        visits: [Visit] = [],
        onDateSelected: @escaping (Date) -> Void = { _ in }
    ) {
        self._selectedDate = selectedDate
        self.visits = visits
        self.onDateSelected = onDateSelected
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: Palette.Spacing.medium) {
            // Calendar header with navigation
            calendarHeader
            
            // Days of week labels
            daysOfWeekHeader
            
            // Calendar grid
            calendarGrid
        }
        .padding(Palette.Spacing.medium)
        .background(Color(.systemBackground))
        .cornerRadius(Palette.CornerRadius.medium)
        .shadow(
            color: .black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
    }
    
    // MARK: - Calendar Header
    
    private var calendarHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(Typography.title2)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel(NSLocalizedString("calendar.previous_month", comment: "Previous month"))
            
            Spacer()
            
            Text(dateFormatter.string(from: currentMonth))
                .font(Typography.headline)
                .fontWeight(.semibold)
                .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(Typography.title2)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel(NSLocalizedString("calendar.next_month", comment: "Next month"))
        }
    }
    
    // MARK: - Days of Week Header
    
    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
        }
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 7),
            spacing: Palette.Spacing.small
        ) {
            ForEach(daysInMonth, id: \.self) { date in
                CalendarDayCell(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isToday: calendar.isDateInToday(date),
                    isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                    hasVisits: hasVisits(on: date),
                    visitCount: visitCount(on: date)
                ) {
                    selectedDate = date
                    onDateSelected(date)
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols
    }
    
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
        else { return [] }
        
        var dates: [Date] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return dates
    }
    
    // MARK: - Visit Helpers
    
    private func hasVisits(on date: Date) -> Bool {
        visits.contains { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }
    }
    
    private func visitCount(on date: Date) -> Int {
        visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }.count
    }
    
    // MARK: - Navigation Methods
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasVisits: Bool
    let visitCount: Int
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background circle
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)
                
                // Day number
                Text(dayNumber)
                    .font(Typography.system(.medium, size: 16))
                    .foregroundColor(textColor)
                
                // Visit indicators
                if hasVisits {
                    VStack {
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0..<min(visitCount, 3), id: \.self) { _ in
                                Circle()
                                    .fill(visitIndicatorColor)
                                    .frame(width: 4, height: 4)
                            }
                            
                            if visitCount > 3 {
                                Text("+")
                                    .font(Typography.system(.bold, size: 8))
                                    .foregroundColor(visitIndicatorColor)
                            }
                        }
                        .offset(y: -2)
                    }
                    .frame(width: 36, height: 36)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(accessibilityTraits)
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.2)
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .secondary
        } else if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var visitIndicatorColor: Color {
        if isSelected {
            return .white
        } else {
            return .red
        }
    }
    
    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        let dateString = formatter.string(from: date)
        
        var label = dateString
        
        if isToday {
            label += ", " + NSLocalizedString("calendar.today", comment: "Today")
        }
        
        if isSelected {
            label += ", " + NSLocalizedString("calendar.selected", comment: "Selected")
        }
        
        if hasVisits {
            let format = NSLocalizedString("calendar.visits_count", comment: "%d visits")
            label += ", " + String(format: format, visitCount)
        }
        
        return label
    }
    
    private var accessibilityTraits: AccessibilityTraits {
        var traits: AccessibilityTraits = [.button]
        
        if isSelected {
            traits.insert(.isSelected)
        }
        
        return traits
    }
}

// MARK: - Preview

#Preview {
    CalendarWidgetView(
        selectedDate: .constant(Date()),
        visits: [
            Visit(
                title: "Weekend visit",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
            ),
            Visit(
                title: "Dinner",
                startDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()) ?? Date()
            )
        ]
    ) { date in
        print("Selected date: \(date)")
    }
    .padding()
}
