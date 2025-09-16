import SwiftUI

struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    let visits: [AgendaVisit]
    let onVisitTap: (AgendaVisit) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 16) {
            // Week header
            weekHeaderView
            
            // Week timeline
            weekTimelineView
        }
        .padding()
    }
    
    private var weekHeaderView: some View {
        HStack {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 4) {
                    Text(dayFormatter.string(from: date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(dayNumberFormatter.string(from: date))
                        .font(.headline)
                        .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .medium)
                        .foregroundColor(calendar.isDate(date, inSameDayAs: selectedDate) ? .blue : .primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.1) : Color.clear)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var weekTimelineView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<24, id: \.self) { hour in
                    HStack(alignment: .top, spacing: 8) {
                        // Hour label
                        Text("\(hour):00")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: 40, alignment: .trailing)
                        
                        // Week days content
                        HStack(spacing: 0) {
                            ForEach(weekDays, id: \.self) { date in
                                VStack(spacing: 2) {
                                    ForEach(visitsForDateAndHour(date: date, hour: hour), id: \.id) { visit in
                                        Button(action: { onVisitTap(visit) }) {
                                            Text(visit.title)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(Color.blue)
                                                .cornerRadius(4)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    if visitsForDateAndHour(date: date, hour: hour).isEmpty {
                                        Color.clear
                                            .frame(height: 20)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Rectangle()
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 400)
    }
    
    private var weekDays: [Date] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
        return (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)
        }
    }
    
    private func visitsForDateAndHour(date: Date, hour: Int) -> [AgendaVisit] {
        return visits.filter { visit in
            calendar.isDate(visit.startDate, inSameDayAs: date) &&
            calendar.component(.hour, from: visit.startDate) == hour
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
}

#Preview {
    @State var selectedDate = Date()
    
    WeekCalendarView(
        selectedDate: $selectedDate,
        visits: [],
        onVisitTap: { _ in }
    )
}
