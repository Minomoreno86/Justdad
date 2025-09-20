//
//  AccessibleComponents.swift
//  JustDad - Accessible Components
//
//  Professional accessible UI components for inclusive design.
//

import SwiftUI

// MARK: - Accessible Button
struct AccessibleButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let accessibilityLabel: String
    let accessibilityHint: String?
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case plain
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44) // Minimum touch target size
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            action()
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return .blue
        case .secondary: return .gray.opacity(0.2)
        case .destructive: return .red
        case .plain: return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .primary
        case .destructive: return .white
        case .plain: return .blue
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary: return .gray.opacity(0.3)
        case .destructive: return .clear
        case .plain: return .blue
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary: return 0
        case .secondary: return 1
        case .destructive: return 0
        case .plain: return 1
        }
    }
}

// MARK: - Accessible Card
struct AccessibleCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let value: String?
    let content: Content
    let accessibilityLabel: String
    let accessibilityValue: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        accessibilityLabel: String? = nil,
        accessibilityValue: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityValue = accessibilityValue ?? value
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityAddTraits(.isHeader)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            content
            
            if let value = value {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue ?? "")
        .accessibilityAddTraits(.isStaticText)
    }
}

// MARK: - Accessible List
struct AccessibleList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let data: Data
    let content: (Data.Element) -> Content
    let accessibilityLabel: String
    
    init(
        data: Data,
        accessibilityLabel: String,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = content
        self.accessibilityLabel = accessibilityLabel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(accessibilityLabel) \(index + 1) de \(data.count)")
                    .accessibilityAddTraits(.isButton)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Accessible Progress Bar
struct AccessibleProgressBar: View {
    let title: String
    let progress: Double
    let total: Double
    let unit: String
    
    private var percentage: Int {
        Int((progress / total) * 100)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(percentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress, total: total)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). Progreso: \(percentage) por ciento")
        .accessibilityValue("\(Int(progress)) de \(Int(total)) \(unit)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - Accessible Toggle
struct AccessibleToggle: View {
    let title: String
    let isOn: Binding<Bool>
    let accessibilityHint: String?
    
    init(
        title: String,
        isOn: Binding<Bool>,
        accessibilityHint: String? = nil
    ) {
        self.title = title
        self.isOn = isOn
        self.accessibilityHint = accessibilityHint
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(isOn.wrappedValue ? "Activado" : "Desactivado")
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Accessible Text Field
struct AccessibleTextField: View {
    let title: String
    let text: Binding<String>
    let placeholder: String
    let accessibilityHint: String?
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        accessibilityHint: String? = nil
    ) {
        self.title = title
        self.text = text
        self.placeholder = placeholder
        self.accessibilityHint = accessibilityHint
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .accessibilityAddTraits(.isHeader)
            
            TextField(placeholder, text: text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibilityLabel(title)
                .accessibilityValue(text.wrappedValue.isEmpty ? placeholder : text.wrappedValue)
                .accessibilityHint(accessibilityHint ?? "")
        }
    }
}

// MARK: - Accessible Navigation Link
struct AccessibleNavigationLink<Destination: View, Label: View>: View {
    let destination: Destination
    let label: Label
    let accessibilityLabel: String
    let accessibilityHint: String?
    
    init(
        destination: Destination,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.label = label()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            label
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(.isButton)
    }
}