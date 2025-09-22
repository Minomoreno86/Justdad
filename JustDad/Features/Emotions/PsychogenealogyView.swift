import SwiftUI

struct PsychogenealogyView: View {
    @StateObject private var psychogenealogyService = PsychogenealogyService.shared
    @State private var selectedTab = 0
    @State private var showingAddMember = false
    @State private var showingPatternInsights = false
    @State private var selectedPattern: Pattern?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Family Tree Tab - Enhanced with Canvas
            NavigationView {
                VStack {
                    HStack {
                        Spacer()
                        Button("Agregar") {
                            showingAddMember = true
                        }
                        .foregroundColor(.purple)
                        .padding()
                    }
                    
                    FamilyTreeCanvasView(psychogenealogyService: psychogenealogyService)
                }
                .navigationTitle("Árbol Familiar")
                .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "tree")
                Text("Árbol")
            }
            .tag(0)
            
            // Patterns Tab - Enhanced with PatternInsightsView
            NavigationView {
                PatternInsightsView(psychogenealogyService: psychogenealogyService)
            }
            .tabItem {
                Image(systemName: "brain.head.profile")
                Text("Patrones")
            }
            .tag(1)
            
            // Letters Tab - Enhanced with Ritual View
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Letters Overview with enhanced cards
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Cartas de Liberación")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if psychogenealogyService.availableLetters.isEmpty {
                                emptyLettersView
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ForEach(psychogenealogyService.availableLetters, id: \.id) { letter in
                                        EnhancedLetterCard(
                                            letter: letter,
                                            psychogenealogyService: psychogenealogyService
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Cartas")
            }
            .tabItem {
                Image(systemName: "doc.text")
                Text("Cartas")
            }
            .tag(2)
            
            // Progress Tab - Enhanced with healing map
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        // Enhanced Progress Overview
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progreso de Sanación")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // Healing Statistics Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                HealingProgressCard(
                                    title: "Cartas Completadas",
                                    value: "\(psychogenealogyService.sessions.count)",
                                    subtitle: "de \(psychogenealogyService.availableLetters.count)",
                                    icon: "checkmark.circle.fill",
                                    color: .green
                                )
                                
                                HealingProgressCard(
                                    title: "Racha Actual",
                                    value: "7 días",
                                    subtitle: "de sanación continua",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                HealingProgressCard(
                                    title: "Patrones Detectados",
                                    value: "5",
                                    subtitle: "patrones familiares",
                                    icon: "brain.head.profile",
                                    color: .purple
                                )
                                
                                HealingProgressCard(
                                    title: "Miembros Registrados",
                                    value: "\(psychogenealogyService.familyMembers.count)",
                                    subtitle: "en el árbol familiar",
                                    icon: "person.3.fill",
                                    color: .blue
                                )
                            }
                            
                            // Overall Progress with enhanced visualization
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Progreso General")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text("50%")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.purple)
                                }
                                
                                ProgressView(value: 0.5)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                    .scaleEffect(x: 1, y: 2)
                                
                                Text("Continúa trabajando con las cartas para avanzar en tu sanación familiar")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(radius: 5)
                            )
                            
                            // Healing Map Preview
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Mapa de Sanación")
                                    .font(.headline)
                                
                                Text("Visualiza tu progreso en el mapa familiar iluminado")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Mini healing map visualization
                                MiniHealingMapView(psychogenealogyService: psychogenealogyService)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(radius: 5)
                            )
                        }
                        .padding()
                    }
                }
                .navigationTitle("Progreso")
            }
            .tabItem {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Progreso")
            }
            .tag(3)
        }
        .sheet(isPresented: $showingAddMember) {
            Text("Agregar Miembro Familiar")
                .padding()
                .background(Color.blue.opacity(0.6))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Supporting Views
    
    private var emptyLettersView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("No hay cartas disponibles")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Agrega más miembros familiares y eventos para desbloquear cartas de liberación")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Enhanced Letter Card
struct EnhancedLetterCard: View {
    let letter: PsychogenealogyLetter
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @State private var showingRitual = false
    
    var body: some View {
        Button(action: {
            showingRitual = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundColor(.purple)
                    
                    Spacer()
                    
                    Text("\(letter.duration) min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(Capsule())
                }
                
                Text(letter.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(letter.targetPattern.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(Capsule())
                
                Spacer()
                
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.purple)
                    
                    Text("Iniciar Ritual")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                    
                    Spacer()
                }
            }
            .padding()
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.purple.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingRitual) {
            PsychogenealogyRitualView(
                letter: letter,
                psychogenealogyService: psychogenealogyService
            )
        }
    }
}

// MARK: - Healing Progress Card
struct HealingProgressCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 3)
        )
    }
}

// MARK: - Mini Healing Map View
struct MiniHealingMapView: View {
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Simple tree representation
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { generation in
                    VStack(spacing: 8) {
                        ForEach(0..<2, id: \.self) { member in
                            Circle()
                                .fill(generation == 1 ? .purple.opacity(0.8) : .gray.opacity(0.4))
                                .frame(width: 20, height: 20)
                                .scaleEffect(1.0 + sin(animationPhase + CGFloat(generation + member)) * 0.1)
                        }
                    }
                }
            }
            
            Text("Cada nodo iluminado representa una carta completada")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
    }
}

#Preview {
    PsychogenealogyView()
}