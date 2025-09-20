//
//  UnifiedJournalNavigationView.swift
//  JustDad - Unified Journal Navigation Container
//
//  Navigation container that handles all unified journal routes and navigation.
//

import SwiftUI
import SwiftData

struct UnifiedJournalNavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var journalingService = UnifiedJournalingService()
    
    var body: some View {
        NavigationStack(path: $router.paths) {
            UnifiedJournalingView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .unifiedJournalNew:
            UnifiedJournalNewEntryView()
        case .unifiedJournalDetail(let entryId):
            if let entry = journalingService.entries.first(where: { $0.id.uuidString == entryId }) {
                UnifiedJournalEntryDetailView(entry: entry)
            } else {
                Text("Entry not found")
                    .navigationTitle("Error")
            }
        case .unifiedJournalFilter:
            UnifiedJournalFilterView(selectedFilter: .constant(.all))
        case .emotionArchive:
            EmotionArchiveView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    UnifiedJournalNavigationView()
        .environmentObject(NavigationRouter.shared)
}
