//
//  RitualElementsView.swift
//  JustDad - Ritual Elements Component
//
//  Componente para elementos rituales reales en técnicas de liberación
//

import SwiftUI

struct RitualElementsView: View {
    let technique: HybridLiberationService.HybridTechnique
    @State private var selectedElements: Set<RitualElement> = []
    @State private var showingElementDetail = false
    @State private var selectedElement: RitualElement?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(technique.color)
                    Text("Elementos Rituales")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text("Selecciona los elementos que tienes disponibles para tu ritual de liberación")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(technique.color.opacity(0.1))
            )
            
            // Elements Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(technique.ritualElements, id: \.id) { element in
                    RitualElementCard(
                        element: element,
                        isSelected: selectedElements.contains(element),
                        onTap: {
                            toggleElement(element)
                        },
                        onInfo: {
                            selectedElement = element
                            showingElementDetail = true
                        }
                    )
                }
            }
            
            // Validation
            if !selectedElements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Elementos seleccionados: \(selectedElements.count)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Puedes continuar con tu ritual usando estos elementos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.1))
                )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Selecciona al menos un elemento")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text("Los elementos rituales son importantes para la efectividad de la técnica")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .sheet(isPresented: $showingElementDetail) {
            if let element = selectedElement {
                RitualElementDetailView(element: element)
            }
        }
    }
    
    private func toggleElement(_ element: RitualElement) {
        if selectedElements.contains(element) {
            selectedElements.remove(element)
        } else {
            selectedElements.insert(element)
        }
    }
}

// MARK: - Ritual Element Model
struct RitualElement: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: ElementCategory
    let color: Color
    let icon: String
    let description: String
    let purpose: String
    let instructions: String
    let isEssential: Bool
    
    enum ElementCategory: String, CaseIterable {
        case candles = "candles"
        case incense = "incense"
        case crystals = "crystals"
        case natural = "natural"
        case tools = "tools"
        case symbols = "symbols"
        
        var name: String {
            switch self {
            case .candles: return "Velas"
            case .incense: return "Incienso"
            case .crystals: return "Cristales"
            case .natural: return "Elementos Naturales"
            case .tools: return "Herramientas"
            case .symbols: return "Símbolos"
            }
        }
    }
}

// MARK: - Ritual Element Card
struct RitualElementCard: View {
    let element: RitualElement
    let isSelected: Bool
    let onTap: () -> Void
    let onInfo: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: element.icon)
                        .font(.title2)
                        .foregroundColor(element.color)
                    
                    Spacer()
                    
                    Button(action: onInfo) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(element.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(element.category.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if element.isEssential {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("Esencial")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? element.color.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? element.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Ritual Element Detail View
struct RitualElementDetailView: View {
    let element: RitualElement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: element.icon)
                            .font(.system(size: 60))
                            .foregroundColor(element.color)
                        
                        Text(element.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(element.category.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(element.color.opacity(0.1))
                    )
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Descripción")
                            .font(.headline)
                        
                        Text(element.description)
                            .font(.body)
                    }
                    
                    // Purpose
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Propósito")
                            .font(.headline)
                        
                        Text(element.purpose)
                            .font(.body)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instrucciones de Uso")
                            .font(.headline)
                        
                        Text(element.instructions)
                            .font(.body)
                    }
                    
                    // Essential Badge
                    if element.isEssential {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Este elemento es esencial para la efectividad del ritual")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow.opacity(0.1))
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Elemento Ritual")
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

// MARK: - Extensions
extension HybridLiberationService.HybridTechnique {
    var ritualElements: [RitualElement] {
        switch self {
        case .forgivenessTherapy:
            return [
                RitualElement(
                    name: "Vela Blanca",
                    category: .candles,
                    color: .white,
                    icon: "flame.fill",
                    description: "Símbolo de pureza y purificación",
                    purpose: "Crear un ambiente sagrado y purificar el espacio",
                    instructions: "Enciende la vela al inicio del ritual y déjala arder durante toda la sesión",
                    isEssential: true
                ),
                RitualElement(
                    name: "Incienso de Lavanda",
                    category: .incense,
                    color: .purple,
                    icon: "leaf.fill",
                    description: "Aroma calmante y purificador",
                    purpose: "Relajar la mente y purificar el ambiente",
                    instructions: "Enciende el incienso 5 minutos antes de comenzar",
                    isEssential: false
                ),
                RitualElement(
                    name: "Cuarzo Rosa",
                    category: .crystals,
                    color: .pink,
                    icon: "diamond.fill",
                    description: "Cristal del amor y la compasión",
                    purpose: "Facilitar el perdón y la sanación del corazón",
                    instructions: "Sostén el cristal en tu mano izquierda durante la meditación",
                    isEssential: false
                )
            ]
        case .liberationLetter:
            return [
                RitualElement(
                    name: "Papel Blanco",
                    category: .tools,
                    color: .white,
                    icon: "doc.text.fill",
                    description: "Soporte para la carta de liberación",
                    purpose: "Materializar los pensamientos y emociones",
                    instructions: "Usa papel de calidad, preferiblemente reciclado",
                    isEssential: true
                ),
                RitualElement(
                    name: "Pluma o Lápiz",
                    category: .tools,
                    color: .blue,
                    icon: "pencil",
                    description: "Herramienta de escritura",
                    purpose: "Permitir la expresión fluida de emociones",
                    instructions: "Usa una pluma que te resulte cómoda para escribir",
                    isEssential: true
                ),
                RitualElement(
                    name: "Sobre Blanco",
                    category: .tools,
                    color: .white,
                    icon: "envelope.fill",
                    description: "Contenedor para la carta",
                    purpose: "Proteger y contener la carta hasta el ritual de liberación",
                    instructions: "Coloca la carta en el sobre después de escribirla",
                    isEssential: false
                )
            ]
        case .psychogenealogy:
            return [
                RitualElement(
                    name: "Vela Verde",
                    category: .candles,
                    color: .green,
                    icon: "flame.fill",
                    description: "Símbolo de crecimiento y sanación familiar",
                    purpose: "Iluminar el árbol genealógico y sanar patrones",
                    instructions: "Enciende la vela mientras trabajas en el árbol genealógico",
                    isEssential: true
                ),
                RitualElement(
                    name: "Incienso de Sándalo",
                    category: .incense,
                    color: .brown,
                    icon: "leaf.fill",
                    description: "Aroma protector y purificador",
                    purpose: "Proteger durante el trabajo con ancestros",
                    instructions: "Enciende el incienso antes de comenzar el trabajo",
                    isEssential: false
                ),
                RitualElement(
                    name: "Amatista",
                    category: .crystals,
                    color: .purple,
                    icon: "diamond.fill",
                    description: "Cristal de protección espiritual",
                    purpose: "Proteger durante el trabajo con ancestros",
                    instructions: "Coloca el cristal cerca de ti durante la sesión",
                    isEssential: false
                )
            ]
        case .liberationRitual:
            return [
                RitualElement(
                    name: "Vela Naranja",
                    category: .candles,
                    color: .orange,
                    icon: "flame.fill",
                    description: "Símbolo de transformación y creatividad",
                    purpose: "Facilitar la transformación y liberación",
                    instructions: "Enciende la vela al inicio del ritual",
                    isEssential: true
                ),
                RitualElement(
                    name: "Incienso de Mirra",
                    category: .incense,
                    color: .brown,
                    icon: "leaf.fill",
                    description: "Aroma sagrado y purificador",
                    purpose: "Purificar y santificar el espacio ritual",
                    instructions: "Enciende el incienso 10 minutos antes del ritual",
                    isEssential: true
                ),
                RitualElement(
                    name: "Sal Marina",
                    category: .natural,
                    color: .white,
                    icon: "drop.fill",
                    description: "Elemento purificador natural",
                    purpose: "Purificar el espacio y proteger energéticamente",
                    instructions: "Esparce sal en los bordes del espacio ritual",
                    isEssential: false
                )
            ]
        case .energeticCords:
            return [
                RitualElement(
                    name: "Vela Púrpura",
                    category: .candles,
                    color: .purple,
                    icon: "flame.fill",
                    description: "Símbolo de transformación espiritual",
                    purpose: "Facilitar el trabajo energético",
                    instructions: "Enciende la vela durante la visualización",
                    isEssential: true
                ),
                RitualElement(
                    name: "Incienso de Palo Santo",
                    category: .incense,
                    color: .brown,
                    icon: "leaf.fill",
                    description: "Aroma purificador y protector",
                    purpose: "Limpiar el campo energético",
                    instructions: "Usa el palo santo para limpiar tu aura antes del ritual",
                    isEssential: false
                ),
                RitualElement(
                    name: "Citrino",
                    category: .crystals,
                    color: .yellow,
                    icon: "diamond.fill",
                    description: "Cristal de alegría y protección",
                    purpose: "Proteger y elevar la energía",
                    instructions: "Sostén el cristal durante la visualización",
                    isEssential: false
                )
            ]
        case .pastLifeBonds:
            return [
                RitualElement(
                    name: "Vela Índigo",
                    category: .candles,
                    color: .indigo,
                    icon: "flame.fill",
                    description: "Símbolo de sabiduría espiritual",
                    purpose: "Facilitar la conexión con vidas pasadas",
                    instructions: "Enciende la vela durante la meditación profunda",
                    isEssential: true
                ),
                RitualElement(
                    name: "Incienso de Copal",
                    category: .incense,
                    color: .brown,
                    icon: "leaf.fill",
                    description: "Aroma sagrado ancestral",
                    purpose: "Conectar con el alma eterna",
                    instructions: "Enciende el incienso antes de la meditación",
                    isEssential: false
                ),
                RitualElement(
                    name: "Lapislázuli",
                    category: .crystals,
                    color: .blue,
                    icon: "diamond.fill",
                    description: "Cristal de sabiduría y conexión espiritual",
                    purpose: "Facilitar la conexión con vidas pasadas",
                    instructions: "Coloca el cristal en tu tercer ojo durante la meditación",
                    isEssential: false
                )
            ]
        }
    }
}

#Preview {
    RitualElementsView(technique: .forgivenessTherapy)
        .padding()
}


