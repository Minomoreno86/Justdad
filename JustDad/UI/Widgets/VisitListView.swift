//
//  VisitListView.swift
//  JustDad - Visit List Component
//
//  Displays visits in list format with filtering and search
//

import SwiftUI

struct VisitListView: View {
    let visits: [Visit]
    let onVisitTap: (Visit) -> Void
    let onEditVisit: (Visit) -> Void
    let onDeleteVisit: (Visit) -> Void
    
    @State private var searchText = ""
    @State private var selectedFilter: VisitTypeFilter = .all
    
    private var filteredVisits: [Visit] {
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
            .background(Color(.systemGray6))
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
                    VisitRowView(
                        visit: visit,
                        onTap: { onVisitTap(visit) },
                        onEdit: { onEditVisit(visit) },
                        onDelete: { onDeleteVisit(visit) }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(emptyStateTitle)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(emptyStateSubtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty {
            return NSLocalizedString("visits.empty.search.title", comment: "No visits found")
        } else if selectedFilter != .all {
            return NSLocalizedString("visits.empty.filter.title", comment: "No visits match filter")
        } else {
            return NSLocalizedString("visits.empty.title", comment: "No visits scheduled")
        }
    }
    
    private var emptyStateSubtitle: String {
        if !searchText.isEmpty {
            return NSLocalizedString("visits.empty.search.subtitle", comment: "Try a different search term")
        } else if selectedFilter != .all {
            return NSLocalizedString("visits.empty.filter.subtitle", comment: "Try changing the filter")
        } else {
            return NSLocalizedString("visits.empty.subtitle", comment: "Tap + to add your first visit")
        }
    }
}

// MARK: - Visit Type Filter

enum VisitTypeFilter: CaseIterable, Equatable {
    case all
    case upcoming
    case past
    case type(VisitType)
    
    static var allCases: [VisitTypeFilter] {
        var cases: [VisitTypeFilter] = [.all, .upcoming, .past]
        cases.append(contentsOf: VisitType.allCases.map { .type($0) })
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
            return "calendar"
        case .upcoming:
            return "clock"
        case .past:
            return "clock.arrow.circlepath"
        case .type(let visitType):
            return visitType.systemIcon
        }
    }
}

// MARK: - Filter Pill

struct FilterPill: View {
    let filter: VisitTypeFilter
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: filter.systemIcon)
                    .font(.caption)
                
                Text(filter.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                isSelected ? Color.blue : Color(.systemGray5)
            )
            .foregroundColor(
                isSelected ? .white : .primary
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Visit Row View

struct VisitRowView: View {
    let visit: Visit
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Visit type indicator
                VStack {
                    Image(systemName: visit.visitType.systemIcon)
                        .font(.title3)
                        .foregroundColor(Color(visit.visitType.color))
                        .frame(width: 30, height: 30)
                        .background(Color(visit.visitType.color).opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                
                // Visit details
                VStack(alignment: .leading, spacing: 4) {
                    Text(visit.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(formatDate(visit.startDate))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text(formatTimeRange(visit.startDate, visit.endDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = visit.location {
                        Label(location, systemImage: "location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if visit.isRecurring {
                        Label(
                            visit.recurrenceRule?.displayName ?? NSLocalizedString("recurring", comment: "Recurring"),
                            systemImage: "repeat"
                        )
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Action menu
                Menu {
                    Button(action: onEdit) {
                        Label(NSLocalizedString("edit", comment: "Edit"), systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label(NSLocalizedString("delete", comment: "Delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .alert(
            NSLocalizedString("delete.visit.title", comment: "Delete Visit"),
            isPresented: $showingDeleteAlert
        ) {
            Button(NSLocalizedString("cancel", comment: "Cancel"), role: .cancel) { }
            Button(NSLocalizedString("delete", comment: "Delete"), role: .destructive) {
                onDelete()
            }
        } message: {
            Text(NSLocalizedString("delete.visit.message", comment: "This action cannot be undone."))
        }
    }
    
    // MARK: - Date Formatting
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formatTimeRange(_ startDate: Date, _ endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startTime = formatter.string(from: startDate)
        let endTime = formatter.string(from: endDate)
        
        return "\(startTime) - \(endTime)"
    }
}

// MARK: - Preview

#Preview {
    VisitListView(
        visits: [
            Visit(
                title: "Weekend with kids",
                startDate: Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date(),
                location: "My place",
                visitType: .weekend
            ),
            Visit(
                title: "Dinner date",
                startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                endDate: Calendar.current.date(byAdding: .hour, value: 2, to: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()) ?? Date(),
                location: "Restaurant",
                visitType: .dinner
            )
        ],
        onVisitTap: { _ in },
        onEditVisit: { _ in },
        onDeleteVisit: { _ in }
    )
}
