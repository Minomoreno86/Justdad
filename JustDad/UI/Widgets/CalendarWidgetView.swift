import SwiftUI

struct CalendarWidgetView: View {
    @Binding var selectedDate: Date
    let visits: [AgendaVisit]
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .onChange(of: selectedDate) { _, newDate in
                onDateSelected(newDate)
            }
        }
        .padding()
    }
}
