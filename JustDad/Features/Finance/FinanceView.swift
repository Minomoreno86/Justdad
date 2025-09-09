//
//  FinanceView.swift
//  SoloPapá - Financial management
//
//  Expense tracking, payments, and PDF reports
//

import SwiftUI

struct FinanceView: View {
    @StateObject private var router = NavigationRouter.shared
    @State private var showingNewExpenseSheet = false
    @State private var selectedPeriod = "Este Mes"
    @State private var expenses: [MockExpense] = MockData.expenses
    
    private let periods = ["Esta Semana", "Este Mes", "Este Año"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary cards
                    VStack(spacing: 16) {
                        FinanceSummaryCard(
                            title: "Total del Mes",
                            amount: "$2,450",
                            trend: "+12%",
                            color: .blue,
                            isPositive: false
                        )
                        
                        HStack(spacing: 16) {
                            FinanceSummaryCard(
                                title: "Manutención",
                                amount: "$1,200",
                                trend: "Fijo",
                                color: .orange,
                                isPositive: false
                            )
                            
                            FinanceSummaryCard(
                                title: "Extras",
                                amount: "$1,250",
                                trend: "+25%",
                                color: .red,
                                isPositive: false
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Period selector
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Expenses list
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Gastos Recientes")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Ver Todo") {
                                // TODO: Navigate to full expenses list
                            }
                            .font(.caption)
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            // Show recent expenses from mock data
                            ForEach(MockData.recentExpenses(limit: 5), id: \.id) { expense in
                                ExpenseRow(
                                    title: expense.type,
                                    category: expense.type,
                                    amount: -expense.amount,
                                    date: expense.date.formatted(date: .abbreviated, time: .omitted),
                                    icon: "dollarsign.circle.fill",
                                    color: .blue
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Export section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reportes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                // TODO: Generate PDF report
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                    Text("Exportar PDF")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // TODO: Export CSV
                            }) {
                                HStack {
                                    Image(systemName: "tablecells.fill")
                                    Text("Exportar CSV")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Finanzas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewExpenseSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewExpenseSheet) {
                NewExpenseSheet()
            }
        }
    }
}

// MARK: - Finance Summary Card
struct FinanceSummaryCard: View {
    let title: String
    let amount: String
    let trend: String
    let color: Color
    let isPositive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(amount)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .font(.caption)
                Text(trend)
                    .font(.caption)
            }
            .foregroundColor(isPositive ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Expense Row
struct ExpenseRow: View {
    let title: String
    let category: String
    let amount: Double
    let date: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "$%.2f", abs(amount)))
                    .font(.headline)
                    .foregroundColor(amount < 0 ? .red : .green)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - New Expense Sheet
struct NewExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expenseTitle = ""
    @State private var expenseAmount = ""
    @State private var expenseCategory = "Otros"
    @State private var expenseDate = Date()
    
    private let categories = ["Educación", "Salud", "Alimentación", "Vestimenta", "Transporte", "Entretenimiento", "Regalos", "Otros"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles del Gasto") {
                    TextField("Descripción", text: $expenseTitle)
                    TextField("Monto", text: $expenseAmount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Categoría", selection: $expenseCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    DatePicker("Fecha", selection: $expenseDate, displayedComponents: .date)
                }
                
                Section("Notas Adicionales") {
                    // TODO: Add notes text field
                    Text("Campo de notas opcional")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Nuevo Gasto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // TODO: Save expense to CoreData
                        dismiss()
                    }
                    .disabled(expenseTitle.isEmpty || expenseAmount.isEmpty)
                }
            }
        }
    }
}

#Preview {
    FinanceView()
}