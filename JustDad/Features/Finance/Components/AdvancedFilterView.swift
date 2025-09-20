//
//  AdvancedFilterView.swift
//  JustDad - Advanced Filter View
//
//  Professional view for advanced financial filtering.
//

import SwiftUI
import SwiftData

struct AdvancedFilterView: View {
    @ObservedObject var filterService: AdvancedFilterService
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveFilterSheet = false
    @State private var newFilterName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.02),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Filtros Avanzados")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.adaptiveLabel)
                            
                            Text("Personaliza tu búsqueda de transacciones")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Filter Sections
                        VStack(spacing: 20) {
                            // Search Section
                            searchSection
                            
                            // Date Range Section
                            dateRangeSection
                            
                            // Amount Range Section
                            amountRangeSection
                            
                            // Category Section
                            categorySection
                            
                            // Expense Type Section
                            expenseTypeSection
                            
                            // Saved Filters Section
                            if !filterService.savedFilters.isEmpty {
                                savedFiltersSection
                            }
                        }
                        
                        // Action Buttons
                        actionButtonsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingSaveFilterSheet) {
            saveFilterSheet
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Búsqueda", icon: "magnifyingglass")
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                TextField("Buscar en títulos y notas...", text: $filterService.currentFilter.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !filterService.currentFilter.searchText.isEmpty {
                    Button(action: {
                        filterService.currentFilter.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color.adaptiveTertiarySystemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - Date Range Section
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Rango de Fechas", icon: "calendar")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(DateRangeFilter.allCases) { filter in
                    AdvancedFilterChip(
                        title: filter.displayName,
                        isSelected: filterService.currentFilter.dateRange == filter,
                        action: {
                            filterService.currentFilter.dateRange = filter
                        }
                    )
                }
            }
            
            if filterService.currentFilter.dateRange == .custom {
                VStack(spacing: 12) {
                    DatePicker("Desde", selection: $filterService.customDateRange.start, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                    
                    DatePicker("Hasta", selection: $filterService.customDateRange.end, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                .padding(12)
                .background(Color.adaptiveSecondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - Amount Range Section
    private var amountRangeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Rango de Montos", icon: "dollarsign.circle")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(AmountRangeFilter.allCases) { filter in
                    AdvancedFilterChip(
                        title: filter.displayName,
                        isSelected: filterService.currentFilter.amountRange == filter,
                        action: {
                            filterService.currentFilter.amountRange = filter
                        }
                    )
                }
            }
            
            if filterService.currentFilter.amountRange == .custom {
                VStack(spacing: 12) {
                    HStack {
                        Text("Monto mínimo:")
                        Spacer()
                        TextField("0.00", value: $filterService.customAmountRange.min, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Monto máximo:")
                        Spacer()
                        TextField("0.00", value: $filterService.customAmountRange.max, format: .currency(code: "USD"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }
                }
                .padding(12)
                .background(Color.adaptiveSecondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Categorías", icon: "tag")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(filterService.availableCategories) { category in
                    CategoryFilterChip(
                        category: category,
                        isSelected: filterService.currentFilter.categories.contains(category),
                        action: {
                            if filterService.currentFilter.categories.contains(category) {
                                filterService.currentFilter.categories.remove(category)
                            } else {
                                filterService.currentFilter.categories.insert(category)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Expense Type Section
    private var expenseTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Tipo de Gasto", icon: "chart.bar")
            
            HStack(spacing: 12) {
                ForEach(ExpenseTypeFilter.allCases) { filter in
                    AdvancedFilterChip(
                        title: filter.displayName,
                        isSelected: filterService.currentFilter.expenseTypes.contains(filter),
                        action: {
                            if filterService.currentFilter.expenseTypes.contains(filter) {
                                filterService.currentFilter.expenseTypes.remove(filter)
                            } else {
                                filterService.currentFilter.expenseTypes.insert(filter)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Saved Filters Section
    private var savedFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Filtros Guardados", icon: "bookmark")
            
            LazyVStack(spacing: 8) {
                ForEach(filterService.savedFilters) { savedFilter in
                    SavedFilterRow(
                        savedFilter: savedFilter,
                        onLoad: {
                            filterService.loadSavedFilter(savedFilter)
                        },
                        onDelete: {
                            filterService.deleteSavedFilter(savedFilter)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            // Save Filter Button
            if !filterService.currentFilter.isEmpty {
                Button(action: {
                    showingSaveFilterSheet = true
                }) {
                    HStack {
                        Image(systemName: "bookmark.fill")
                        Text("Guardar Filtro")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Clear Filters Button
            Button(action: {
                filterService.clearAllFilters()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Limpiar Filtros")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // MARK: - Save Filter Sheet
    private var saveFilterSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Guardar Filtro")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre del filtro:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("Mi filtro personalizado", text: $newFilterName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button("Cancelar") {
                        showingSaveFilterSheet = false
                        newFilterName = ""
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.adaptiveSecondarySystemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button("Guardar") {
                        filterService.saveCurrentFilter(as: newFilterName)
                        showingSaveFilterSheet = false
                        newFilterName = ""
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(newFilterName.isEmpty)
                }
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        showingSaveFilterSheet = false
                        newFilterName = ""
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.adaptiveLabel)
            
            Spacer()
        }
    }
}

struct AdvancedFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryFilterChip: View {
    let category: FilterCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : Color.adaptiveLabel)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color : category.color.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SavedFilterRow: View {
    let savedFilter: SavedFilter
    let onLoad: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(savedFilter.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.adaptiveLabel)
                
                Text("Creado: \(savedFilter.createdAt, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onLoad) {
                    Image(systemName: "play.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    AdvancedFilterView(filterService: AdvancedFilterService())
}
