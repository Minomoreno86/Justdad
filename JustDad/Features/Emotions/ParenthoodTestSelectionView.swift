//
//  ParenthoodTestSelectionView.swift
//  JustDad - Test Selection Interface
//
//  Professional test selection for fathers
//

import SwiftUI

struct ParenthoodTestSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var testService = ParenthoodTestService.shared
    @State private var selectedTest: ParenthoodTestService.TestType?
    @State private var showingTest = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Tests de Paternidad")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Evalúa tu preparación y habilidades como padre durante este proceso")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Available Tests
                    LazyVStack(spacing: 16) {
                        ForEach(ParenthoodTestService.TestType.allCases) { testType in
                            TestSelectionCard(testType: testType) {
                                selectedTest = testType
                                showingTest = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("¿Cómo funcionan estos tests?")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "clock", text: "Cada test toma entre 4-8 minutos")
                            InfoRow(icon: "chart.bar.fill", text: "Recibe un análisis detallado de tus resultados")
                            InfoRow(icon: "lightbulb.fill", text: "Obtén recomendaciones personalizadas")
                            InfoRow(icon: "lock.fill", text: "Tus respuestas son completamente privadas")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Tests de Paternidad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingTest) {
                if let testType = selectedTest {
                    ParenthoodTestView(testType: testType)
                }
            }
        }
    }
}

// MARK: - Test Selection Card
struct TestSelectionCard: View {
    let testType: ParenthoodTestService.TestType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: testType.icon)
                        .font(.title2)
                        .foregroundColor(testType.color)
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(testType.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(testType.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(testType.estimatedTime)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(testType.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(testType.color.opacity(0.1))
                            .cornerRadius(8)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: testType.color.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(testType.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    ParenthoodTestSelectionView()
}
