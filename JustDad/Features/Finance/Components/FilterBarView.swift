//
//  FilterBarView.swift
//  JustDad - Filter Bar View
//
//  Compact filter bar for displaying active filters and quick access.
//

import SwiftUI

struct FilterBarView: View {
    @ObservedObject var filterService: AdvancedFilterService
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            // Filter Icon and Count
            HStack(spacing: 6) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.blue)
                
                if filterService.currentFilter.isEmpty {
                    Text("Sin filtros")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(activeFilterCount) filtro\(activeFilterCount == 1 ? "" : "s")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Active Filter Chips
            if !filterService.currentFilter.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(activeFilterChips, id: \.id) { chip in
                            FilterBarChip(
                                title: chip.title,
                                isSelected: true,
                                action: chip.action
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Clear Button
            if !filterService.currentFilter.isEmpty {
                Button(action: {
                    filterService.clearAllFilters()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.adaptiveSecondarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Computed Properties
    private var activeFilterCount: Int {
        var count = 0
        if !filterService.currentFilter.searchText.isEmpty { count += 1 }
        if filterService.currentFilter.dateRange != .all { count += 1 }
        if filterService.currentFilter.amountRange != .all { count += 1 }
        if !filterService.currentFilter.categories.isEmpty { count += 1 }
        if !filterService.currentFilter.expenseTypes.isEmpty { count += 1 }
        return count
    }
    
    private var activeFilterChips: [FilterChipData] {
        var chips: [FilterChipData] = []
        
        // Search filter
        if !filterService.currentFilter.searchText.isEmpty {
            chips.append(FilterChipData(
                id: "search",
                title: "Búsqueda",
                action: {
                    filterService.currentFilter.searchText = ""
                }
            ))
        }
        
        // Date range filter
        if filterService.currentFilter.dateRange != .all {
            chips.append(FilterChipData(
                id: "date",
                title: filterService.currentFilter.dateRange.displayName,
                action: {
                    filterService.currentFilter.dateRange = .all
                }
            ))
        }
        
        // Amount range filter
        if filterService.currentFilter.amountRange != .all {
            chips.append(FilterChipData(
                id: "amount",
                title: filterService.currentFilter.amountRange.displayName,
                action: {
                    filterService.currentFilter.amountRange = .all
                }
            ))
        }
        
        // Category filters
        if !filterService.currentFilter.categories.isEmpty {
            chips.append(FilterChipData(
                id: "categories",
                title: "\(filterService.currentFilter.categories.count) categoría\(filterService.currentFilter.categories.count == 1 ? "" : "s")",
                action: {
                    filterService.currentFilter.categories.removeAll()
                }
            ))
        }
        
        // Expense type filters
        if !filterService.currentFilter.expenseTypes.isEmpty {
            chips.append(FilterChipData(
                id: "types",
                title: "\(filterService.currentFilter.expenseTypes.count) tipo\(filterService.currentFilter.expenseTypes.count == 1 ? "" : "s")",
                action: {
                    filterService.currentFilter.expenseTypes.removeAll()
                }
            ))
        }
        
        return chips
    }
}

// MARK: - Supporting Types
struct FilterChipData {
    let id: String
    let title: String
    let action: () -> Void
}

// MARK: - Filter Chip (Reused from AdvancedFilterView)
struct FilterBarChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        FilterBarView(
            filterService: AdvancedFilterService(),
            onTap: {}
        )
        
        Spacer()
    }
    .padding()
}
