import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let isInMonth: Bool
    let isSelected: Bool
    let badgeCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.footnote.weight(isSelected ? .bold : .regular))
                .foregroundColor(isInMonth ? (isSelected ? .white : .primary) : .secondary)
                .frame(maxWidth: .infinity)

            // Dot/badge
            if badgeCount > 0 {
                Circle()
                    .frame(width: 6, height: 6)
                    .opacity(0.9)
            } else {
                Circle()
                    .frame(width: 6, height: 6)
                    .opacity(0.0)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor : Color.clear)
        )
    }
}
