//
//  AgendaHeaderView.swift
//  JustDad - Agenda Header Component
//
//  Professional header component for AgendaView with view mode selector,
//  search functionality, and bulk actions toolbar
//

import SwiftUI

struct AgendaHeaderView: View {
    // MARK: - Properties
    let viewMode: CalendarViewMode
    let isEditMode: Bool
    let selectedVisitsCount: Int
    let headerSubtitle: String
    let searchText: Binding<String>
    let selectedFilter: VisitFilter
    let showingViewModeSheet: Binding<Bool>
    let showingFilterSheet: Binding<Bool>
    let onEditModeToggle: () -> Void
    let onViewModeChange: (CalendarViewMode) -> Void
    let onFilterChange: (VisitFilter) -> Void
    let onSyncTap: (() -> Void)?
    let onNotificationSettingsTap: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            // Top navigation bar with professional gradient
            topNavigationBar
            
            // Bulk Actions Toolbar (only in edit mode)
            if isEditMode && selectedVisitsCount > 0 {
                bulkActionsToolbar
            }
            
            // Month navigation (for month view) with enhanced styling
            if viewMode == .month {
                monthNavigationView
            }
            
            // Search bar (only in list mode)
            if viewMode == .list {
                searchBarView
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(SuperDesign.Tokens.colors.surfaceElevated)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xxs) {
                HStack {
                    Text("📅 Agenda")
                        .font(SuperDesign.Tokens.typography.headlineLarge)
                        .fontWeight(.bold)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                    
                    if isEditMode {
                        Text("(\(selectedVisitsCount) seleccionadas)")
                            .font(SuperDesign.Tokens.typography.bodyMedium)
                            .foregroundColor(SuperDesign.Tokens.colors.primary)
                            .padding(.horizontal, SuperDesign.Tokens.space.sm)
                            .padding(.vertical, SuperDesign.Tokens.space.xxs)
                            .background(SuperDesign.Tokens.colors.primaryLight)
                            .cornerRadius(12)
                    }
                }
                
                Text(headerSubtitle)
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
            
            Spacer()
            
            // Edit mode toggle with enhanced styling
            if viewMode == .list {
                SuperButton(
                    title: isEditMode ? "Cancelar" : "Editar",
                    style: .secondary,
                    size: .small
                ) {
                    withAnimation(SuperDesign.Tokens.animation.easeInOut) {
                        onEditModeToggle()
                    }
                }
            }
            
            // View mode selector with enhanced styling
            SuperButton(
                title: viewModeText,
                icon: viewModeIcon,
                style: .primary,
                size: .small
            ) {
                showingViewModeSheet.wrappedValue = true
            }
            
            // Sync button
            if let onSyncTap = onSyncTap {
                Button(action: onSyncTap) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                        .frame(width: 32, height: 32)
                        .background(SuperDesign.Tokens.colors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Notification settings button
            if let onNotificationSettingsTap = onNotificationSettingsTap {
                Button(action: onNotificationSettingsTap) {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                        .frame(width: 32, height: 32)
                        .background(SuperDesign.Tokens.colors.primary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.top, SuperDesign.Tokens.space.lg)
    }
    
    // MARK: - Month Navigation View
    private var monthNavigationView: some View {
        HStack {
            SuperButton(
                title: "",
                icon: "chevron.left",
                style: .ghost,
                size: .medium
            ) {
                withAnimation(SuperDesign.Tokens.animation.spring) {
                    // This will be handled by the parent view
                }
            }
            
            Spacer()
            
            VStack(spacing: SuperDesign.Tokens.space.xxs) {
                Text(monthYearText)
                    .font(SuperDesign.Tokens.typography.titleLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(SuperDesign.Tokens.colors.primaryGradient)
                
                // Professional indicator line
                Rectangle()
                    .fill(SuperDesign.Tokens.colors.primary)
                    .frame(height: 2)
                    .frame(maxWidth: 60)
                    .cornerRadius(1)
            }
            
            Spacer()
            
            SuperButton(
                title: "",
                icon: "chevron.right",
                style: .ghost,
                size: .medium
            ) {
                withAnimation(SuperDesign.Tokens.animation.spring) {
                    // This will be handled by the parent view
                }
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.bottom, SuperDesign.Tokens.space.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(SuperDesign.Tokens.colors.surface)
                .shadow(color: SuperDesign.Tokens.colors.primary.opacity(0.08), radius: 4, x: 0, y: 1)
        )
        .padding(.horizontal, SuperDesign.Tokens.space.md)
    }
    
    // MARK: - Search Bar View
    private var searchBarView: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                
                TextField("Buscar visitas...", text: searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.wrappedValue.isEmpty {
                    Button(action: { searchText.wrappedValue = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(SuperDesign.Tokens.colors.textTertiary)
                    }
                }
            }
            .padding(.horizontal, SuperDesign.Tokens.space.md)
            .padding(.vertical, SuperDesign.Tokens.space.sm)
            .background(SuperDesign.Tokens.colors.surfaceSecondary)
            .cornerRadius(SuperDesign.Tokens.effects.cornerRadius)
            
            // Filter button
            SuperButton(
                title: "",
                icon: "line.3.horizontal.decrease.circle",
                style: .secondary,
                size: .small
            ) {
                showingFilterSheet.wrappedValue = true
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.bottom, SuperDesign.Tokens.space.md)
    }
    
    // MARK: - Bulk Actions Toolbar
    private var bulkActionsToolbar: some View {
        HStack {
            Button("Seleccionar todo") {
                // This will be handled by the parent view
            }
            .foregroundColor(SuperDesign.Tokens.colors.primary)
            
            Spacer()
            
            Button(action: {
                // This will be handled by the parent view
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Eliminar")
                }
                .foregroundColor(SuperDesign.Tokens.colors.error)
            }
            .disabled(selectedVisitsCount == 0)
        }
        .padding(.horizontal, SuperDesign.Tokens.space.lg)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .background(SuperDesign.Tokens.colors.surfaceSecondary)
    }
    
    // MARK: - Computed Properties
    private var viewModeIcon: String {
        switch viewMode {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.leading"
        case .list: return "list.bullet"
        }
    }
    
    private var viewModeText: String {
        switch viewMode {
        case .month: return "Mes"
        case .week: return "Semana"
        case .list: return "Lista"
        }
    }
    
    private var monthYearText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: Date()).capitalized
    }
}

