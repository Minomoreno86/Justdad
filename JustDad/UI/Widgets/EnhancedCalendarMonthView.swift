import SwiftUI

struct EnhancedCalendarMonthView: View {
    let month: Date
    @Binding var selectedDate: Date
    let visits: [AgendaVisit]
    let onDateTap: (Date) -> Void
    
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
                            visitCount: visitsCount(for: date),
                            onTap: { onDateTap(date) }
                        )
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.vertical, 8)
    }
    
    private var weekdayHeaderView: some View {
        HStack {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
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
    let visitCount: Int
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected || isToday ? .semibold : .regular))
                    .foregroundColor(textColor)
                
                // Visit indicator dots
                if visitCount > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<min(visitCount, 3), id: \.self) { _ in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 4, height: 4)
                        }
                        
                        if visitCount > 3 {
                            Text("+")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 6)
                } else {
                    Color.clear
                        .frame(height: 6)
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .gray.opacity(0.4)
        } else if isSelected {
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
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue
        } else {
            return .clear
        }
    }
}

#Preview {
    @State var selectedDate = Date()
    
    EnhancedCalendarMonthView(
        month: Date(),
        selectedDate: $selectedDate,
        visits: [],
        onDateTap: { _ in }
    )
}
