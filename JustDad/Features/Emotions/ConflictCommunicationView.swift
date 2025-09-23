//
//  ConflictCommunicationView.swift
//  JustDad - Conflict Communication Training
//
//  BIFF communication trainer for conflict wellness
//

import SwiftUI

struct ConflictCommunicationView: View {
    @StateObject private var service = ConflictWellnessService.shared
    @State private var currentExample: CommunicationExample?
    @State private var userResponse = ""
    @State private var showingResult = false
    @State private var currentResult: CommunicationTrainingResult?
    @State private var selectedCategory = "Todas"
    @State private var showingRules = false
    
    private let categories = ["Todas"] + Set(ConflictWellnessContentPack.communicationExamples.map { $0.category }).sorted()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Rules Section
                rulesSection
                
                // Category Selector
                categorySelector
                
                // Training Section
                if let example = currentExample {
                    trainingSection(example)
                } else {
                    emptyStateSection
                }
                
                // Stats Section
                statsSection
            }
            .padding()
        }
        .navigationBarHidden(true)
        .onAppear {
            if currentExample == nil {
                loadRandomExample()
            }
        }
        .sheet(isPresented: $showingRules) {
            CommunicationRulesView()
        }
        .sheet(isPresented: $showingResult) {
            if let result = currentResult {
                CommunicationResultView(result: result) {
                    showingResult = false
                    loadRandomExample()
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "message.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Entrenador de Comunicación Serena")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Practica respuestas BIFF: Breve, Clara, Amable, Firme")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Rules Section
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reglas de Comunicación Serena")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Ver Todas") {
                    showingRules = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                RuleCard(
                    letter: "B",
                    word: "Breve",
                    description: "Respuestas cortas y al punto"
                )
                
                RuleCard(
                    letter: "I",
                    word: "Clara",
                    description: "Hechos específicos y concretos"
                )
                
                RuleCard(
                    letter: "A",
                    word: "Amable",
                    description: "Tono neutro y respetuoso"
                )
                
                RuleCard(
                    letter: "F",
                    word: "Firme",
                    description: "Cierra el tema sin debate"
                )
            }
        }
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categoría de Ejercicio")
                .font(.subheadline)
                .fontWeight(.medium)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                            loadRandomExample()
                        }) {
                            Text(category)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedCategory == category ? Color.blue : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedCategory == category ? .white : .primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Training Section
    private func trainingSection(_ example: CommunicationExample) -> some View {
        VStack(spacing: 16) {
            // Scenario Card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Escenario")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(example.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
                
                Text("\"\(example.trigger)\"")
                    .font(.body)
                    .italic()
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            
            // Response Input
            VStack(alignment: .leading, spacing: 12) {
                Text("Tu Respuesta Serena")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextEditor(text: $userResponse)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Button("Evaluar Respuesta") {
                    evaluateResponse()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(userResponse.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(userResponse.isEmpty)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            
            // Example Response (shown after evaluation)
            if showingResult {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ejemplo de Respuesta Serena")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(example.responseSerena)
                        .font(.body)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    
                    HStack {
                        ForEach(example.checks, id: \.self) { check in
                            Text(check)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Selecciona una categoría para comenzar")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button("Cargar Ejemplo Aleatorio") {
                loadRandomExample()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tu Progreso")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                ConflictStatItem(
                    title: "Total",
                    value: "\(service.stats.totalResponses)",
                    color: .blue
                )
                
                ConflictStatItem(
                    title: "Serenas",
                    value: "\(service.stats.serenaResponses)",
                    color: .green
                )
                
                ConflictStatItem(
                    title: "% Éxito",
                    value: String(format: "%.0f%%", service.stats.serenaPercentage),
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func loadRandomExample() {
        let filteredExamples = selectedCategory == "Todas" 
            ? ConflictWellnessContentPack.communicationExamples
            : ConflictWellnessContentPack.communicationExamples.filter { $0.category == selectedCategory }
        
        currentExample = filteredExamples.randomElement()
        userResponse = ""
        showingResult = false
        currentResult = nil
    }
    
    private func evaluateResponse() {
        guard let example = currentExample else { return }
        
        let result = CommunicationTrainingResult(
            example: example,
            userResponse: userResponse,
            isBreve: isBreve(userResponse),
            isClara: isClara(userResponse),
            isAmable: isAmable(userResponse),
            isFirme: isFirme(userResponse),
            score: calculateScore(userResponse, example: example),
            date: Date()
        )
        
        currentResult = result
        service.addTrainingResult(result)
        showingResult = true
    }
    
    private func isBreve(_ response: String) -> Bool {
        return response.count <= 100
    }
    
    private func isClara(_ response: String) -> Bool {
        let clarityKeywords = ["estaré", "llegaré", "confirmo", "cumpliré", "haré", "a las", "el día", "mañana", "hoy"]
        return clarityKeywords.contains { keyword in
            response.lowercased().contains(keyword)
        }
    }
    
    private func isAmable(_ response: String) -> Bool {
        let negativeWords = ["no", "nunca", "jamás", "tú", "tu", "tuya", "tuyo", "siempre", "nadie", "nada"]
        let hasNegativeWords = negativeWords.contains { word in
            response.lowercased().contains(word)
        }
        return !hasNegativeWords && !response.contains("?") && !response.contains("!")
    }
    
    private func isFirme(_ response: String) -> Bool {
        let firmEndings = [".", "gracias", "saludos"]
        return firmEndings.contains { ending in
            response.lowercased().hasSuffix(ending)
        }
    }
    
    private func calculateScore(_ response: String, example: CommunicationExample) -> Int {
        var score = 0
        if isBreve(response) { score += 1 }
        if isClara(response) { score += 1 }
        if isAmable(response) { score += 1 }
        if isFirme(response) { score += 1 }
        return score * example.points
    }
}

// MARK: - Supporting Views

struct RuleCard: View {
    let letter: String
    let word: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(letter)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(word)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

struct ConflictStatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ConflictCommunicationView()
}
