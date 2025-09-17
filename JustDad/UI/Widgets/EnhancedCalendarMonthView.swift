import SwiftUI

struct EnhancedCalendarMonthView: View {
    let month: Date
    @Binding var selectedDate: Date
    let visits: [AgendaVisit]
    let onDateTap: (Date) -> Void
    let onVisitTap: (AgendaVisit) -> Void
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 12) {
            // Days of week header
            weekdayHeaderView
            
            // Calendar grid with proper scroll behavior
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: month, toGranularity: .month),
                            visits: visitsForDate(date),
                            onDateTap: { onDateTap(date) },
                            onVisitTap: onVisitTap
                        )
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding(.horizontal, SuperDesign.Tokens.space.xs)
        }
        .padding(.vertical, SuperDesign.Tokens.space.xs)
    }
    
    private var weekdayHeaderView: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .fontWeight(.medium)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.xs)
    }
    
    private var daysInMonth: [Date?] {
        guard let firstOfMonth = calendar.dateInterval(of: .month, for: month)?.start else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let adjustedFirstWeekday = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days: [Date?] = Array(repeating: nil, count: adjustedFirstWeekday)
        
        let numberOfDays = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Pad to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func visitsCount(for date: Date) -> Int {
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }.count
    }
    
    private func visitsForDate(_ date: Date) -> [AgendaVisit] {
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date)
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekday = calendar.firstWeekday - 1
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let visits: [AgendaVisit]
    let onDateTap: () -> Void
    let onVisitTap: (AgendaVisit) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            // Date number - always tappable
            Button(action: onDateTap) {
                Text("\(calendar.component(.day, from: date))")
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .fontWeight(isSelected || isToday ? .semibold : .regular)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Visit indicators - just dots
            if !visits.isEmpty {
                HStack(spacing: 2) {
                    ForEach(visits.prefix(4), id: \.id) { visit in
                        Circle()
                            .fill(visitTypeColor(visit.visitType))
                            .frame(width: 6, height: 6)
                    }
                    
                    if visits.count > 4 {
                        Text("+\(visits.count - 4)")
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            .fontWeight(.medium)
                    }
                }
                .frame(height: 8)
            } else {
                Color.clear
                    .frame(height: 8)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                .stroke(borderColor, lineWidth: isSelected ? SuperDesign.Tokens.effects.borderWidthThick : 0)
        )
        .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
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
    
    private var textColor: Color {
        if !isCurrentMonth {
            return SuperDesign.Tokens.colors.textTertiary.opacity(0.4)
        } else if isSelected {
            return SuperDesign.Tokens.colors.surface
        } else if isToday {
            return SuperDesign.Tokens.colors.primary
        } else {
            return SuperDesign.Tokens.colors.textPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return SuperDesign.Tokens.colors.primary
        } else if isToday {
            return SuperDesign.Tokens.colors.primary.opacity(SuperDesign.Tokens.effects.opacitySubtle)
        } else {
            return SuperDesign.Tokens.colors.surface
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return SuperDesign.Tokens.colors.primary
        } else if isToday {
            return SuperDesign.Tokens.colors.primary
        } else {
            return SuperDesign.Tokens.colors.border
        }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date()
    
    EnhancedCalendarMonthView(
        month: Date(),
        selectedDate: .constant(Date()),
        visits: [],
        onDateTap: { _ in },
        onVisitTap: { _ in }
    )
}

#Preview("With Visits") {
    @Previewable @State var selectedDate = Date()
    
    let sampleVisits = [
        AgendaVisit(
            id: UUID(),
            title: "Visit with Kids",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            location: "Park",
            notes: "Fun day at the park",
            reminderMinutes: 30,
            isRecurring: false
        )
    ]
    
    EnhancedCalendarMonthView(
        month: Date(),
        selectedDate: $selectedDate,
        visits: sampleVisits,
        onDateTap: { _ in },
        onVisitTap: { _ in }
    )
}
