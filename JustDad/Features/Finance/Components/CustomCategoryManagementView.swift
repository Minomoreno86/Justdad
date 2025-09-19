//
//  CustomCategoryManagementView.swift
//  JustDad - Custom Category Management
//
//  Professional view for creating, editing, and managing custom expense categories
//

import SwiftUI
import SwiftData

struct CustomCategoryManagementView: View {
    @StateObject private var categoryService = CustomCategoryService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateCategory = false
    @State private var showingEditCategory: CustomCategory? = nil
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: CustomCategory? = nil
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Search Bar
                searchSection
                
                // Categories List
                categoriesList
            }
            .navigationTitle("Categorías Personalizadas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        showingCreateCategory = true
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingCreateCategory) {
            CreateCategoryView { name, displayName, icon, color in
                Task {
                    do {
                        try await categoryService.createCategory(
                            name: name,
                            displayName: displayName,
                            icon: icon,
                            color: color
                        )
                    } catch {
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                    }
                }
            }
        }
        .sheet(item: $showingEditCategory) { category in
            EditCategoryView(category: category) { name, displayName, icon, color in
                Task {
                    do {
                        try await categoryService.updateCategory(
                            category,
                            name: name,
                            displayName: displayName,
                            icon: icon,
                            color: color
                        )
                    } catch {
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                    }
                }
            }
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Eliminar Categoría", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let category = categoryToDelete {
                    Task {
                        do {
                            try await categoryService.deleteCategory(category)
                        } catch {
                            errorMessage = error.localizedDescription
                            showingErrorAlert = true
                        }
                    }
                }
            }
        } message: {
            if let category = categoryToDelete {
                Text("¿Estás seguro de que quieres eliminar la categoría '\(category.displayName)'? Esta acción no se puede deshacer.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "tag.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Gestiona tus Categorías")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Crea y personaliza categorías de gastos para organizar mejor tus finanzas.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Buscar categorías...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.tertiarySystemBackground))
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Categories List
    private var categoriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if categoryService.isLoading {
                    ProgressView("Cargando categorías...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 50)
                } else {
                    ForEach(filteredCategories) { category in
                        CategoryRow(
                            category: category,
                            onEdit: { showingEditCategory = category },
                            onDelete: { 
                                categoryToDelete = category
                                showingDeleteAlert = true
                            },
                            onToggleActive: {
                                Task {
                                    do {
                                        try await categoryService.toggleCategoryActive(category)
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showingErrorAlert = true
                                    }
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Computed Properties
    private var filteredCategories: [CustomCategory] {
        if searchText.isEmpty {
            return categoryService.categories
        } else {
            return categoryService.searchCategories(query: searchText)
        }
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: CustomCategory
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleActive: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Category Icon
            Image(systemName: category.systemIcon)
                .font(.title2)
                .foregroundColor(category.swiftUIColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(category.swiftUIColor.opacity(0.1))
                )
            
            // Category Info
            VStack(alignment: .leading, spacing: 4) {
                Text(category.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(category.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("\(category.usageCount) usos")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if category.isDefault {
                        Text("Predeterminada")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 12) {
                // Active Toggle
                Button(action: onToggleActive) {
                    Image(systemName: category.isActive ? "eye.fill" : "eye.slash.fill")
                        .font(.title3)
                        .foregroundColor(category.isActive ? .green : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Edit Button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Delete Button (only for non-default categories)
                if !category.isDefault {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .opacity(category.isActive ? 1.0 : 0.6)
    }
}

// MARK: - Create Category View
struct CreateCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var displayName = ""
    @State private var selectedIcon = "tag.fill"
    @State private var selectedColor = "blue"
    @State private var showingIconPicker = false
    @State private var showingColorPicker = false
    
    let onSave: (String, String, String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Básica") {
                    TextField("Nombre interno", text: $name)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Nombre para mostrar", text: $displayName)
                }
                
                Section("Apariencia") {
                    HStack {
                        Text("Icono")
                        Spacer()
                        Button(action: { showingIconPicker = true }) {
                            HStack {
                                Image(systemName: selectedIcon)
                                    .foregroundColor(Color(selectedColor))
                                Text("Seleccionar")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Button(action: { showingColorPicker = true }) {
                            HStack {
                                Circle()
                                    .fill(Color(selectedColor))
                                    .frame(width: 20, height: 20)
                                Text("Seleccionar")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section("Vista Previa") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(Color(selectedColor))
                        
                        VStack(alignment: .leading) {
                            Text(displayName.isEmpty ? "Nombre de categoría" : displayName)
                                .font(.headline)
                            Text(name.isEmpty ? "nombre_interno" : name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Nueva Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        onSave(name, displayName, selectedIcon, selectedColor)
                        dismiss()
                    }
                    .disabled(name.isEmpty || displayName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerView(selectedColor: $selectedColor)
        }
    }
}

// MARK: - Edit Category View
struct EditCategoryView: View {
    let category: CustomCategory
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var displayName: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var showingIconPicker = false
    @State private var showingColorPicker = false
    
    let onSave: (String, String, String, String) -> Void
    
    init(category: CustomCategory, onSave: @escaping (String, String, String, String) -> Void) {
        self.category = category
        self.onSave = onSave
        self._name = State(initialValue: category.name)
        self._displayName = State(initialValue: category.displayName)
        self._selectedIcon = State(initialValue: category.icon)
        self._selectedColor = State(initialValue: category.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Básica") {
                    TextField("Nombre interno", text: $name)
                        .textInputAutocapitalization(.never)
                        .disabled(category.isDefault)
                    
                    TextField("Nombre para mostrar", text: $displayName)
                }
                
                Section("Apariencia") {
                    HStack {
                        Text("Icono")
                        Spacer()
                        Button(action: { showingIconPicker = true }) {
                            HStack {
                                Image(systemName: selectedIcon)
                                    .foregroundColor(Color(selectedColor))
                                Text("Seleccionar")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Button(action: { showingColorPicker = true }) {
                            HStack {
                                Circle()
                                    .fill(Color(selectedColor))
                                    .frame(width: 20, height: 20)
                                Text("Seleccionar")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section("Vista Previa") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(Color(selectedColor))
                        
                        VStack(alignment: .leading) {
                            Text(displayName.isEmpty ? "Nombre de categoría" : displayName)
                                .font(.headline)
                            Text(name.isEmpty ? "nombre_interno" : name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Editar Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        onSave(name, displayName, selectedIcon, selectedColor)
                        dismiss()
                    }
                    .disabled(name.isEmpty || displayName.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
        .sheet(isPresented: $showingColorPicker) {
            ColorPickerView(selectedColor: $selectedColor)
        }
    }
}

// MARK: - Icon Picker View
struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(CustomCategory.availableIcons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                            dismiss()
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .white : .primary)
                                
                                Text(icon)
                                    .font(.caption2)
                                    .foregroundColor(selectedIcon == icon ? .white : .secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 60, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIcon == icon ? Color.blue : Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Seleccionar Icono")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Picker View
struct ColorPickerView: View {
    @Binding var selectedColor: String
    @Environment(\.dismiss) private var dismiss
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(CustomCategory.availableColors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                            dismiss()
                        }) {
                            Circle()
                                .fill(Color(color))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Seleccionar Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CustomCategoryManagementView()
}
