//
//  SyncNotificationBanner.swift
//  JustDad - Sync Notification Banner
//
//  Professional sync notification banner with animations and user actions
//

import SwiftUI

struct SyncNotificationBanner: View {
    // MARK: - Properties
    let syncStatus: SimpleSyncStatus
    let lastSyncDate: Date?
    let onSyncTap: () -> Void
    let onRetryTap: (() -> Void)?
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Computed Properties
    private var bannerColor: Color {
        switch syncStatus {
        case .idle, .success:
            return SuperDesign.Tokens.colors.success
        case .syncing:
            return SuperDesign.Tokens.colors.primary
        case .failed:
            return SuperDesign.Tokens.colors.error
        case .conflict:
            return SuperDesign.Tokens.colors.warning
        }
    }
    
    private var bannerIcon: String {
        switch syncStatus {
        case .idle:
            return "checkmark.circle.fill"
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
    
    private var bannerTitle: String {
        switch syncStatus {
        case .idle:
            return "Sincronizado"
        case .syncing:
            return "Sincronizando..."
        case .success:
            return "Sincronización exitosa"
        case .failed:
            return "Error de sincronización"
        case .conflict:
            return "Conflicto detectado"
        }
    }
    
    private var bannerMessage: String {
        switch syncStatus {
        case .idle:
            return "Los datos están actualizados"
        case .syncing:
            return "Sincronizando con EventKit..."
        case .success:
            return "Los datos se han sincronizado correctamente"
        case .failed:
            return "No se pudo completar la sincronización"
        case .conflict:
            return "Hay conflictos que requieren atención"
        }
    }
    
    // MARK: - Body
    var body: some View {
        if shouldShowBanner {
            VStack(spacing: 0) {
                bannerContent
                    .offset(y: dragOffset)
                    .gesture(dragGesture)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isVisible = true
                }
            }
            .onDisappear {
                isVisible = false
            }
        }
    }
    
    // MARK: - Banner Content
    private var bannerContent: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            // Status Icon
            if syncStatus == .syncing {
                ProgressView()
                    .scaleEffect(0.8)
                    .foregroundColor(.white)
            } else {
                Image(systemName: bannerIcon)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(bannerTitle)
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(bannerMessage)
                    .font(SuperDesign.Tokens.typography.bodySmall)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Action Buttons
            actionButtons
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .background(bannerColor)
        .cornerRadius(SuperDesign.Tokens.space.sm)
        .shadow(color: bannerColor.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.top, SuperDesign.Tokens.space.sm)
    }
    
    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: SuperDesign.Tokens.space.xs) {
            switch syncStatus {
            case .idle, .success:
                Button(action: onSyncTap) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                
            case .syncing:
                // No action buttons during sync
                EmptyView()
                
            case .failed:
                if let onRetryTap = onRetryTap {
                    Button(action: onRetryTap) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
                
            case .conflict:
                Button(action: onSyncTap) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
            }
            
            // Dismiss Button
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Computed Properties
    private var shouldShowBanner: Bool {
        switch syncStatus {
        case .idle:
            return false
        case .syncing, .success, .failed, .conflict:
            return true
        }
    }
    
    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height < -50 {
                    // Swipe up to dismiss
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                } else {
                    // Return to original position
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                    }
                }
            }
    }
}

// MARK: - Sync Notification Manager
class SyncNotificationManager: ObservableObject {
    // MARK: - Singleton
    static let shared = SyncNotificationManager()
    
    // MARK: - Published Properties
    @Published var isVisible: Bool = false
    @Published var syncStatus: SimpleSyncStatus = .idle
    @Published var lastSyncDate: Date? = nil
    
    // MARK: - Private Properties
    private var dismissTimer: Timer?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func showSyncStatus(_ status: SimpleSyncStatus, lastSync: Date? = nil) {
        syncStatus = status
        lastSyncDate = lastSync
        isVisible = true
        
        // Auto-dismiss for success status
        if case .success = status {
            dismissTimer?.invalidate()
            dismissTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
                self.dismiss()
            }
        } else {
            dismissTimer?.invalidate()
        }
    }
    
    func dismiss() {
        isVisible = false
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
    
    func updateSyncStatus(_ status: SimpleSyncStatus) {
        syncStatus = status
    }
}

// MARK: - Sync Notification Overlay
struct SyncNotificationOverlay: View {
    // MARK: - Properties
    @StateObject private var notificationManager = SyncNotificationManager.shared
    let onSyncTap: () -> Void
    let onRetryTap: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack {
            if notificationManager.isVisible {
                SyncNotificationBanner(
                    syncStatus: notificationManager.syncStatus,
                    lastSyncDate: notificationManager.lastSyncDate,
                    onSyncTap: onSyncTap,
                    onRetryTap: onRetryTap,
                    onDismiss: {
                        notificationManager.dismiss()
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
            
            Spacer()
        }
        .zIndex(1000) // Ensure it appears above other content
    }
}
