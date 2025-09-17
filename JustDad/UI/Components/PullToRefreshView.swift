//
//  PullToRefreshView.swift
//  JustDad - Pull to Refresh Component
//
//  Professional pull-to-refresh component with custom animations and states
//

import SwiftUI
import UIKit

struct PullToRefreshView<Content: View>: View {
    // MARK: - Properties
    let content: Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var pullOffset: CGFloat = 0
    @State private var refreshThreshold: CGFloat = 80
    
    // MARK: - Initialization
    init(onRefresh: @escaping () async -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Pull to refresh indicator
                    pullToRefreshIndicator
                        .frame(height: isRefreshing ? 60 : max(0, pullOffset))
                        .opacity(isRefreshing ? 1 : min(1, pullOffset / refreshThreshold))
                    
                    content
                }
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: scrollGeometry.frame(in: .global).minY)
                    }
                )
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollOffset(value)
            }
        }
    }
    
    // MARK: - Pull to Refresh Indicator
    private var pullToRefreshIndicator: some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            if isRefreshing {
                // Refreshing state
                HStack(spacing: SuperDesign.Tokens.space.sm) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: SuperDesign.Tokens.colors.primary))
                        .scaleEffect(0.8)
                    
                    Text("Actualizando...")
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                }
            } else {
                // Pull to refresh state
                HStack(spacing: SuperDesign.Tokens.space.sm) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                        .rotationEffect(.degrees(pullOffset > refreshThreshold ? 180 : 0))
                        .animation(SuperDesign.Tokens.animation.easeInOut, value: pullOffset > refreshThreshold)
                    
                    Text(pullOffset > refreshThreshold ? "Suelta para actualizar" : "Desliza para actualizar")
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        .animation(SuperDesign.Tokens.animation.easeInOut, value: pullOffset > refreshThreshold)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
    }
    
    // MARK: - Scroll Handling
    private func handleScrollOffset(_ offset: CGFloat) {
        let adjustedOffset = max(0, offset)
        
        if !isRefreshing {
            pullOffset = adjustedOffset
            
            // Trigger refresh when user releases after threshold
            if adjustedOffset > refreshThreshold {
                Task {
                    await triggerRefresh()
                }
            }
        }
    }
    
    private func triggerRefresh() async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Perform refresh
        await onRefresh()
        
        // Reset state
        withAnimation(SuperDesign.Tokens.animation.easeInOut) {
            isRefreshing = false
            pullOffset = 0
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    PullToRefreshView {
        try? await Task.sleep(nanoseconds: 2_000_000_000) // Simulate refresh
    } content: {
        VStack(spacing: 20) {
            ForEach(0..<10) { index in
                HStack {
                    Text("Item \(index + 1)")
                        .font(SuperDesign.Tokens.typography.bodyMedium)
                    Spacer()
                }
                .padding()
                .background(SuperDesign.Tokens.colors.surface)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
