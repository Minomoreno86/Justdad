//
//  LiberationTechniqueDetailView.swift
//  JustDad - Liberation Technique Detail View
//
//  Vista detallada para cada técnica de liberación con pasos guiados
//

import SwiftUI

struct LiberationTechniqueDetailView: View {
    let technique: LiberationService.LiberationTechnique
    @StateObject private var liberationService = LiberationService.shared
    @State private var currentStepIndex = 0
    @State private var isSessionActive = false
    @State private var sessionNotes = ""
    @State private var progress = 5
    @State private var showingCompletion = false
    @State private var showingForgivenessTherapy = false
    @Environment(\.dismiss) private var dismiss
    
    private var steps: [LiberationStep] {
        getSteps(for: technique)
    }
    
    private var currentStep: LiberationStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if technique.isForgivenessTherapy {
                    // Redirect to Forgiveness Therapy View
                    ForgivenessTherapyView()
                } else if technique == .liberationLetter {
                    // Redirect to Liberation Letter System
                    LiberationLetterView()
                        .onDisappear {
                            dismiss()
                        }
                } else if isSessionActive {
                    sessionView
                } else {
                    techniqueOverviewView
                }
            }
            .navigationTitle(technique.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                if isSessionActive && !technique.isForgivenessTherapy {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Finalizar") {
                            showingCompletion = true
                        }
                        .disabled(currentStepIndex < steps.count - 1)
                    }
                }
            }
            .sheet(isPresented: $showingCompletion) {
                LiberationSessionCompletionView(
                    technique: technique,
                    notes: $sessionNotes,
                    progress: $progress,
                    onComplete: completeSession
                )
            }
        }
    }
    
    // MARK: - Technique Overview View
    private var techniqueOverviewView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: technique.icon)
                        .font(.system(size: 80))
                        .foregroundColor(technique.color)
                    
                    Text(technique.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "clock")
                                .font(.title3)
                                .foregroundColor(technique.color)
                            Text(technique.estimatedTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Image(systemName: "chart.bar")
                                .font(.title3)
                                .foregroundColor(technique.color)
                            Text("Guía paso a paso")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(technique.color.opacity(0.1))
                )
                
                // Steps Preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pasos de la Técnica")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        LiberationStepPreviewCard(step: step, stepNumber: index + 1)
                    }
                }
                
                // Start Session Button
                Button(action: startSession) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Iniciar Sesión de Liberación")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(technique.color)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    // MARK: - Session View
    private var sessionView: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressView(value: Double(currentStepIndex + 1), total: Double(steps.count))
                .progressViewStyle(LinearProgressViewStyle(tint: technique.color))
                .padding()
            
            // Current Step
            if let step = currentStep {
                ScrollView {
                    VStack(spacing: 24) {
                        // Step Header
                        VStack(spacing: 16) {
                            Text("Paso \(currentStepIndex + 1) de \(steps.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(step.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text(step.duration)
                                .font(.caption)
                                .foregroundColor(technique.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(technique.color.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(technique.color.opacity(0.1))
                        )
                        
                        // Step Description
                        Text(step.description)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        // Meditation Text
                        if let meditationText = step.meditationText {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "quote.bubble.fill")
                                        .foregroundColor(technique.color)
                                    Text("Meditación")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                
                                Text(meditationText)
                                    .font(.body)
                                    .italic()
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(UIColor.systemGray6))
                                    )
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            
            // Navigation Buttons
            HStack(spacing: 16) {
                if currentStepIndex > 0 {
                    Button("Anterior") {
                        withAnimation {
                            currentStepIndex -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
                
                if currentStepIndex < steps.count - 1 {
                    Button("Siguiente") {
                        withAnimation {
                            currentStepIndex += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(technique.color)
                    .frame(maxWidth: .infinity)
                } else {
                    Button("Completar Técnica") {
                        showingCompletion = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(technique.color)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
    
    // MARK: - Actions
    private func startSession() {
        isSessionActive = true
        currentStepIndex = 0
    }
    
    private func completeSession() {
        liberationService.addSession(
            technique: technique,
            notes: sessionNotes,
            progress: progress
        )
        dismiss()
    }
    
    // MARK: - Liberation Steps
    private func getSteps(for technique: LiberationService.LiberationTechnique) -> [LiberationStep] {
        switch technique {
        case .forgivenessTherapy:
            return forgivenessTherapySteps
        case .liberationLetter:
            return liberationLetterSteps
        case .psychogenealogy:
            return psychogenealogySteps
        case .liberationRitual:
            return liberationRitualSteps
        case .energeticCords:
            return energeticCordsSteps
        case .pastLifeBonds:
            return pastLifeBondsSteps
        }
    }
}

// MARK: - Liberation Step
struct LiberationStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let meditationText: String?
    
    init(title: String, description: String, duration: String, meditationText: String? = nil) {
        self.title = title
        self.description = description
        self.duration = duration
        self.meditationText = meditationText
    }
}

// MARK: - Liberation Step Preview Card
struct LiberationStepPreviewCard: View {
    let step: LiberationStep
    let stepNumber: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(stepNumber)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(.blue))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(step.duration)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray6))
        )
        .padding(.horizontal)
    }
}

// MARK: - Liberation Steps Data
extension LiberationTechniqueDetailView {
    
    // MARK: - Forgiveness Therapy Steps
    private var forgivenessTherapySteps: [LiberationStep] {
        [
            LiberationStep(
                title: "Preparación",
                description: "Encuentra un lugar tranquilo y cómodo. Respira profundamente y relájate.",
                duration: "2-3 min",
                meditationText: "Inhala paz, exhala tensión. Permítete estar presente en este momento de sanación."
            ),
            LiberationStep(
                title: "Identificación",
                description: "Identifica a la persona o situación que necesitas perdonar. No juzgues, solo observa.",
                duration: "3-5 min",
                meditationText: "Observa sin juzgar. Permite que las emociones surjan naturalmente."
            ),
            LiberationStep(
                title: "Comprensión",
                description: "Intenta entender las circunstancias que llevaron a esa situación. Busca la humanidad en el otro.",
                duration: "5-7 min",
                meditationText: "Todos somos humanos, todos cometemos errores. La compasión es la clave del perdón."
            ),
            LiberationStep(
                title: "Perdón",
                description: "Repite mentalmente: 'Te perdono, me perdono, libero esta carga'.",
                duration: "3-5 min",
                meditationText: "Te perdono por tu dolor. Me perdono por mi dolor. Libero esta carga con amor."
            ),
            LiberationStep(
                title: "Liberación",
                description: "Visualiza la situación siendo liberada como una nube que se disipa en el cielo.",
                duration: "2-3 min",
                meditationText: "Visualiza la situación elevándose como una nube blanca, llevándose todo el dolor."
            )
        ]
    }
    
    // MARK: - Liberation Letter Steps (Updated to use new system)
    private var liberationLetterSteps: [LiberationStep] {
        [
            LiberationStep(
                title: "Sistema de 21 Días",
                description: "Accede al sistema completo de Cartas de Liberación con detección de voz y seguimiento de progreso.",
                duration: "5-7 min por carta"
            )
        ]
    }
    
    // MARK: - Psychogenealogy Steps
    private var psychogenealogySteps: [LiberationStep] {
        [
            LiberationStep(
                title: "Árbol Genealógico",
                description: "Dibuja tu árbol genealógico con las emociones y patrones que observas.",
                duration: "5-10 min",
                meditationText: "Observa los patrones que se repiten. No juzgues, solo observa."
            ),
            LiberationStep(
                title: "Identificación de Patrones",
                description: "Identifica patrones repetitivos en tu familia: divorcios, adicciones, miedos, etc.",
                duration: "5-7 min",
                meditationText: "Los patrones familiares son oportunidades de sanación, no condenas."
            ),
            LiberationStep(
                title: "Reconocimiento",
                description: "Reconoce cómo estos patrones te afectan actualmente en tu vida.",
                duration: "3-5 min",
                meditationText: "Al reconocer el patrón, ya has comenzado a liberarte de él."
            ),
            LiberationStep(
                title: "Liberación Ancestral",
                description: "Visualiza sanando a tus ancestros y liberando los patrones familiares.",
                duration: "5-7 min",
                meditationText: "Con amor, libero a mis ancestros de su dolor y me libero del mío."
            ),
            LiberationStep(
                title: "Nuevo Patrón",
                description: "Crea un nuevo patrón positivo para ti y tus descendientes.",
                duration: "3-5 min",
                meditationText: "Elijo crear un nuevo legado de amor, paz y sanación."
            )
        ]
    }
    
    // MARK: - Liberation Ritual Steps
    private var liberationRitualSteps: [LiberationStep] {
        [
            LiberationStep(
                title: "Preparación del Espacio",
                description: "Prepara un espacio sagrado con velas, incienso o música relajante.",
                duration: "3-5 min",
                meditationText: "Este espacio es sagrado. Aquí me conecto con mi esencia divina."
            ),
            LiberationStep(
                title: "Intención",
                description: "Establece claramente tu intención de liberación. ¿Qué quieres liberar?",
                duration: "2-3 min",
                meditationText: "Mi intención es clara: liberar lo que ya no me sirve con amor y gratitud."
            ),
            LiberationStep(
                title: "Ritual de Purificación",
                description: "Lávate las manos o toma una ducha simbólica para purificarte.",
                duration: "2-3 min",
                meditationText: "Con esta agua, me purifico de todo lo que ya no me sirve."
            ),
            LiberationStep(
                title: "Ceremonia de Liberación",
                description: "Realiza un ritual simbólico: quema papel, entierra objetos, etc.",
                duration: "5-7 min",
                meditationText: "Con este acto sagrado, libero al universo todo lo que necesito soltar."
            ),
            LiberationStep(
                title: "Gratitud y Renovación",
                description: "Agradece por la liberación y visualiza tu nueva realidad.",
                duration: "3-5 min",
                meditationText: "Agradezco por esta liberación. Recibo con amor mi nueva realidad."
            )
        ]
    }
    
    // MARK: - Energetic Cords Steps
    private var energeticCordsSteps: [LiberationStep] {
        [
            LiberationStep(
                title: "Meditación de Conexión",
                description: "Medita y visualiza los cordones energéticos que te conectan con otras personas.",
                duration: "3-5 min",
                meditationText: "Observo los cordones de luz que me conectan con el mundo."
            ),
            LiberationStep(
                title: "Identificación de Cordones",
                description: "Identifica qué cordones son saludables y cuáles son tóxicos o dependientes.",
                duration: "5-7 min",
                meditationText: "Con amor, distingo entre conexiones sanas y dependencias tóxicas."
            ),
            LiberationStep(
                title: "Corte Consciente",
                description: "Visualiza cortando los cordones tóxicos con amor y gratitud.",
                duration: "5-7 min",
                meditationText: "Con amor, corto estos cordones. Te libero y me libero con gratitud."
            ),
            LiberationStep(
                title: "Sanación",
                description: "Visualiza sanando las heridas donde estaban los cordones cortados.",
                duration: "3-5 min",
                meditationText: "Con luz dorada, sanó estas heridas. Me lleno de amor propio."
            ),
            LiberationStep(
                title: "Protección",
                description: "Visualiza una burbuja de luz protegiendo tu campo energético.",
                duration: "2-3 min",
                meditationText: "Me envuelvo en una burbuja de luz dorada. Estoy protegido y en paz."
            )
        ]
    }
    
    // MARK: - Past Life Bonds Steps
    private var pastLifeBondsSteps: [LiberationStep] {
        [
            LiberationStep(
                title: "Meditación Profunda",
                description: "Entra en un estado de meditación profunda para conectar con vidas pasadas.",
                duration: "5-7 min",
                meditationText: "Me conecto con mi alma eterna. Observo las vidas que he vivido."
            ),
            LiberationStep(
                title: "Exploración",
                description: "Explora las conexiones kármicas y vínculos del alma que persisten.",
                duration: "5-10 min",
                meditationText: "Con amor, observo las lecciones que mi alma ha venido a aprender."
            ),
            LiberationStep(
                title: "Reconocimiento",
                description: "Reconoce los patrones kármicos que se repiten en esta vida.",
                duration: "3-5 min",
                meditationText: "Reconozco estos patrones como oportunidades de crecimiento."
            ),
            LiberationStep(
                title: "Liberación Kármica",
                description: "Visualiza liberando los vínculos kármicos con amor y comprensión.",
                duration: "5-7 min",
                meditationText: "Con amor, libero estos vínculos kármicos. Acepto las lecciones aprendidas."
            ),
            LiberationStep(
                title: "Renovación del Alma",
                description: "Visualiza tu alma renovada, libre de cargas del pasado.",
                duration: "3-5 min",
                meditationText: "Mi alma se renueva. Soy libre de crear mi realidad presente con amor."
            )
        ]
    }
}

#Preview {
    LiberationTechniqueDetailView(technique: .forgivenessTherapy)
}
