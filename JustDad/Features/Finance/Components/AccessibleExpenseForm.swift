//
//  AccessibleExpenseForm.swift
//  JustDad - Accessible Expense Form Components
//
//  Professional accessible form components for expense management.
//

import SwiftUI

// MARK: - Accessible Expense Form
struct AccessibleExpenseForm: View {
    @Binding var title: String
    @Binding var amount: String
    @Binding var selectedCategory: FinancialEntry.ExpenseCategory
    @Binding var selectedType: FinancialEntry.ExpenseType
    @Binding var date: Date
    @Binding var notes: String
    
    let onSubmit: () -> Void
    let onCancel: () -> Void
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información Básica") {
                    TextField("Título del gasto", text: $title)
                        .accessibilityLabel("Título del gasto")
                        .accessibilityHint("Introduce un título descriptivo para el gasto")
                    
                    TextField("Monto", text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityLabel("Monto")
                        .accessibilityHint("Introduce el monto del gasto en dólares")
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(FinancialEntry.ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .accessibilityLabel("Categoría del gasto")
                }
                
                Section("Tipo") {
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(FinancialEntry.ExpenseType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .accessibilityLabel("Tipo de gasto")
                }
                
                Section("Fecha") {
                    DatePicker("Fecha", selection: $date, displayedComponents: .date)
                        .accessibilityLabel("Fecha del gasto")
                }
                
                Section("Notas") {
                    TextField("Notas (opcional)", text: $notes, axis: .vertical)
                        .accessibilityLabel("Notas")
                        .accessibilityHint("Añade cualquier detalle relevante sobre este gasto")
                }
            }
            .navigationTitle("Nuevo Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        validateAndSubmit()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Error de Validación", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    private func validateAndSubmit() {
        guard !title.isEmpty else {
            errorMessage = "El título es requerido"
            showingError = true
            return
        }
        
        guard !amount.isEmpty, let _ = Double(amount) else {
            errorMessage = "El monto debe ser un número válido"
            showingError = true
            return
        }
        
        onSubmit()
    }
}