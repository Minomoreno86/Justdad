//
//  CustomCategory.swift
//  JustDad - Custom Category Management
//
//  Professional model for user-defined expense categories with full customization
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class CustomCategory {
    var id: UUID
    var name: String
    var displayName: String
    var icon: String
    var color: String
    var isDefault: Bool
    var isActive: Bool
    var sortOrder: Int
    var createdAt: Date
    var updatedAt: Date
    var usageCount: Int
    
    // Relationship to financial entries
    var financialEntries: [FinancialEntry] = []
    
    init(name: String, displayName: String, icon: String, color: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.displayName = displayName
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
        self.isActive = true
        self.sortOrder = 0
        self.createdAt = Date()
        self.updatedAt = Date()
        self.usageCount = 0
    }
    
    // MARK: - Computed Properties
    var swiftUIColor: Color {
        switch color {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "brown": return .brown
        case "gray": return .gray
        case "black": return .black
        case "white": return .white
        case "cyan": return .cyan
        case "mint": return .mint
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .blue
        }
    }
    
    var systemIcon: String {
        return icon
    }
    
    // MARK: - Methods
    func updateUsageCount() {
        usageCount += 1
        updatedAt = Date()
    }
    
    func resetUsageCount() {
        usageCount = 0
        updatedAt = Date()
    }
    
    func updateDetails(name: String, displayName: String, icon: String, color: String) {
        self.name = name
        self.displayName = displayName
        self.icon = icon
        self.color = color
        self.updatedAt = Date()
    }
    
    func toggleActive() {
        isActive.toggle()
        updatedAt = Date()
    }
    
    func updateSortOrder(_ newOrder: Int) {
        sortOrder = newOrder
        updatedAt = Date()
    }
}

// MARK: - Category Management Service
@MainActor
class CustomCategoryService: ObservableObject {
    static let shared = CustomCategoryService()
    
    @Published var categories: [CustomCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init() {
        self.modelContext = ModelContainerManager.shared.getContext() ?? ModelContext(try! ModelContainer(for: CustomCategory.self))
        loadCategories()
    }
    
    // MARK: - CRUD Operations
    func createCategory(name: String, displayName: String, icon: String, color: String) async throws {
        let category = CustomCategory(
            name: name,
            displayName: displayName,
            icon: icon,
            color: color
        )
        
        modelContext.insert(category)
        try modelContext.save()
        
        await MainActor.run {
            categories.append(category)
            sortCategories()
        }
    }
    
    func updateCategory(_ category: CustomCategory, name: String, displayName: String, icon: String, color: String) async throws {
        category.updateDetails(name: name, displayName: displayName, icon: icon, color: color)
        try modelContext.save()
        
        await MainActor.run {
            sortCategories()
        }
    }
    
    func deleteCategory(_ category: CustomCategory) async throws {
        // Don't allow deletion of default categories
        guard !category.isDefault else {
            throw CategoryError.cannotDeleteDefault
        }
        
        // Check if category is in use
        if category.usageCount > 0 {
            throw CategoryError.categoryInUse
        }
        
        modelContext.delete(category)
        try modelContext.save()
        
        await MainActor.run {
            categories.removeAll { $0.id == category.id }
        }
    }
    
    func toggleCategoryActive(_ category: CustomCategory) async throws {
        category.toggleActive()
        try modelContext.save()
        
        await MainActor.run {
            sortCategories()
        }
    }
    
    func reorderCategories(_ newOrder: [CustomCategory]) async throws {
        for (index, category) in newOrder.enumerated() {
            category.updateSortOrder(index)
        }
        try modelContext.save()
        
        await MainActor.run {
            sortCategories()
        }
    }
    
    // MARK: - Data Loading
    private func loadCategories() {
        isLoading = true
        
        do {
            let descriptor = FetchDescriptor<CustomCategory>(
                sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
            )
            categories = try modelContext.fetch(descriptor)
            
            // Create default categories if none exist
            if categories.isEmpty {
                createDefaultCategories()
            }
        } catch {
            errorMessage = "Error loading categories: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func createDefaultCategories() {
        let defaultCategories = [
            ("education", "Educación", "book.fill", "blue"),
            ("health", "Salud", "cross.fill", "red"),
            ("food", "Alimentación", "fork.knife", "orange"),
            ("clothing", "Vestimenta", "tshirt.fill", "purple"),
            ("transportation", "Transporte", "car.fill", "green"),
            ("entertainment", "Entretenimiento", "gamecontroller.fill", "pink"),
            ("gifts", "Regalos", "gift.fill", "yellow"),
            ("childSupport", "Manutención", "house.fill", "brown"),
            ("other", "Otros", "ellipsis.circle.fill", "gray")
        ]
        
        for (name, displayName, icon, color) in defaultCategories {
            let category = CustomCategory(
                name: name,
                displayName: displayName,
                icon: icon,
                color: color,
                isDefault: true
            )
            modelContext.insert(category)
        }
        
        do {
            try modelContext.save()
            loadCategories()
        } catch {
            errorMessage = "Error creating default categories: \(error.localizedDescription)"
        }
    }
    
    private func sortCategories() {
        categories.sort { first, second in
            if first.sortOrder != second.sortOrder {
                return first.sortOrder < second.sortOrder
            }
            return first.createdAt < second.createdAt
        }
    }
    
    // MARK: - Helper Methods
    func getActiveCategories() -> [CustomCategory] {
        return categories.filter { $0.isActive }
    }
    
    func getCategory(by name: String) -> CustomCategory? {
        return categories.first { $0.name == name }
    }
    
    func getMostUsedCategories(limit: Int = 5) -> [CustomCategory] {
        return categories
            .filter { $0.isActive && $0.usageCount > 0 }
            .sorted { $0.usageCount > $1.usageCount }
            .prefix(limit)
            .map { $0 }
    }
    
    func searchCategories(query: String) -> [CustomCategory] {
        guard !query.isEmpty else { return getActiveCategories() }
        
        return getActiveCategories().filter { category in
            category.displayName.localizedCaseInsensitiveContains(query) ||
            category.name.localizedCaseInsensitiveContains(query)
        }
    }
}

// MARK: - Category Errors
enum CategoryError: LocalizedError {
    case cannotDeleteDefault
    case categoryInUse
    case invalidName
    case duplicateName
    
    var errorDescription: String? {
        switch self {
        case .cannotDeleteDefault:
            return "No se pueden eliminar las categorías predeterminadas"
        case .categoryInUse:
            return "No se puede eliminar una categoría que está en uso"
        case .invalidName:
            return "El nombre de la categoría no es válido"
        case .duplicateName:
            return "Ya existe una categoría con ese nombre"
        }
    }
}

// MARK: - Available Icons
extension CustomCategory {
    static let availableIcons = [
        "book.fill", "graduationcap.fill", "studentdesk",
        "cross.fill", "stethoscope", "pills.fill", "heart.fill",
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill",
        "tshirt.fill", "shoe.2.fill", "bag.fill", "watch.fill",
        "car.fill", "bus.fill", "bicycle", "airplane",
        "gamecontroller.fill", "tv.fill", "music.note", "camera.fill",
        "gift.fill", "balloon.fill", "party.popper.fill",
        "house.fill", "building.2.fill", "wrench.and.screwdriver.fill",
        "dollarsign.circle.fill", "creditcard.fill", "banknote.fill",
        "ellipsis.circle.fill", "questionmark.circle.fill"
    ]
    
    static let availableColors = [
        "red", "orange", "yellow", "green", "blue", "purple",
        "pink", "brown", "gray", "black", "white", "cyan",
        "mint", "indigo", "teal"
    ]
}
