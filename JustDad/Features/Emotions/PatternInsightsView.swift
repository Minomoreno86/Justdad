import SwiftUI

// MARK: - Pattern Insights View
struct PatternInsightsView: View {
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @State private var selectedPattern: Pattern?
    @State private var showPatternDetail = false
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with overall insights
                    patternOverviewSection
                    
                    // Patterns grid
                    patternsGridSection
                    
                    // Healing progress
                    healingProgressSection
                }
                .padding()
            }
            .navigationTitle("Patrones Familiares")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.05), Color.blue.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .sheet(isPresented: $showPatternDetail) {
            if let selectedPattern = selectedPattern {
                PatternDetailView(pattern: selectedPattern, psychogenealogyService: psychogenealogyService)
            }
        }
        .onAppear {
            startPatternAnimation()
        }
    }
    
    // MARK: - Pattern Overview Section
    private var patternOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Análisis Familiar")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(psychogenealogyService.detectedPatterns.count) patrones detectados")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Animated pattern icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.1)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(1.0 + sin(animationPhase) * 0.1)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
            }
            
            // Pattern severity distribution
            patternSeverityChart
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 5)
        )
    }
    
    private var patternSeverityChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución por Severidad")
                .font(.headline)
            
            let patterns = Array(psychogenealogyService.detectedPatterns)
            let highSeverity = patterns.filter { $0.score >= 80 }.count
            let mediumSeverity = patterns.filter { $0.score >= 50 && $0.score < 80 }.count
            let lowSeverity = patterns.filter { $0.score < 50 }.count
            let total = patterns.count
            
            if total > 0 {
                HStack(spacing: 16) {
                    SeverityBar(
                        label: "Alta",
                        count: highSeverity,
                        total: total,
                        color: .red,
                        animationPhase: animationPhase
                    )
                    
                    SeverityBar(
                        label: "Media",
                        count: mediumSeverity,
                        total: total,
                        color: .orange,
                        animationPhase: animationPhase
                    )
                    
                    SeverityBar(
                        label: "Baja",
                        count: lowSeverity,
                        total: total,
                        color: .green,
                        animationPhase: animationPhase
                    )
                }
            } else {
                Text("No hay patrones detectados aún")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    // MARK: - Patterns Grid Section
    private var patternsGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Patrones Detectados")
                .font(.title2)
                .fontWeight(.bold)
            
            let patterns = Array(psychogenealogyService.detectedPatterns)
            
            if patterns.isEmpty {
                emptyPatternsView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(patterns, id: \.id) { pattern in
                        SimplePatternCard(
                            pattern: pattern,
                            isSelected: selectedPattern?.id == pattern.id,
                            animationPhase: animationPhase
                        ) {
                            selectedPattern = pattern
                            showPatternDetail = true
                        }
                    }
                }
            }
        }
    }
    
    private var emptyPatternsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.purple.opacity(0.5))
            
            Text("No hay patrones detectados")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Agrega más miembros familiares y eventos para detectar patrones automáticamente")
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
    
    // MARK: - Healing Progress Section
    private var healingProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progreso de Sanación")
                .font(.title2)
                .fontWeight(.bold)
            
            let completedSessions = psychogenealogyService.sessions.count
            let totalLetters = psychogenealogyService.availableLetters.count
            
            VStack(spacing: 12) {
                HStack {
                    Text("Cartas Completadas")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(completedSessions)/\(totalLetters)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: totalLetters > 0 ? Double(completedSessions) / Double(totalLetters) : 0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                    .scaleEffect(x: 1, y: 2)
                
                HStack {
                    SimpleHealingStatCard(
                        title: "Racha",
                        value: "7 días",
                        icon: "flame.fill",
                        color: .orange,
                        animationPhase: animationPhase
                    )
                    
                    SimpleHealingStatCard(
                        title: "Liberados",
                        value: "3 patrones",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        animationPhase: animationPhase
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 5)
        )
    }
    
    // MARK: - Helper Methods
    private func startPatternAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }
}

// MARK: - Supporting Views

struct SeverityBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let animationPhase: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                    .frame(width: 20, height: 60)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 20, height: total > 0 ? 60 * CGFloat(count) / CGFloat(total) : 0)
                    .scaleEffect(y: 1.0 + sin(animationPhase + Double(label.hashValue)) * 0.1)
            }
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

struct SimplePatternCard: View {
    let pattern: Pattern
    let isSelected: Bool
    let animationPhase: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: patternIcon(for: pattern.name))
                        .font(.title2)
                        .foregroundColor(patternColor(for: pattern.score))
                    
                    Spacer()
                    
                    Text("\(pattern.score)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(patternColor(for: pattern.score))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(patternColor(for: pattern.score).opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Text(pattern.name.capitalized)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(pattern.evidence.count) evidencias")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .frame(height: 120)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? patternColor(for: pattern.score).opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? patternColor(for: pattern.score) : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func patternIcon(for name: String) -> String {
        if name.contains("absence") { return "person.slash" }
        if name.contains("divorce") { return "heart.slash" }
        if name.contains("death") { return "cross.circle" }
        if name.contains("secret") { return "eye.slash" }
        if name.contains("migration") { return "airplane" }
        return "brain.head.profile"
    }
    
    private func patternColor(for score: Int) -> Color {
        switch score {
        case 80...: return .red
        case 50..<80: return .orange
        default: return .green
        }
    }
}

struct SimpleHealingStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let animationPhase: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .scaleEffect(1.0 + sin(animationPhase + Double(title.hashValue)) * 0.1)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Pattern Detail View
struct PatternDetailView: View {
    let pattern: Pattern
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    patternHeaderSection
                    evidenceSection
                    actionSection
                }
                .padding()
            }
            .navigationTitle("Detalle del Patrón")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var patternHeaderSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 48))
                    .foregroundColor(patternColor(for: pattern.score))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(pattern.name.capitalized)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Severidad: \(pattern.score)%")
                        .font(.subheadline)
                        .foregroundColor(patternColor(for: pattern.score))
                }
                
                Spacer()
            }
            
            if !pattern.description.isEmpty {
                Text(pattern.description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var evidenceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Evidencias (\(pattern.evidence.count))")
                .font(.headline)
            
            ForEach(pattern.evidence, id: \.id) { evidence in
                SimpleEvidenceRow(evidence: evidence)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                // Start working with recommended letters
            }) {
                Text("Comenzar Trabajo de Sanación")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.purple)
                    )
            }
            
            Button(action: {
                // Export pattern data
            }) {
                Text("Exportar Información")
                    .font(.subheadline)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.purple, lineWidth: 1)
                    )
            }
        }
    }
    
    private func patternColor(for score: Int) -> Color {
        switch score {
        case 80...: return .red
        case 50..<80: return .orange
        default: return .green
        }
    }
}

struct SimpleEvidenceRow: View {
    let evidence: PatternEvidence
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(evidence.description)
                    .font(.subheadline)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    PatternInsightsView(psychogenealogyService: PsychogenealogyService.shared)
}