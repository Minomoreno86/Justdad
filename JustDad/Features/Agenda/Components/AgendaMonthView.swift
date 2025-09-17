//
//  AgendaMonthView.swift
//  JustDad - Agenda Month View Component
//
//  Professional month view component for displaying visits in calendar format
//  with selected day events and navigation controls
//

import SwiftUI

struct AgendaMonthView: View {
    // MARK: - Properties
    let currentMonth: Date
    let selectedDate: Binding<Date>
    let visits: [AgendaVisit]
    let onDateTap: (Date) -> Void
    let onVisitTap: (AgendaVisit) -> Void
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // Enhanced Calendar with animation
            EnhancedCalendarMonthView(
                month: currentMonth,
                selectedDate: selectedDate,
                visits: visits,
                onDateTap: onDateTap,
                onVisitTap: onVisitTap
            )
            .background(SuperDesign.Tokens.colors.surface)
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.3), value: currentMonth)
            
            // Selected day events with proper scroll
            selectedDayEventsCard
                .padding(.horizontal, 20)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: selectedDate.wrappedValue)
            
            // Add bottom padding to account for floating button
            Color.clear
                .frame(height: 80)
        }
    }
    
    // MARK: - Selected Day Events Card
    private var selectedDayEventsCard: some View {
        let dayEvents = visits.filter { 
            Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate.wrappedValue)
        }
        
        return VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            HStack {
                Text("✨ Eventos del día")
                    .font(SuperDesign.Tokens.typography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(SuperDesign.Tokens.colors.primaryGradient)
                
                Spacer()
                
                Text("\(dayEvents.count)")
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, SuperDesign.Tokens.space.sm)
                    .padding(.vertical, SuperDesign.Tokens.space.xxs)
                    .background(SuperDesign.Tokens.colors.primary)
                    .cornerRadius(12)
            }
            
            if dayEvents.isEmpty {
                VStack(spacing: SuperDesign.Tokens.space.sm) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                    
                    Text("No hay eventos programados")
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SuperDesign.Tokens.space.lg)
            } else {
                ForEach(dayEvents, id: \.id) { visit in
                    Button(action: {
                        onVisitTap(visit)
                    }) {
                        HStack(spacing: SuperDesign.Tokens.space.md) {
                            // Color indicator
                            RoundedRectangle(cornerRadius: 3)
                                .fill(SuperDesign.Tokens.colors.primary)
                                .frame(width: 4, height: 40)
                            
                            VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                                Text(visit.title)
                                    .font(SuperDesign.Tokens.typography.bodyMedium)
                                    .fontWeight(.semibold)
                                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                                    .lineLimit(1)
                                
                                Text(timeRange(visit))
                                    .font(SuperDesign.Tokens.typography.bodySmall)
                                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                                
                                if let location = visit.location {
                                    HStack(spacing: SuperDesign.Tokens.space.xxs) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                                            .font(.caption)
                                        Text(location)
                                            .font(SuperDesign.Tokens.typography.bodySmall)
                                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                                .font(.caption)
                        }
                        .padding(.vertical, SuperDesign.Tokens.space.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(SuperDesign.Tokens.colors.surfaceSecondary)
                                .opacity(0.5)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .superCard()
    }
    
    // MARK: - Helper Methods
    private func timeRange(_ visit: AgendaVisit) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: visit.startDate)) - \(formatter.string(from: visit.endDate))"
    }
}
