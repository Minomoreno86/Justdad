//
//  VisitSwipeActions.swift
//  JustDad - Visit Swipe Actions
//
//  Professional swipe actions for visit items with contextual actions
//

import SwiftUI

// MARK: - Visit Swipe Actions
struct VisitSwipeActions: View {
    // MARK: - Properties
    let visit: AgendaVisit
    let onEdit: (AgendaVisit) -> Void
    let onDelete: (AgendaVisit) -> Void
    let onDuplicate: (AgendaVisit) -> Void
    let onShare: (AgendaVisit) -> Void
    let onToggleFavorite: (AgendaVisit) -> Void
    let onArchive: (AgendaVisit) -> Void
    
    // MARK: - Computed Properties
    private var leftActions: [SwipeActionConfig] {
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
    
    private var rightActions: [SwipeActionConfig] {
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
    
    // MARK: - Body
    var body: some View {
        EmptyView()
    }
    
    // MARK: - Static Methods
    static func createActions(
        for visit: AgendaVisit,
        onEdit: @escaping (AgendaVisit) -> Void,
        onDelete: @escaping (AgendaVisit) -> Void,
        onDuplicate: @escaping (AgendaVisit) -> Void,
        onShare: @escaping (AgendaVisit) -> Void,
        onToggleFavorite: @escaping (AgendaVisit) -> Void,
        onArchive: @escaping (AgendaVisit) -> Void
    ) -> (leftActions: [SwipeActionConfig], rightActions: [SwipeActionConfig]) {
        let swipeActions = VisitSwipeActions(
            visit: visit,
            onEdit: onEdit,
            onDelete: onDelete,
            onDuplicate: onDuplicate,
            onShare: onShare,
            onToggleFavorite: onToggleFavorite,
            onArchive: onArchive
        )
        
        return (swipeActions.leftActions, swipeActions.rightActions)
    }
}

// MARK: - Visit Swipe Action Manager
class VisitSwipeActionManager: ObservableObject {
    // MARK: - Singleton
    static let shared = VisitSwipeActionManager()
    
    // MARK: - Published Properties
    @Published var activeVisitId: UUID? = nil
    @Published var showingDeleteConfirmation = false
    @Published var visitToDelete: AgendaVisit? = nil
    @Published var showingShareSheet = false
    @Published var visitToShare: AgendaVisit? = nil
    
    // MARK: - Private Properties
    private var onEdit: ((AgendaVisit) -> Void)?
    private var onDelete: ((AgendaVisit) -> Void)?
    private var onDuplicate: ((AgendaVisit) -> Void)?
    private var onShare: ((AgendaVisit) -> Void)?
    private var onToggleFavorite: ((AgendaVisit) -> Void)?
    private var onArchive: ((AgendaVisit) -> Void)?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Configuration
    func configure(
        onEdit: @escaping (AgendaVisit) -> Void,
        onDelete: @escaping (AgendaVisit) -> Void,
        onDuplicate: @escaping (AgendaVisit) -> Void,
        onShare: @escaping (AgendaVisit) -> Void,
        onToggleFavorite: @escaping (AgendaVisit) -> Void,
        onArchive: @escaping (AgendaVisit) -> Void
    ) {
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
        self.onShare = onShare
        self.onToggleFavorite = onToggleFavorite
        self.onArchive = onArchive
    }
    
    // MARK: - Action Methods
    func edit(_ visit: AgendaVisit) {
        onEdit?(visit)
        clearActiveVisit()
    }
    
    func delete(_ visit: AgendaVisit) {
        visitToDelete = visit
        showingDeleteConfirmation = true
        clearActiveVisit()
    }
    
    func duplicate(_ visit: AgendaVisit) {
        onDuplicate?(visit)
        clearActiveVisit()
    }
    
    func share(_ visit: AgendaVisit) {
        visitToShare = visit
        showingShareSheet = true
        clearActiveVisit()
    }
    
    func toggleFavorite(_ visit: AgendaVisit) {
        onToggleFavorite?(visit)
        clearActiveVisit()
    }
    
    func archive(_ visit: AgendaVisit) {
        onArchive?(visit)
        clearActiveVisit()
    }
    
    func confirmDelete() {
        guard let visit = visitToDelete else { return }
        onDelete?(visit)
        showingDeleteConfirmation = false
        visitToDelete = nil
    }
    
    func cancelDelete() {
        showingDeleteConfirmation = false
        visitToDelete = nil
    }
    
    func dismissShareSheet() {
        showingShareSheet = false
        visitToShare = nil
    }
    
    // MARK: - Private Methods
    private func clearActiveVisit() {
        activeVisitId = nil
    }
}

// MARK: - Visit Swipe Action Modifier
struct VisitSwipeActionModifier: ViewModifier {
    let visit: AgendaVisit
    @StateObject private var actionManager = VisitSwipeActionManager.shared
    
    func body(content: Content) -> some View {
        let actions = VisitSwipeActions.createActions(
            for: visit,
            onEdit: { actionManager.edit($0) },
            onDelete: { actionManager.delete($0) },
            onDuplicate: { actionManager.duplicate($0) },
            onShare: { actionManager.share($0) },
            onToggleFavorite: { actionManager.toggleFavorite($0) },
            onArchive: { actionManager.archive($0) }
        )
        
        content
            .swipeActions(
                id: visit.id,
                leftActions: actions.leftActions,
                rightActions: actions.rightActions
            )
    }
}

// MARK: - View Extension
extension View {
    func visitSwipeActions(for visit: AgendaVisit) -> some View {
        self.modifier(VisitSwipeActionModifier(visit: visit))
    }
}

// MARK: - Swipe Action Confirmation Views
struct SwipeActionConfirmationView: View {
    @StateObject private var actionManager = VisitSwipeActionManager.shared
    
    var body: some View {
        EmptyView()
            .alert("Eliminar Visita", isPresented: $actionManager.showingDeleteConfirmation) {
                Button("Cancelar", role: .cancel) {
                    actionManager.cancelDelete()
                }
                Button("Eliminar", role: .destructive) {
                    actionManager.confirmDelete()
                }
            } message: {
                if let visit = actionManager.visitToDelete {
                    Text("¿Estás seguro de que quieres eliminar la visita '\(visit.title)'? Esta acción no se puede deshacer.")
                }
            }
            .sheet(isPresented: $actionManager.showingShareSheet) {
                if let visit = actionManager.visitToShare {
                    ShareSheet(visit: visit)
                }
            }
    }
}

// MARK: - Share Sheet
struct ShareSheet: View {
    let visit: AgendaVisit
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: SuperDesign.Tokens.space.lg) {
                // Visit Header
                VStack(spacing: SuperDesign.Tokens.space.sm) {
                    Text(visit.title)
                        .font(SuperDesign.Tokens.typography.headlineMedium)
                        .fontWeight(.bold)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                    
                    Text(visit.visitType.displayName)
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                }
                
                // Visit Details
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
                    if let location = visit.location, !location.isEmpty {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(SuperDesign.Tokens.colors.primary)
                            Text(visit.location ?? "")
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                        Text(visit.startDate, style: .date)
                            .font(SuperDesign.Tokens.typography.bodyMedium)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                        Text(visit.startDate, style: .time)
                            .font(SuperDesign.Tokens.typography.bodyMedium)
                    }
                    
                    if let notes = visit.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                            Text("Notas:")
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                                .fontWeight(.medium)
                            Text(notes)
                                .font(SuperDesign.Tokens.typography.bodySmall)
                                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(SuperDesign.Tokens.colors.surfaceSecondary)
                .cornerRadius(SuperDesign.Tokens.space.sm)
                
                Spacer()
                
                // Share Button
                Button(action: {
                    shareVisit()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Compartir")
                    }
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(SuperDesign.Tokens.colors.primary)
                    .cornerRadius(SuperDesign.Tokens.space.sm)
                }
            }
            .padding()
            .navigationTitle("Compartir Visita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareVisit() {
        let shareText = createShareText()
        let activityViewController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
    }
    
    private func createShareText() -> String {
        var text = "📅 \(visit.title)\n"
        text += "📅 \(visit.startDate.formatted(date: .abbreviated, time: .omitted))\n"
        text += "🕐 \(visit.startDate.formatted(date: .omitted, time: .shortened))\n"
        
        if let location = visit.location, !location.isEmpty {
            text += "📍 \(location)\n"
        }
        
        if let notes = visit.notes, !notes.isEmpty {
            text += "📝 \(notes)\n"
        }
        
        text += "\nCompartido desde JustDad"
        return text
    }
}
