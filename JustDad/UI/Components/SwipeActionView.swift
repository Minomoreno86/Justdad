//
//  SwipeActionView.swift
//  JustDad - Swipe Action Component
//
//  Professional swipe action component with customizable actions and animations
//

import SwiftUI

// MARK: - Swipe Action Configuration
struct SwipeActionConfig {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(title: String, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
}

// MARK: - Swipe Action View
struct SwipeActionView<Content: View>: View {
    // MARK: - Properties
    let content: Content
    let leftActions: [SwipeActionConfig]
    let rightActions: [SwipeActionConfig]
    let onTap: (() -> Void)?
    
    @State private var dragOffset: CGFloat = 0
    @State private var isLeftActionVisible = false
    @State private var isRightActionVisible = false
    @State private var isAnimating = false
    
    // MARK: - Constants
    private let actionWidth: CGFloat = 80
    private let maxDragDistance: CGFloat = 160
    private let snapThreshold: CGFloat = 40
    
    // MARK: - Initialization
    init(
        @ViewBuilder content: () -> Content,
        leftActions: [SwipeActionConfig] = [],
        rightActions: [SwipeActionConfig] = [],
        onTap: (() -> Void)? = nil
    ) {
        self.content = content()
        self.leftActions = leftActions
        self.rightActions = rightActions
        self.onTap = onTap
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Actions
            HStack(spacing: 0) {
                // Left Actions
                if !leftActions.isEmpty {
                    leftActionsView
                }
                
                Spacer()
                
                // Right Actions
                if !rightActions.isEmpty {
                    rightActionsView
                }
            }
            
            // Main Content
            content
                .background(SuperDesign.Tokens.colors.surface)
                .offset(x: dragOffset)
                .gesture(dragGesture)
                .onTapGesture {
                    onTap?()
                }
        }
        .clipped()
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: dragOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isLeftActionVisible)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isRightActionVisible)
    }
    
    // MARK: - Left Actions View
    private var leftActionsView: some View {
        HStack(spacing: 0) {
            ForEach(Array(leftActions.enumerated()), id: \.offset) { index, action in
                Button(action: {
                    performAction(action)
                }) {
                    VStack(spacing: SuperDesign.Tokens.space.xxs) {
                        Image(systemName: action.icon)
                            .font(.system(size: 16, weight: .medium))
                        Text(action.title)
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .frame(width: actionWidth, height: 60)
                    .background(action.color)
                }
                .opacity(isLeftActionVisible ? 1 : 0)
                .scaleEffect(isLeftActionVisible ? 1 : 0.8)
            }
        }
    }
    
    // MARK: - Right Actions View
    private var rightActionsView: some View {
        HStack(spacing: 0) {
            ForEach(Array(rightActions.enumerated()), id: \.offset) { index, action in
                Button(action: {
                    performAction(action)
                }) {
                    VStack(spacing: SuperDesign.Tokens.space.xxs) {
                        Image(systemName: action.icon)
                            .font(.system(size: 16, weight: .medium))
                        Text(action.title)
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white)
                    .frame(width: actionWidth, height: 60)
                    .background(action.color)
                }
                .opacity(isRightActionVisible ? 1 : 0)
                .scaleEffect(isRightActionVisible ? 1 : 0.8)
            }
        }
    }
    
    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard !isAnimating else { return }
                
                let translation = value.translation.width
                let maxLeft = leftActions.isEmpty ? 0 : CGFloat(leftActions.count) * actionWidth
                let maxRight = rightActions.isEmpty ? 0 : CGFloat(rightActions.count) * actionWidth
                
                // Calculate drag offset with limits
                if translation > 0 {
                    // Swiping right (showing left actions)
                    dragOffset = min(translation, maxLeft)
                    isLeftActionVisible = translation > snapThreshold
                } else {
                    // Swiping left (showing right actions)
                    dragOffset = max(translation, -maxRight)
                    isRightActionVisible = abs(translation) > snapThreshold
                }
            }
            .onEnded { value in
                guard !isAnimating else { return }
                
                let translation = value.translation.width
                let velocity = value.velocity.width
                
                isAnimating = true
                
                if translation > snapThreshold || velocity > 500 {
                    // Snap to left actions
                    let maxLeft = leftActions.isEmpty ? 0 : CGFloat(leftActions.count) * actionWidth
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = maxLeft
                        isLeftActionVisible = true
                        isRightActionVisible = false
                    }
                } else if translation < -snapThreshold || velocity < -500 {
                    // Snap to right actions
                    let maxRight = rightActions.isEmpty ? 0 : CGFloat(rightActions.count) * actionWidth
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = -maxRight
                        isRightActionVisible = true
                        isLeftActionVisible = false
                    }
                } else {
                    // Snap back to center
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                        isLeftActionVisible = false
                        isRightActionVisible = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAnimating = false
                }
            }
    }
    
    // MARK: - Helper Methods
    private func performAction(_ action: SwipeActionConfig) {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Perform action
        action.action()
        
        // Snap back to center
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
            isLeftActionVisible = false
            isRightActionVisible = false
        }
    }
    
    // MARK: - Reset Method
    func reset() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = 0
            isLeftActionVisible = false
            isRightActionVisible = false
        }
    }
}

// MARK: - Swipe Action Presets
extension SwipeActionConfig {
    static func edit(action: @escaping () -> Void) -> SwipeActionConfig {
        SwipeActionConfig(
            title: "Editar",
            icon: "pencil",
            color: SuperDesign.Tokens.colors.primary,
            action: action
        )
    }
    
    static func delete(action: @escaping () -> Void) -> SwipeActionConfig {
        SwipeActionConfig(
            title: "Eliminar",
            icon: "trash",
            color: SuperDesign.Tokens.colors.error,
            action: action
        )
    }
    
    static func duplicate(action: @escaping () -> Void) -> SwipeActionConfig {
        SwipeActionConfig(
            title: "Duplicar",
            icon: "doc.on.doc",
            color: SuperDesign.Tokens.colors.warning,
            action: action
        )
    }
    
    static func share(action: @escaping () -> Void) -> SwipeActionConfig {
        SwipeActionConfig(
            title: "Compartir",
            icon: "square.and.arrow.up",
            color: SuperDesign.Tokens.colors.success,
            action: action
        )
    }
    
    static func favorite(action: @escaping () -> Void) -> SwipeActionConfig {
        SwipeActionConfig(
            title: "Favorito",
            icon: "heart",
            color: SuperDesign.Tokens.colors.warning,
            action: action
        )
    }
    
    static func archive(action: @escaping () -> Void) -> SwipeActionConfig {
        SwipeActionConfig(
            title: "Archivar",
            icon: "archivebox",
            color: SuperDesign.Tokens.colors.textSecondary,
            action: action
        )
    }
}

// MARK: - Swipe Action Manager
class SwipeActionManager: ObservableObject {
    @Published var activeSwipeView: AnyHashable? = nil
    
    func setActiveSwipeView(_ id: AnyHashable) {
        activeSwipeView = id
    }
    
    func clearActiveSwipeView() {
        activeSwipeView = nil
    }
}

// MARK: - Swipe Action Modifier
struct SwipeActionModifier: ViewModifier {
    let id: AnyHashable
    let leftActions: [SwipeActionConfig]
    let rightActions: [SwipeActionConfig]
    let onTap: (() -> Void)?
    
    @StateObject private var swipeManager = SwipeActionManager()
    
    func body(content: Content) -> some View {
        SwipeActionView(
            content: { content },
            leftActions: leftActions,
            rightActions: rightActions,
            onTap: onTap
        )
        .environmentObject(swipeManager)
    }
}

// MARK: - View Extension
extension View {
    func swipeActions(
        id: AnyHashable = UUID(),
        leftActions: [SwipeActionConfig] = [],
        rightActions: [SwipeActionConfig] = [],
        onTap: (() -> Void)? = nil
    ) -> some View {
        self.modifier(SwipeActionModifier(
            id: id,
            leftActions: leftActions,
            rightActions: rightActions,
            onTap: onTap
        ))
    }
}
