//
//  EmptyStateView.swift
//  JustDad - Empty state component
//
//  Reusable empty state view for lists and content
//

import SwiftUI

struct EmptyStateView: View {
    var title: String
    var message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 40))
                .foregroundColor(Palette.textSecondary)
            Text(title)
                .font(Typography.title)
                .foregroundColor(Palette.textPrimary)
            Text(message)
                .font(Typography.body)
                .foregroundColor(Palette.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            if let actionTitle, let action {
                PrimaryButton(actionTitle, action: action)
                    .padding(.top, 8)
            }
        }
        .padding(24)
    }
}

#Preview {
    EmptyStateView(
        title: "No entries yet",
        message: "Start capturing your moments",
        actionTitle: "Add entry",
        action: {}
    )
}
