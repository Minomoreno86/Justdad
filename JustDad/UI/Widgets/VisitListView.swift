//
//  VisitListView.swift
//  JustDad - Visit List Component
//
//  Displays visits in list format with filtering and search
//

import SwiftUI

// MARK: - Visit Type Filter
enum VisitTypeFilter: CaseIterable, Hashable {
    case all
    case upcoming
    case past
    case type(AgendaVisitType)
    
    static var allCases: [VisitTypeFilter] {
        var cases: [VisitTypeFilter] = [.all, .upcoming, .past]
        cases.append(contentsOf: AgendaVisitType.allCases.map { .type($0) })
        return cases
    }
    
    var displayName: String {
        switch self {
        case .all:
            return NSLocalizedString("filter.all", comment: "All")
        case .upcoming:
            return NSLocalizedString("filter.upcoming", comment: "Upcoming")
        case .past:
            return NSLocalizedString("filter.past", comment: "Past")
        case .type(let visitType):
            return visitType.displayName
        }
    }
    
    var systemIcon: String {
        switch self {
        case .all:
            return "list.bullet"
        case .upcoming:
            return "clock"
        case .past:
            return "clock.arrow.circlepath"
        case .type(let visitType):
            return visitType.systemIcon
        }
    }
}

struct VisitListView: View {
    let visits: [AgendaVisit]
    let onVisitTap: (AgendaVisit) -> Void
    let onEditVisit: (AgendaVisit) -> Void
    let onDeleteVisit: (AgendaVisit) -> Void
    
    @State private var searchText = ""
    @State private var selectedFilter: VisitTypeFilter = .all
    
    private var filteredVisits: [AgendaVisit] {
        var filtered = visits
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { visit in
                visit.title.localizedCaseInsensitiveContains(searchText) ||
                visit.notes?.localizedCaseInsensitiveContains(searchText) == true ||
                visit.location?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply type filter
        switch selectedFilter {
        case .all:
            break
        case .type(let visitType):
            filtered = filtered.filter { $0.visitType == visitType }
        case .upcoming:
            filtered = filtered.filter { $0.startDate > Date() }
        case .past:
            filtered = filtered.filter { $0.startDate < Date() }
        }
        
        return filtered.sorted { $0.startDate < $1.startDate }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Section
            searchAndFilterSection
            
            // Visit List
            if filteredVisits.isEmpty {
                emptyStateView
            } else {
                visitListContent
            }
        }
    }
    
    // MARK: - Search and Filter Section
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(
                    NSLocalizedString("visits.search.placeholder", comment: "Search visits..."),
                    text: $searchText
                )
                .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(VisitTypeFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            filter: filter,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }
    
    // MARK: - Visit List Content
    
    private var visitListContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredVisits) { visit in
                    VisitRowViewLocal(
                        visit: visit,
                        isEditMode: false,
                        isSelected: false,
                        onTap: { onVisitTap(visit) },
                        onLongPress: { /* No implementation needed for basic list */ },
                        onEdit: { onVisitTap(visit) },
                        onDelete: { /* No implementation needed for basic list */ },
                        onDuplicate: { /* No implementation needed for basic list */ },
                        onShare: { /* No implementation needed for basic list */ },
                        onToggleFavorite: { /* No implementation needed for basic list */ },
                        onArchive: { /* No implementation needed for basic list */ }
                    )
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            onEditVisit(visit)
                        }
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            onDeleteVisit(visit)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("visits.empty.title", comment: "No visits found"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(getEmptyStateMessage())
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getEmptyStateMessage() -> String {
        if !searchText.isEmpty {
            return String(format: NSLocalizedString("visits.empty.search", comment: "No visits match '%@'"), searchText)
        } else if selectedFilter != .all {
            return NSLocalizedString("visits.empty.filter", comment: "No visits match the selected filter")
        } else {
            return NSLocalizedString("visits.empty.default", comment: "Start by creating your first visit")
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let filter: VisitTypeFilter
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: filter.systemIcon)
                    .font(.caption)
                
                Text(filter.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color.blue : Color(UIColor.systemGray5)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - Preview

#Preview {
    VisitListView(
        visits: [
            AgendaVisit(
                title: "Weekend visit",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date(),
                visitType: .weekend
            ),
            AgendaVisit(
                title: "Dinner",
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()) ?? Date(),
                visitType: .dinner
            )
        ],
        onVisitTap: { _ in },
        onEditVisit: { _ in },
        onDeleteVisit: { _ in }
    )
    .padding()
}

// MARK: - VisitRowViewLocal
struct VisitRowViewLocal: View {
    let visit: AgendaVisit
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onShare: () -> Void
    let onToggleFavorite: () -> Void
    let onArchive: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Visit Type Icon
                Circle()
                    .fill(colorForVisitType(visit.visitType))
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(visit.startDate, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let location = visit.location {
                            Image(systemName: "location")
                                .foregroundColor(.secondary)
                            Text(location)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.clear)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture {
            onLongPress()
        }
    }
    
    private func colorForVisitType(_ visitType: AgendaVisitType) -> Color {
        switch visitType {
        case .weekend: return .blue
        case .dinner: return .green
        case .activity: return .purple
        case .school: return .yellow
        case .medical: return .orange
        case .emergency: return .red
        case .general: return .gray
        }
    }
}
