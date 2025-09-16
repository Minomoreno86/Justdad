//
//  VisitDetailView.swift
//  JustDad - Visit Detail View
//
//  Professional detailed view for visit information
//

import SwiftUI

struct VisitDetailView: View {
    let visit: AgendaVisit
    let onEdit: (AgendaVisit) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SuperDesign.Tokens.space.lg) {
                    // Header Card
                    headerCard
                    
                    // Details Card
                    detailsCard
                    
                    // Actions Card
                    actionsCard
                    
                    Spacer(minLength: SuperDesign.Tokens.space.xl)
                }
                .padding(SuperDesign.Tokens.space.lg)
            }
            .background(SuperDesign.Tokens.colors.surfaceGradient)
            .navigationTitle("Detalles de la Visita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SuperButton(
                        title: "Cerrar",
                        style: .ghost,
                        size: .small
                    ) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    SuperButton(
                        title: "Editar",
                        style: .primary,
                        size: .small
                    ) {
                        onEdit(visit)
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            HStack {
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                    Text(visit.title)
                        .font(SuperDesign.Tokens.typography.headlineMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(SuperDesign.Tokens.colors.primaryGradient)
                    
                    HStack(spacing: SuperDesign.Tokens.space.xs) {
                        Image(systemName: "calendar")
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                        Text(formatDateRange())
                            .font(SuperDesign.Tokens.typography.bodyMedium)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Visit type indicator
                VStack {
                    Image(systemName: visit.visitType.systemIcon)
                        .font(.title2)
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                    
                    Text(visit.visitType.displayName)
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                }
            }
            
            // Status indicator
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                
                Text(statusText)
                    .font(SuperDesign.Tokens.typography.bodySmall)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                
                Spacer()
            }
        }
        .superCard()
    }
    
    // MARK: - Details Card
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            Text("📝 Detalles")
                .font(SuperDesign.Tokens.typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            VStack(spacing: SuperDesign.Tokens.space.md) {
                // Time
                DetailRow(
                    icon: "clock",
                    title: "Horario",
                    value: formatTimeRange(),
                    color: SuperDesign.Tokens.colors.info
                )
                
                // Location
                if let location = visit.location, !location.isEmpty {
                    DetailRow(
                        icon: "location",
                        title: "Ubicación",
                        value: location,
                        color: SuperDesign.Tokens.colors.success
                    )
                }
                
                // Duration
                DetailRow(
                    icon: "timer",
                    title: "Duración",
                    value: formatDuration(),
                    color: SuperDesign.Tokens.colors.warning
                )
                
                // Notes
                if let notes = visit.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundColor(SuperDesign.Tokens.colors.accent)
                            Text("Notas")
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                                .fontWeight(.medium)
                                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        }
                        
                        Text(notes)
                            .font(SuperDesign.Tokens.typography.bodyMedium)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            .padding(.leading, SuperDesign.Tokens.space.lg)
                    }
                }
            }
        }
        .superCard()
    }
    
    // MARK: - Actions Card
    private var actionsCard: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            Text("🚀 Acciones Rápidas")
                .font(SuperDesign.Tokens.typography.titleMedium)
                .fontWeight(.semibold)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: SuperDesign.Tokens.space.md) {
                ActionButton(
                    icon: "square.and.pencil",
                    title: "Editar",
                    color: SuperDesign.Tokens.colors.primary
                ) {
                    onEdit(visit)
                    dismiss()
                }
                
                ActionButton(
                    icon: "calendar.badge.plus",
                    title: "Duplicar",
                    color: SuperDesign.Tokens.colors.success
                ) {
                    // TODO: Implement duplicate functionality
                }
                
                if let location = visit.location, !location.isEmpty {
                    ActionButton(
                        icon: "map",
                        title: "Ver Mapa",
                        color: SuperDesign.Tokens.colors.info
                    ) {
                        // TODO: Open in Maps
                    }
                }
                
                ActionButton(
                    icon: "square.and.arrow.up",
                    title: "Compartir",
                    color: SuperDesign.Tokens.colors.accent
                ) {
                    // TODO: Share functionality
                }
            }
        }
        .superCard()
    }
    
    // MARK: - Helper Views
    private struct DetailRow: View {
        let icon: String
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            HStack(spacing: SuperDesign.Tokens.space.md) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                    Text(title)
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                    
                    Text(value)
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                }
                
                Spacer()
            }
        }
    }
    
    private struct ActionButton: View {
        let icon: String
        let title: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: SuperDesign.Tokens.space.sm) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(SuperDesign.Tokens.space.md)
                .background(SuperDesign.Tokens.colors.surfaceSecondary)
                .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Helper Functions
    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        
        if Calendar.current.isDate(visit.startDate, inSameDayAs: visit.endDate) {
            return formatter.string(from: visit.startDate)
        } else {
            return "\(formatter.string(from: visit.startDate)) - \(formatter.string(from: visit.endDate))"
        }
    }
    
    private func formatTimeRange() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: visit.startDate)) - \(formatter.string(from: visit.endDate))"
    }
    
    private func formatDuration() -> String {
        let duration = visit.endDate.timeIntervalSince(visit.startDate)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) minutos"
        }
    }
    
    private var statusColor: Color {
        let now = Date()
        if visit.endDate < now {
            return SuperDesign.Tokens.colors.textTertiary
        } else if visit.startDate <= now && visit.endDate >= now {
            return SuperDesign.Tokens.colors.success
        } else {
            return SuperDesign.Tokens.colors.primary
        }
    }
    
    private var statusText: String {
        let now = Date()
        if visit.endDate < now {
            return "Finalizada"
        } else if visit.startDate <= now && visit.endDate >= now {
            return "En curso"
        } else {
            return "Programada"
        }
    }
}

// MARK: - Preview
#Preview {
    VisitDetailView(
        visit: AgendaVisit(
            title: "Visita con los niños",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
            location: "Parque Central",
            notes: "Llevar juegos y merienda"
        )
    ) { _ in }
}
