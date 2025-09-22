//
//  SyncStatusIndicator.swift
//  JustDad - EventKit Sync Status Indicator
//
//  Professional sync status indicator with real-time updates and user feedback
//

import SwiftUI

struct SyncStatusIndicator: View {
    // MARK: - Properties
    let syncStatus: SimpleSyncStatus
    let lastSyncDate: Date?
    let onSyncTap: () -> Void
    let onRetryTap: (() -> Void)?
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        switch syncStatus {
        case .idle:
            return SuperDesign.Tokens.colors.textSecondary
        case .syncing:
            return SuperDesign.Tokens.colors.primary
        case .success:
            return SuperDesign.Tokens.colors.success
        case .failed:
            return SuperDesign.Tokens.colors.error
        case .conflict:
            return SuperDesign.Tokens.colors.warning
        }
    }
    
    private var statusIcon: String {
        switch syncStatus {
        case .idle:
            return "arrow.clockwise"
        case .syncing:
            return "arrow.clockwise"
        case .success:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        case .conflict:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var statusText: String {
        switch syncStatus {
        case .idle:
            return "Sincronizado"
        case .syncing:
            return "Sincronizando..."
        case .success:
            return "Sincronizado"
        case .failed:
            return "Error de sincronización"
        case .conflict:
            return "Conflicto detectado"
        }
    }
    
    private var lastSyncText: String {
        guard let lastSync = lastSyncDate else { return "Nunca" }
        return formatLastSyncDate(lastSync)
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            // Status Icon
            if syncStatus == .syncing {
                ProgressView()
                    .scaleEffect(0.8)
                    .foregroundColor(statusColor)
            } else {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.system(size: 14, weight: .medium))
            }
            
            // Status Text
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(SuperDesign.Tokens.typography.bodySmall)
                    .fontWeight(.medium)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Text(lastSyncText)
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
            
            Spacer()
            
            // Action Button
            actionButton
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .background(backgroundView)
        .cornerRadius(SuperDesign.Tokens.space.sm)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
    
    // MARK: - Action Button
    @ViewBuilder
    private var actionButton: some View {
        switch syncStatus {
        case .idle, .success:
            Button(action: onSyncTap) {
                HStack(spacing: SuperDesign.Tokens.space.xxs) {
                    Image(systemName: "arrow.clockwise")
                    Text("Sincronizar")
                }
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.primary)
            }
            
        case .syncing:
            HStack(spacing: SuperDesign.Tokens.space.xxs) {
                ProgressView()
                    .scaleEffect(0.6)
                Text("Sincronizando...")
            }
            .font(SuperDesign.Tokens.typography.labelSmall)
            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            
        case .failed:
            if let onRetryTap = onRetryTap {
                Button(action: onRetryTap) {
                    HStack(spacing: SuperDesign.Tokens.space.xxs) {
                        Image(systemName: "arrow.clockwise")
                        Text("Reintentar")
                    }
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.error)
                }
            }
            
        case .conflict:
            Button(action: onSyncTap) {
                HStack(spacing: SuperDesign.Tokens.space.xxs) {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Resolver")
                }
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.warning)
            }
        }
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        Group {
            switch syncStatus {
            case .idle, .success:
                SuperDesign.Tokens.colors.surfaceSecondary
            case .syncing:
                SuperDesign.Tokens.colors.primary.opacity(0.1)
            case .failed:
                SuperDesign.Tokens.colors.error.opacity(0.1)
            case .conflict:
                SuperDesign.Tokens.colors.warning.opacity(0.1)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formatLastSyncDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Sync Status Header
struct SyncStatusHeader: View {
    // MARK: - Properties
    let syncStatus: SimpleSyncStatus
    let lastSyncDate: Date?
    let onSyncTap: () -> Void
    let onRetryTap: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.xs) {
            // Main Status
            SyncStatusIndicator(
                syncStatus: syncStatus,
                lastSyncDate: lastSyncDate,
                onSyncTap: onSyncTap,
                onRetryTap: onRetryTap
            )
            
            // Additional Info
            if syncStatus == .conflict {
                conflictInfoView
            }
        }
    }
    
    // MARK: - Conflict Info View
    private var conflictInfoView: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(SuperDesign.Tokens.colors.warning)
                .font(.system(size: 12))
            
            Text("Hay conflictos entre la app y el calendario del sistema")
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.xs)
        .background(SuperDesign.Tokens.colors.warning.opacity(0.1))
        .cornerRadius(SuperDesign.Tokens.space.xs)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
}

// MARK: - Sync Progress View
struct SyncProgressView: View {
    // MARK: - Properties
    let progress: Double
    let status: String
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            // Progress Bar
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: SuperDesign.Tokens.colors.primary))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            // Status Text
            Text(status)
                .font(SuperDesign.Tokens.typography.bodySmall)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .background(SuperDesign.Tokens.colors.surfaceSecondary)
        .cornerRadius(SuperDesign.Tokens.space.sm)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
}

// MARK: - Sync Error View
struct SyncErrorView: View {
    // MARK: - Properties
    let error: Error
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            // Error Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(SuperDesign.Tokens.colors.error)
                .font(.system(size: 16))
            
            // Error Message
            VStack(alignment: .leading, spacing: 2) {
                Text("Error de Sincronización")
                    .font(SuperDesign.Tokens.typography.bodySmall)
                    .fontWeight(.medium)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Text(error.localizedDescription)
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: SuperDesign.Tokens.space.xs) {
                Button("Reintentar") {
                    onRetry()
                }
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.error)
                
                Button("Cerrar") {
                    onDismiss()
                }
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .background(SuperDesign.Tokens.colors.error.opacity(0.1))
        .cornerRadius(SuperDesign.Tokens.space.sm)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
}
