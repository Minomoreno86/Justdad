//
//  AgendaListView.swift
//  JustDad - Agenda List View Component
//
//  Professional list view component for displaying visits with search,
//  filtering, and bulk selection capabilities
//

import SwiftUI

struct AgendaListView: View {
    // MARK: - Properties
    let visits: [AgendaVisit]
    let isEditMode: Bool
    let selectedVisits: Set<UUID>
    let onVisitTap: (AgendaVisit) -> Void
    let onVisitLongPress: (AgendaVisit) -> Void
    let onSelectionToggle: (UUID) -> Void
    let onEdit: (AgendaVisit) -> Void
    let onDelete: (AgendaVisit) -> Void
    let onDuplicate: (AgendaVisit) -> Void
    let onShare: (AgendaVisit) -> Void
    let onToggleFavorite: (AgendaVisit) -> Void
    let onArchive: (AgendaVisit) -> Void
    
    // MARK: - Body
    var body: some View {
        Group {
            if visits.isEmpty {
                emptyStateView
            } else {
                visitsList
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
            
            Text("No visits scheduled")
                .font(SuperDesign.Tokens.typography.titleMedium)
                .fontWeight(.medium)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            Text("Tap the + button to add your first visit")
                .font(SuperDesign.Tokens.typography.bodyMedium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Visits List
    private var visitsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(visits.sorted(by: { $0.startDate < $1.startDate })) { visit in
                VisitRowView(
                    visit: visit,
                    isEditMode: isEditMode,
                    isSelected: selectedVisits.contains(visit.id),
                    onTap: {
                        if isEditMode {
                            onSelectionToggle(visit.id)
                        } else {
                            onVisitTap(visit)
                        }
                    },
                    onLongPress: {
                        if !isEditMode {
                            onVisitLongPress(visit)
                        }
                    },
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onDuplicate: onDuplicate,
                    onShare: onShare,
                    onToggleFavorite: onToggleFavorite,
                    onArchive: onArchive
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: visit.id)
            }
            
            // Add bottom padding to account for floating button
            Color.clear
                .frame(height: 80)
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.3), value: visits.count)
    }
}

// MARK: - Visit Row View
struct VisitRowView: View {
    let visit: AgendaVisit
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onEdit: (AgendaVisit) -> Void
    let onDelete: (AgendaVisit) -> Void
    let onDuplicate: (AgendaVisit) -> Void
    let onShare: (AgendaVisit) -> Void
    let onToggleFavorite: (AgendaVisit) -> Void
    let onArchive: (AgendaVisit) -> Void
    
    var body: some View {
        SwipeActionView(
            content: {
                Button(action: onTap) {
                    HStack {
                        // Selection indicator in edit mode
                        if isEditMode {
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isSelected ? SuperDesign.Tokens.colors.primary : SuperDesign.Tokens.colors.textTertiary)
                                .font(.title3)
                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isSelected)
                        }
                        
                        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                            Text(visit.title)
                                .font(SuperDesign.Tokens.typography.titleSmall)
                                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                                .lineLimit(1)
                            
                            Text(timeRange(visit))
                                .font(SuperDesign.Tokens.typography.bodySmall)
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                            
                            if let notes = visit.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(SuperDesign.Tokens.typography.labelSmall)
                                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: SuperDesign.Tokens.space.xxs) {
                            Text(visit.visitType.displayName)
                                .font(SuperDesign.Tokens.typography.labelSmall)
                                .padding(.horizontal, SuperDesign.Tokens.space.sm)
                                .padding(.vertical, SuperDesign.Tokens.space.xxs)
                                .background(visitTypeColor(visit.visitType).opacity(0.15))
                                .foregroundColor(visitTypeColor(visit.visitType))
                                .cornerRadius(SuperDesign.Tokens.space.sm)
                            
                            if !isEditMode {
                                Image(systemName: "chevron.right")
                                    .font(SuperDesign.Tokens.typography.labelSmall)
                                    .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                            }
                        }
                    }
                    .superCard()
                    .scaleEffect(isSelected ? 0.98 : 1.0)
                    .animation(SuperDesign.Tokens.animation.easeInOut, value: isSelected)
                }
                .buttonStyle(PlainButtonStyle())
                .onLongPressGesture {
                    onLongPress()
                }
            },
            leftActions: createLeftActions(),
            rightActions: createRightActions()
        )
    }
    
    private func timeRange(_ visit: AgendaVisit) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return "\(formatter.string(from: visit.startDate)) - \(formatter.string(from: visit.endDate))"
    }
    
    private func visitTypeColor(_ type: AgendaVisitType) -> Color {
        switch type {
        case .medical: return SuperDesign.Tokens.colors.error
        case .school: return SuperDesign.Tokens.colors.info
        case .activity: return SuperDesign.Tokens.colors.success
        case .weekend: return SuperDesign.Tokens.colors.warning
        case .dinner: return SuperDesign.Tokens.colors.accent
        case .emergency: return SuperDesign.Tokens.colors.error
        case .general: return SuperDesign.Tokens.colors.textTertiary
        }
    }
    
    // MARK: - Swipe Actions
    private func createLeftActions() -> [SwipeActionConfig] {
        var actions: [SwipeActionConfig] = []
        
        // Edit action (always available)
        actions.append(.edit {
            onEdit(visit)
        })
        
        // Duplicate action (always available)
        actions.append(.duplicate {
            onDuplicate(visit)
        })
        
        return actions
    }
    
    private func createRightActions() -> [SwipeActionConfig] {
        var actions: [SwipeActionConfig] = []
        
        // Share action (always available)
        actions.append(.share {
            onShare(visit)
        })
        
        // Favorite action (always available)
        actions.append(.favorite {
            onToggleFavorite(visit)
        })
        
        // Archive action (always available)
        actions.append(.archive {
            onArchive(visit)
        })
        
        // Delete action (always available)
        actions.append(.delete {
            onDelete(visit)
        })
        
        return actions
    }
}
