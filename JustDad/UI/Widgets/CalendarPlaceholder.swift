//
//  CalendarPlaceholder.swift
//  JustDad - Calendar placeholder component
//
//  Simple calendar grid placeholder for visit scheduling
//

import SwiftUI

struct CalendarPlaceholder: View {
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        hasEvent: mockEvents.contains { calendar.isDate($0, inSameDayAs: date) }
                    ) {
                        selectedDate = date
                    }
                }
            }
            
            // TODO note
            Text("TODO: Implement real calendar with visit data")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .padding()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Properties
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
    
    private var mockEvents: [Date] {
        let today = Date()
        return [
            calendar.date(byAdding: .day, value: 3, to: today) ?? today,
            calendar.date(byAdding: .day, value: 7, to: today) ?? today,
            calendar.date(byAdding: .day, value: 14, to: today) ?? today
        ]
    }
    
    // MARK: - Navigation Methods
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

// MARK: - Day Cell Component
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvent: Bool
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isCurrentMonth: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 36, height: 36)
                
                // Day number
                Text(dayNumber)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                
                // Event indicator
                if hasEvent {
                    VStack {
                        Spacer()
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .offset(y: -2)
                    }
                    .frame(width: 36, height: 36)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
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
}

#Preview {
    CalendarPlaceholder()
        .padding()
}
