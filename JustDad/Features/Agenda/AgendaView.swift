//
//  AgendaView.swift
//  SoloPapá - Calendar and visits management
//
//  Calendar view with visit scheduling and management
//

import SwiftUI

struct AgendaView: View {
    @StateObject private var router = NavigationRouter.shared
    @State private var selectedDate = Date()
    @State private var showingNewVisitSheet = false
    @State private var visits: [MockVisit] = MockData.visits
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar placeholder
                VStack {
                    Text("📅 Calendar Component")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("TODO: Implement calendar with visit highlights")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Visits list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Próximas Visitas")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Placeholder visits
                            VisitRow(
                                title: "Fin de semana con los niños",
                                date: "Sábado 14 Sept",
                                time: "9:00 AM - 6:00 PM",
                                type: .weekend
                            )
                            
                            VisitRow(
                                title: "Cena entre semana",
                                date: "Miércoles 18 Sept",
                                time: "6:00 PM - 8:00 PM",
                                type: .dinner
                            )
                            
                            VisitRow(
                                title: "Evento escolar",
                                date: "Viernes 20 Sept",
                                time: "3:00 PM - 5:00 PM",
                                type: .event
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Agenda")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewVisitSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewVisitSheet) {
                NewVisitSheet()
            }
        }
    }
}

// MARK: - Visit Row Component
struct VisitRow: View {
    let title: String
    let date: String
    let time: String
    let type: VisitType
    
    enum VisitType {
        case weekend, dinner, event
        
        var color: Color {
            switch self {
            case .weekend: return .blue
            case .dinner: return .green
            case .event: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .weekend: return "house.fill"
            case .dinner: return "fork.knife"
            case .event: return "star.fill"
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(type.color)
                    .frame(width: 30, height: 30)
                    .background(type.color.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // TODO: Edit visit
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - New Visit Sheet
struct NewVisitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var visitTitle = ""
    @State private var visitDate = Date()
    @State private var visitType = VisitRow.VisitType.weekend
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Detalles de la Visita") {
                    TextField("Título", text: $visitTitle)
                    DatePicker("Fecha y Hora", selection: $visitDate)
                    
                    // TODO: Add visit type picker
                    // TODO: Add location field
                    // TODO: Add notes field
                }
                
                Section("Recordatorios") {
                    // TODO: Add reminder settings
                    Text("Configuración de recordatorios")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Nueva Visita")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        // TODO: Save visit to CoreData
                        dismiss()
                    }
                    .disabled(visitTitle.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AgendaView()
}
