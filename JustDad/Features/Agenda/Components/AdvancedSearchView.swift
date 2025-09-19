//
//  AdvancedSearchView.swift
//  JustDad - Advanced Search Interface
//
//  Professional advanced search interface with multiple filter options
//

import SwiftUI

struct AdvancedSearchView: View {
    // MARK: - Properties
    @Binding var searchFilter: AdvancedSearchFilter
    @State private var showingFilters = false
    @State private var showingSortOptions = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            searchBar
            
            // Filter Chips
            if searchFilter.hasActiveFilters {
                filterChips
            }
        }
        .background(SuperDesign.Tokens.colors.surface)
        .sheet(isPresented: $showingFilters) {
            FilterOptionsView(searchFilter: $searchFilter)
        }
        .sheet(isPresented: $showingSortOptions) {
            SortOptionsView(searchFilter: $searchFilter)
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: SuperDesign.Tokens.space.sm) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .font(.system(size: 16))
            
            // Search Text Field
            TextField("Buscar visitas...", text: $searchFilter.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(SuperDesign.Tokens.typography.bodyMedium)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            // Clear Search Button
            if !searchFilter.searchText.isEmpty {
                Button(action: {
                    searchFilter.resetSearchOnly()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        .font(.system(size: 16))
                }
            }
            
            // Filter Button
            Button(action: {
                showingFilters = true
            }) {
                HStack(spacing: SuperDesign.Tokens.space.xxs) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16))
                    
                    if searchFilter.activeFilterCount > 0 {
                        Text("\(searchFilter.activeFilterCount)")
                            .font(SuperDesign.Tokens.typography.labelSmall)
                            .fontWeight(.medium)
                    }
                }
                .foregroundColor(searchFilter.hasActiveFilters ? 
                                SuperDesign.Tokens.colors.primary : 
                                SuperDesign.Tokens.colors.textSecondary)
            }
            
            // Sort Button
            Button(action: {
                showingSortOptions = true
            }) {
                HStack(spacing: SuperDesign.Tokens.space.xxs) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16))
                    
                    Text(searchFilter.sortBy.displayName)
                        .font(SuperDesign.Tokens.typography.labelSmall)
                        .fontWeight(.medium)
                }
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            }
        }
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.sm)
        .background(SuperDesign.Tokens.colors.surfaceSecondary)
        .cornerRadius(SuperDesign.Tokens.space.sm)
        .padding(.horizontal, SuperDesign.Tokens.space.md)
        .padding(.vertical, SuperDesign.Tokens.space.xs)
    }
    
    // MARK: - Filter Chips
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SuperDesign.Tokens.space.xs) {
                // Date Filter Chip
                if searchFilter.selectedDateFilter != .all {
                    FilterChip(
                        title: searchFilter.selectedDateFilter.displayName,
                        icon: searchFilter.selectedDateFilter.icon,
                        onRemove: {
                            searchFilter.selectedDateFilter = .all
                        }
                    )
                }
                
                // Visit Type Chips
                ForEach(Array(searchFilter.selectedVisitTypes), id: \.self) { visitType in
                    FilterChip(
                        title: visitType.displayName,
                        icon: visitType.systemIcon,
                        onRemove: {
                            searchFilter.selectedVisitTypes.remove(visitType)
                        }
                    )
                }
                
                // Time Range Chip
                if searchFilter.selectedTimeRange != .all {
                    FilterChip(
                        title: searchFilter.selectedTimeRange.displayName,
                        icon: searchFilter.selectedTimeRange.icon,
                        onRemove: {
                            searchFilter.selectedTimeRange = .all
                        }
                    )
                }
                
                // Location Chip
                if !searchFilter.selectedLocation.isEmpty {
                    FilterChip(
                        title: "Ubicación: \(searchFilter.selectedLocation)",
                        icon: "location",
                        onRemove: {
                            searchFilter.selectedLocation = ""
                        }
                    )
                }
                
                // Notes Chip
                if let hasNotes = searchFilter.hasNotes {
                    FilterChip(
                        title: hasNotes ? "Con notas" : "Sin notas",
                        icon: hasNotes ? "note.text" : "note",
                        onRemove: {
                            searchFilter.hasNotes = nil
                        }
                    )
                }
                
                // Recurring Chip
                if let isRecurring = searchFilter.isRecurring {
                    FilterChip(
                        title: isRecurring ? "Recurrente" : "No recurrente",
                        icon: isRecurring ? "repeat" : "repeat.circle",
                        onRemove: {
                            searchFilter.isRecurring = nil
                        }
                    )
                }
                
                // Clear All Button
                Button(action: {
                    searchFilter.resetAllFilters()
                }) {
                    HStack(spacing: SuperDesign.Tokens.space.xxs) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Limpiar todo")
                    }
                    .font(SuperDesign.Tokens.typography.labelSmall)
                    .foregroundColor(SuperDesign.Tokens.colors.error)
                }
                .padding(.horizontal, SuperDesign.Tokens.space.sm)
                .padding(.vertical, SuperDesign.Tokens.space.xs)
                .background(SuperDesign.Tokens.colors.error.opacity(0.1))
                .cornerRadius(SuperDesign.Tokens.space.sm)
            }
            .padding(.horizontal, SuperDesign.Tokens.space.md)
        }
        .padding(.bottom, SuperDesign.Tokens.space.xs)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: SuperDesign.Tokens.space.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            
            Text(title)
                .font(SuperDesign.Tokens.typography.labelSmall)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
            }
        }
        .foregroundColor(SuperDesign.Tokens.colors.primary)
        .padding(.horizontal, SuperDesign.Tokens.space.sm)
        .padding(.vertical, SuperDesign.Tokens.space.xs)
        .background(SuperDesign.Tokens.colors.primary.opacity(0.1))
        .cornerRadius(SuperDesign.Tokens.space.sm)
    }
}

// MARK: - Filter Options View
struct FilterOptionsView: View {
    @Binding var searchFilter: AdvancedSearchFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: SuperDesign.Tokens.space.lg) {
                    // Date Filter Section
                    FilterSection(title: "Filtro de Fecha", icon: "calendar") {
                        VStack(spacing: SuperDesign.Tokens.space.sm) {
                            ForEach(VisitFilter.allCases, id: \.self) { filter in
                                FilterOptionRow(
                                    title: filter.displayName,
                                    icon: filter.icon,
                                    isSelected: searchFilter.selectedDateFilter == filter,
                                    onTap: {
                                        searchFilter.selectedDateFilter = filter
                                    }
                                )
                            }
                        }
                    }
                    
                    // Visit Type Filter Section
                    FilterSection(title: "Tipo de Visita", icon: "tag") {
                        VStack(spacing: SuperDesign.Tokens.space.sm) {
                            ForEach(AgendaVisitType.allCases, id: \.self) { visitType in
                                FilterOptionRow(
                                    title: visitType.displayName,
                                    icon: visitType.systemIcon,
                                    isSelected: searchFilter.selectedVisitTypes.contains(visitType),
                                    onTap: {
                                        if searchFilter.selectedVisitTypes.contains(visitType) {
                                            searchFilter.selectedVisitTypes.remove(visitType)
                                        } else {
                                            searchFilter.selectedVisitTypes.insert(visitType)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    // Time Range Filter Section
                    FilterSection(title: "Rango Horario", icon: "clock") {
                        VStack(spacing: SuperDesign.Tokens.space.sm) {
                            ForEach(TimeRangeFilter.allCases, id: \.self) { timeRange in
                                FilterOptionRow(
                                    title: timeRange.displayName,
                                    icon: timeRange.icon,
                                    isSelected: searchFilter.selectedTimeRange == timeRange,
                                    onTap: {
                                        searchFilter.selectedTimeRange = timeRange
                                    }
                                )
                            }
                        }
                    }
                    
                    // Location Filter Section
                    FilterSection(title: "Ubicación", icon: "location") {
                        TextField("Filtrar por ubicación", text: $searchFilter.selectedLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Additional Filters Section
                    FilterSection(title: "Filtros Adicionales", icon: "slider.horizontal.3") {
                        VStack(spacing: SuperDesign.Tokens.space.sm) {
                            // Notes Filter
                            HStack {
                                Text("Solo con notas")
                                    .font(SuperDesign.Tokens.typography.bodyMedium)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { searchFilter.hasNotes == true },
                                    set: { searchFilter.hasNotes = $0 ? true : nil }
                                ))
                            }
                            
                            // Recurring Filter
                            HStack {
                                Text("Solo recurrentes")
                                    .font(SuperDesign.Tokens.typography.bodyMedium)
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { searchFilter.isRecurring == true },
                                    set: { searchFilter.isRecurring = $0 ? true : nil }
                                ))
                            }
                        }
                    }
                }
                .padding(SuperDesign.Tokens.space.lg)
            }
            .navigationTitle("Filtros Avanzados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        searchFilter.resetFiltersOnly()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Sort Options View
struct SortOptionsView: View {
    @Binding var searchFilter: AdvancedSearchFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: SuperDesign.Tokens.space.lg) {
                // Sort By Section
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
                    Text("Ordenar por")
                        .font(SuperDesign.Tokens.typography.titleSmall)
                        .fontWeight(.medium)
                    
                    ForEach(SortOption.allCases, id: \.self) { sortOption in
                        FilterOptionRow(
                            title: sortOption.displayName,
                            icon: sortOption.icon,
                            isSelected: searchFilter.sortBy == sortOption,
                            onTap: {
                                searchFilter.sortBy = sortOption
                            }
                        )
                    }
                }
                
                // Sort Order Section
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
                    Text("Orden")
                        .font(SuperDesign.Tokens.typography.titleSmall)
                        .fontWeight(.medium)
                    
                    ForEach(SortOrder.allCases, id: \.self) { sortOrder in
                        FilterOptionRow(
                            title: sortOrder.displayName,
                            icon: sortOrder.icon,
                            isSelected: searchFilter.sortOrder == sortOrder,
                            onTap: {
                                searchFilter.sortOrder = sortOrder
                            }
                        )
                    }
                }
                
                Spacer()
            }
            .padding(SuperDesign.Tokens.space.lg)
            .navigationTitle("Opciones de Ordenamiento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Filter Section
struct FilterSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                Text(title)
                    .font(SuperDesign.Tokens.typography.titleSmall)
                    .fontWeight(.medium)
            }
            
            content
        }
        .padding(SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.surfaceSecondary)
        .cornerRadius(SuperDesign.Tokens.space.sm)
    }
}

// MARK: - Filter Option Row
struct FilterOptionRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                        .fontWeight(.medium)
                }
            }
            .padding(.vertical, SuperDesign.Tokens.space.xs)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

