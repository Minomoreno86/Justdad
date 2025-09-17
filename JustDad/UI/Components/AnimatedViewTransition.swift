//
//  AnimatedViewTransition.swift
//  JustDad - Animated View Transition Component
//
//  Professional animated transitions between different view modes
//

import SwiftUI

struct AnimatedViewTransition<Content: View>: View {
    // MARK: - Properties
    let content: Content
    let transitionType: TransitionType
    let animationDuration: Double
    
    // MARK: - Initialization
    init(
        transitionType: TransitionType = .slide,
        animationDuration: Double = 0.3,
        @ViewBuilder content: () -> Content
    ) {
        self.transitionType = transitionType
        self.animationDuration = animationDuration
        self.content = content()
    }
    
    // MARK: - Body
    var body: some View {
        content
            .transition(transitionType.animation)
            .animation(.easeInOut(duration: animationDuration), value: UUID())
    }
}

// MARK: - Transition Types
enum TransitionType {
    case slide
    case fade
    case scale
    case slideUp
    case slideDown
    case custom(AnyTransition)
    
    var animation: AnyTransition {
        switch self {
        case .slide:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .fade:
            return .opacity
        case .scale:
            return .scale.combined(with: .opacity)
        case .slideUp:
            return .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            )
        case .slideDown:
            return .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        case .custom(let transition):
            return transition
        }
    }
}

// MARK: - View Modifier for Easy Application
struct AnimatedTransitionModifier: ViewModifier {
    let transitionType: TransitionType
    let animationDuration: Double
    
    func body(content: Content) -> some View {
        AnimatedViewTransition(
            transitionType: transitionType,
            animationDuration: animationDuration
        ) {
            content
        }
    }
}

// MARK: - View Extension
extension View {
    func animatedTransition(
        type: TransitionType = .slide,
        duration: Double = 0.3
    ) -> some View {
        self.modifier(AnimatedTransitionModifier(
            transitionType: type,
            animationDuration: duration
        ))
    }
}

// MARK: - Custom Transitions
extension TransitionType {
    static let agendaViewTransition: TransitionType = .custom(
        .asymmetric(
            insertion: .move(edge: .trailing)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.95)),
            removal: .move(edge: .leading)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 1.05))
        )
    )
    
    static let calendarTransition: TransitionType = .custom(
        .asymmetric(
            insertion: .move(edge: .bottom)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 0.9)),
            removal: .move(edge: .top)
                .combined(with: .opacity)
                .combined(with: .scale(scale: 1.1))
        )
    )
    
    static let listTransition: TransitionType = .custom(
        .asymmetric(
            insertion: .move(edge: .top)
                .combined(with: .opacity),
            removal: .move(edge: .bottom)
                .combined(with: .opacity)
        )
    )
}
