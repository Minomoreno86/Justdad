//
//  AccessibleNavigation.swift
//  JustDad - Accessible Navigation Components
//
//  Professional accessible navigation components for inclusive user experience.
//

import SwiftUI

// MARK: - Accessible Tab Bar
struct AccessibleTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    struct TabItem: Identifiable {
        let id: Int
        let title: String
        let icon: String
        let accessibilityLabel: String
        let accessibilityHint: String
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                Button(action: {
                    selectedTab = tab.id
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == tab.id ? .blue : .gray)
                        
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(selectedTab == tab.id ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab.id ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedTab == tab.id ? Color.blue.opacity(0.1) : Color.clear
                    )
                }
                .accessibilityLabel(tab.accessibilityLabel)
                .accessibilityHint(tab.accessibilityHint)
                .accessibilityAddTraits(selectedTab == tab.id ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .top
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Barra de navegación principal")
    }
}

// MARK: - Accessible Navigation Bar
struct AccessibleNavigationBar: View {
    let title: String
    let subtitle: String?
    let leadingButton: NavigationButton?
    let trailingButton: NavigationButton?
    
    struct NavigationButton {
        let title: String
        let icon: String?
        let action: () -> Void
        let accessibilityLabel: String
        let accessibilityHint: String
    }
    
    var body: some View {
        HStack {
            // Leading button
            if let leadingButton = leadingButton {
                Button(action: leadingButton.action) {
                    HStack(spacing: 4) {
                        if let icon = leadingButton.icon {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                        }
                        Text(leadingButton.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .accessibilityLabel(leadingButton.accessibilityLabel)
                .accessibilityHint(leadingButton.accessibilityHint)
                .accessibilityAddTraits(.isButton)
            } else {
                Spacer()
            }
            
            // Title
            VStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title)\(subtitle != nil ? ". \(subtitle!)" : "")")
            .accessibilityAddTraits(.isHeader)
            
            // Trailing button
            if let trailingButton = trailingButton {
                Button(action: trailingButton.action) {
                    HStack(spacing: 4) {
                        Text(trailingButton.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        if let icon = trailingButton.icon {
                            Image(systemName: icon)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                }
                .accessibilityLabel(trailingButton.accessibilityLabel)
                .accessibilityHint(trailingButton.accessibilityHint)
                .accessibilityAddTraits(.isButton)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}

// MARK: - Accessible Back Button
struct AccessibleBackButton: View {
    let action: () -> Void
    let title: String
    
    init(title: String = "Atrás", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .accessibilityLabel("Botón de regreso")
        .accessibilityHint("Toca para regresar a la pantalla anterior")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Accessible Close Button
struct AccessibleCloseButton: View {
    let action: () -> Void
    let title: String
    
    init(title: String = "Cerrar", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .accessibilityLabel("Botón de cerrar")
        .accessibilityHint("Toca para cerrar esta pantalla")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Accessible Menu Button
struct AccessibleMenuButton: View {
    let action: () -> Void
    let title: String
    
    init(title: String = "Menú", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .accessibilityLabel("Botón de menú")
        .accessibilityHint("Toca para abrir el menú de opciones")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Accessible Search Bar
struct AccessibleSearchBar: View {
    @Binding var searchText: String
    let placeholder: String
    let onSearchButtonClicked: () -> Void
    let onCancelButtonClicked: () -> Void
    
    @State private var isSearching = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(placeholder, text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSearchButtonClicked()
                    }
                    .accessibilityLabel("Campo de búsqueda")
                    .accessibilityValue(searchText.isEmpty ? placeholder : searchText)
                    .accessibilityHint("Introduce el texto que deseas buscar")
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Limpiar búsqueda")
                    .accessibilityHint("Toca para limpiar el texto de búsqueda")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isSearching {
                Button("Cancelar") {
                    searchText = ""
                    isSearching = false
                    onCancelButtonClicked()
                }
                .accessibilityLabel("Cancelar búsqueda")
                .accessibilityHint("Toca para cancelar la búsqueda")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .onTapGesture {
            isSearching = true
        }
    }
}

// MARK: - Accessible Section Header
struct AccessibleSectionHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(title: String, subtitle: String? = nil, action: (() -> Void)? = nil, actionTitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title)\(subtitle != nil ? ". \(subtitle!)" : "")")
            .accessibilityAddTraits(.isHeader)
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel(actionTitle)
                .accessibilityHint("Toca para \(actionTitle.lowercased())")
                .accessibilityAddTraits(.isButton)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Accessible Divider
struct AccessibleDivider: View {
    let title: String?
    
    init(title: String? = nil) {
        self.title = title
    }
    
    var body: some View {
        HStack {
            if let title = title {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title ?? "Separador")
        .accessibilityAddTraits(.isStaticText)
    }
}
