import SwiftUI

struct CalendarMonthView: View {
    let month: Date
    @Binding var selectedDate: Date
    let visitsForDay: (Date) -> Int
    let onPrev: () -> Void
    let onNext: () -> Void

    private let cal = Calendar.current

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onPrev) { Image(systemName: "chevron.left") }
                Spacer()
                Text(monthTitle(month)).font(.headline)
                Spacer()
                Button(action: onNext) { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal, 4)

            let days = daysForMonth(month)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(weekdayHeaders(), id: \.self) { s in
                    Text(s).font(.caption2).foregroundColor(.secondary).frame(maxWidth: .infinity)
                }
                ForEach(days, id: \.self) { day in
                    let inMonth = cal.isDate(day, equalTo: month, toGranularity: .month)
                    let isSel = cal.isDate(day, inSameDayAs: selectedDate)
                    CalendarDayCell(
                        date: day,
                        isInMonth: inMonth,
                        isSelected: isSel,
                        badgeCount: visitsForDay(day)
                    )
                    .onTapGesture { selectedDate = day }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func weekdayHeaders() -> [String] {
        let symbols = cal.shortStandaloneWeekdaySymbols // locale-aware
        let first = cal.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }

    private func monthTitle(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d).capitalized
    }

    private func daysForMonth(_ d: Date) -> [Date] {
        let comps = cal.dateComponents([.year, .month], from: d)
        let start = cal.date(from: comps)!
        let range = cal.range(of: .day, in: .month, for: start)!
        let firstWeekday = cal.component(.weekday, from: start) - cal.firstWeekday
        let leading = (firstWeekday + 7) % 7
        var result: [Date] = []
        // días del grid (6 semanas * 7 días = 42)
        let total = 42
        for i in 0..<total {
            let dayOffset = i - leading
            let date = cal.date(byAdding: .day, value: dayOffset, to: start)!
            result.append(date)
        }
        return result
    }
}
