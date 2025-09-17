//
//  AgendaWeekView.swift
//  JustDad - Agenda Week View Component
//
//  Professional week view component for displaying visits in weekly calendar format
//

import SwiftUI

struct AgendaWeekView: View {
    // MARK: - Properties
    let selectedDate: Binding<Date>
    let visits: [AgendaVisit]
    let onVisitTap: (AgendaVisit) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            WeekCalendarView(
                selectedDate: selectedDate,
                visits: visits,
                onVisitTap: onVisitTap
            )
            .background(SuperDesign.Tokens.colors.surface)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.3), value: selectedDate.wrappedValue)
            
            // Add bottom padding to account for floating button
            Color.clear
                .frame(height: 80)
        }
    }
}
