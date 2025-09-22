//
//  LoadingStateView.swift
//  JustDad - Loading State Component
//
//  Professional loading state component with SuperDesign integration
//  Provides consistent loading indicators across the app
//

import SwiftUI

struct LoadingStateView: View {
    // MARK: - Properties
    let message: String
    let showProgress: Bool
    let progress: Double
    let style: LoadingStyle
    
    // MARK: - Initialization
    init(
        message: String = "Cargando...",
        showProgress: Bool = false,
        progress: Double = 0.0,
        style: LoadingStyle = .default
    ) {
        self.message = message
        self.showProgress = showProgress
        self.progress = progress
        self.style = style
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.lg) {
            // Loading indicator
            loadingIndicator
            
            // Message
            Text(message)
                .font(SuperDesign.Tokens.typography.bodyMedium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
            
            // Progress bar (if enabled)
            if showProgress {
                progressBar
            }
        }
        .padding(SuperDesign.Tokens.space.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SuperDesign.Tokens.colors.surface)
    }
    
    // MARK: - Loading Indicator
    private var loadingIndicator: some View {
        Group {
            switch style {
            case .default:
                defaultSpinner
            case .pulse:
                pulseAnimation
            case .dots:
                dotsAnimation
            case .skeleton:
                skeletonAnimation
            }
        }
    }
    
    private var defaultSpinner: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: SuperDesign.Tokens.colors.primary))
            .scaleEffect(1.2)
    }
    
    private var pulseAnimation: some View {
        Circle()
            .fill(SuperDesign.Tokens.colors.primary)
            .frame(width: 40, height: 40)
            .scaleEffect(pulseScale)
            .opacity(pulseOpacity)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: pulseScale
            )
    }
    
    private var dotsAnimation: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(SuperDesign.Tokens.colors.primary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(dotScale(for: index))
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: dotScale(for: index)
                    )
            }
        }
    }
    
    private var skeletonAnimation: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            // Skeleton for calendar
            RoundedRectangle(cornerRadius: SuperDesign.Tokens.effects.cornerRadius)
                .fill(SuperDesign.Tokens.colors.surfaceSecondary)
                .frame(height: 200)
                .shimmer()
            
            // Skeleton for events
            VStack(spacing: SuperDesign.Tokens.space.sm) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(SuperDesign.Tokens.colors.surfaceSecondary)
                            .frame(width: 60, height: 16)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(SuperDesign.Tokens.colors.surfaceSecondary)
                            .frame(height: 16)
                        
                        Spacer()
                    }
                    .shimmer()
                }
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: SuperDesign.Tokens.space.sm) {
            ProgressView()
                .progressViewStyle(LinearProgressViewStyle(tint: SuperDesign.Tokens.colors.primary))
                .frame(height: 4)
            
            Text("\(Int(progress * 100))%")
                .font(SuperDesign.Tokens.typography.labelSmall)
                .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
        }
    }
    
    // MARK: - Animation States
    @State private var pulseScale: CGFloat = 0.8
    @State private var pulseOpacity: Double = 0.6
    
    private func dotScale(for index: Int) -> CGFloat {
        // This will be animated by the animation modifier
        return 1.0
    }
}

// MARK: - Loading Style Enum
enum LoadingStyle {
    case `default`
    case pulse
    case dots
    case skeleton
}

// MARK: - Shimmer Effect Extension
extension View {
    func shimmer() -> some View {
        ShimmerView { self }
    }
}

// MARK: - Shimmer View
struct ShimmerView<Content: View>: View {
    let content: Content
    @State private var shimmerOffset: CGFloat = -200
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                SuperDesign.Tokens.colors.textTertiary.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: shimmerOffset)
                    .animation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: shimmerOffset
                    )
            )
            .clipped()
            .onAppear {
                shimmerOffset = 200
            }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        LoadingStateView(style: .default)
        LoadingStateView(style: .pulse)
        LoadingStateView(style: .dots)
        LoadingStateView(style: .skeleton)
    }
}
