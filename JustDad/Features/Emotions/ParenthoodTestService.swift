//
//  ParenthoodTestService.swift
//  JustDad - Professional Parenthood Assessment Tests
//
//  Psychological tests specifically designed for fathers in divorce process
//

import Foundation
import SwiftUI

// MARK: - Parenthood Test Service
public class ParenthoodTestService: ObservableObject {
    static let shared = ParenthoodTestService()
    
    private init() {}
    
    // MARK: - Available Tests
    public enum TestType: String, CaseIterable, Identifiable {
        case emotionalReadiness = "emotional_readiness"
        case communicationSkills = "communication_skills"
        case stressManagement = "stress_management"
        case parentingConfidence = "parenting_confidence"
        case workLifeBalance = "work_life_balance"
        
        public var id: String { rawValue }
        
        public var title: String {
            switch self {
            case .emotionalReadiness: return "Preparación Emocional"
            case .communicationSkills: return "Habilidades de Comunicación"
            case .stressManagement: return "Gestión del Estrés"
            case .parentingConfidence: return "Confianza Parental"
            case .workLifeBalance: return "Balance Vida-Trabajo"
            }
        }
        
        public var description: String {
            switch self {
            case .emotionalReadiness: return "Evalúa tu preparación emocional para manejar el divorcio y la paternidad"
            case .communicationSkills: return "Mide tus habilidades para comunicarte efectivamente con tus hijos"
            case .stressManagement: return "Analiza cómo manejas el estrés en situaciones difíciles"
            case .parentingConfidence: return "Determina tu nivel de confianza como padre"
            case .workLifeBalance: return "Evalúa tu capacidad para balancear trabajo y familia"
            }
        }
        
        var icon: String {
            switch self {
            case .emotionalReadiness: return "heart.circle.fill"
            case .communicationSkills: return "bubble.left.and.bubble.right.fill"
            case .stressManagement: return "lungs.fill"
            case .parentingConfidence: return "person.2.fill"
            case .workLifeBalance: return "scale.3d"
            }
        }
        
        var color: Color {
            switch self {
            case .emotionalReadiness: return .red
            case .communicationSkills: return .blue
            case .stressManagement: return .green
            case .parentingConfidence: return .purple
            case .workLifeBalance: return .orange
            }
        }
        
        public var estimatedTime: String {
            switch self {
            case .emotionalReadiness: return "5-7 min"
            case .communicationSkills: return "4-6 min"
            case .stressManagement: return "6-8 min"
            case .parentingConfidence: return "5-7 min"
            case .workLifeBalance: return "4-6 min"
            }
        }
    }
    
    // MARK: - Test Questions
    func getQuestions(for testType: TestType) -> [TestQuestion] {
        switch testType {
        case .emotionalReadiness:
            return emotionalReadinessQuestions
        case .communicationSkills:
            return communicationSkillsQuestions
        case .stressManagement:
            return stressManagementQuestions
        case .parentingConfidence:
            return parentingConfidenceQuestions
        case .workLifeBalance:
            return workLifeBalanceQuestions
        }
    }
    
    // MARK: - Test Results
    func calculateResult(for testType: TestType, answers: [Int]) -> TestResult {
        let totalScore = answers.reduce(0, +)
        let maxScore = answers.count * 5 // Assuming 5-point scale
        let percentage = Double(totalScore) / Double(maxScore) * 100
        
        return TestResult(
            testType: testType,
            score: totalScore,
            maxScore: maxScore,
            percentage: percentage,
            level: getLevel(for: percentage),
            recommendations: getRecommendations(for: testType, level: getLevel(for: percentage))
        )
    }
    
    private func getLevel(for percentage: Double) -> TestLevel {
        switch percentage {
        case 0..<40: return .needsImprovement
        case 40..<60: return .developing
        case 60..<80: return .good
        case 80...100: return .excellent
        default: return .developing
        }
    }
    
    private func getRecommendations(for testType: TestType, level: TestLevel) -> [String] {
        switch (testType, level) {
        case (.emotionalReadiness, .needsImprovement):
            return [
                "Considera buscar apoyo profesional o terapéutico",
                "Practica técnicas de respiración y mindfulness diariamente",
                "Conecta con otros padres que han pasado por situaciones similares",
                "Tómate tiempo para procesar tus emociones antes de interactuar con tus hijos"
            ]
        case (.emotionalReadiness, .developing):
            return [
                "Continúa trabajando en tu inteligencia emocional",
                "Practica la comunicación abierta con tus hijos",
                "Mantén rutinas que te ayuden a mantener el equilibrio"
            ]
        case (.emotionalReadiness, .good):
            return [
                "Mantén las estrategias que te están funcionando",
                "Considera ayudar a otros padres en situaciones similares",
                "Sigue desarrollando tu resiliencia emocional"
            ]
        case (.emotionalReadiness, .excellent):
            return [
                "¡Excelente trabajo! Eres un ejemplo de fortaleza emocional",
                "Considera compartir tus estrategias con otros padres",
                "Mantén tu equilibrio y continúa siendo un apoyo para tus hijos"
            ]
        // Add more cases for other test types...
        default:
            return ["Continúa trabajando en esta área"]
        }
    }
}

// MARK: - Test Question Model
struct TestQuestion: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let category: String?
    
    init(text: String, options: [String], category: String? = nil) {
        self.text = text
        self.options = options
        self.category = category
    }
}

// MARK: - Test Result Model
struct TestResult: Identifiable {
    let id = UUID()
    let testType: ParenthoodTestService.TestType
    let score: Int
    let maxScore: Int
    let percentage: Double
    let level: TestLevel
    let recommendations: [String]
    let date: Date = Date()
}

enum TestLevel: String, CaseIterable {
    case needsImprovement = "needs_improvement"
    case developing = "developing"
    case good = "good"
    case excellent = "excellent"
    
    var title: String {
        switch self {
        case .needsImprovement: return "Necesita Mejora"
        case .developing: return "En Desarrollo"
        case .good: return "Bueno"
        case .excellent: return "Excelente"
        }
    }
    
    var color: Color {
        switch self {
        case .needsImprovement: return .red
        case .developing: return .orange
        case .good: return .blue
        case .excellent: return .green
        }
    }
    
    var description: String {
        switch self {
        case .needsImprovement: return "Hay áreas importantes que necesitan atención"
        case .developing: return "Estás progresando, continúa trabajando"
        case .good: return "Tienes una base sólida, sigue mejorando"
        case .excellent: return "¡Excelente trabajo! Eres un gran ejemplo"
        }
    }
}

// MARK: - Test Questions Data
extension ParenthoodTestService {
    private var emotionalReadinessQuestions: [TestQuestion] {
        [
            TestQuestion(
                text: "¿Cómo te sientes cuando tus hijos expresan emociones fuertes?",
                options: [
                    "Me siento abrumado y no sé qué hacer",
                    "Me siento incómodo pero trato de ayudar",
                    "Me siento preparado para manejar la situación",
                    "Me siento confiado y puedo guiarlos efectivamente",
                    "Me siento completamente cómodo y es una oportunidad de conexión"
                ],
                category: "Gestión Emocional"
            ),
            TestQuestion(
                text: "¿Con qué frecuencia te sientes preparado para las conversaciones difíciles con tus hijos?",
                options: [
                    "Nunca me siento preparado",
                    "Raramente me siento preparado",
                    "A veces me siento preparado",
                    "Frecuentemente me siento preparado",
                    "Siempre me siento preparado"
                ],
                category: "Comunicación"
            ),
            TestQuestion(
                text: "¿Cómo manejas el estrés relacionado con la paternidad?",
                options: [
                    "Me siento completamente abrumado",
                    "Tengo dificultades para manejarlo",
                    "A veces puedo manejarlo bien",
                    "Generalmente lo manejo bien",
                    "Lo manejo muy bien y me siento en control"
                ],
                category: "Gestión del Estrés"
            ),
            TestQuestion(
                text: "¿Qué tan cómodo te sientes expresando tus propias emociones frente a tus hijos?",
                options: [
                    "Muy incómodo, evito hacerlo",
                    "Algo incómodo, raramente lo hago",
                    "Neutral, a veces lo hago",
                    "Cómodo, lo hago regularmente",
                    "Muy cómodo, es parte de mi relación con ellos"
                ],
                category: "Autenticidad"
            ),
            TestQuestion(
                text: "¿Cómo te sientes sobre tu capacidad para ser un buen padre durante este proceso?",
                options: [
                    "No creo que pueda ser un buen padre",
                    "Tengo muchas dudas sobre mi capacidad",
                    "A veces tengo dudas, pero creo que puedo lograrlo",
                    "Me siento bastante confiado en mi capacidad",
                    "Me siento muy confiado y preparado"
                ],
                category: "Confianza Parental"
            )
        ]
    }
    
    private var communicationSkillsQuestions: [TestQuestion] {
        [
            TestQuestion(
                text: "¿Con qué frecuencia escuchas activamente a tus hijos sin interrumpir?",
                options: [
                    "Nunca",
                    "Raramente",
                    "A veces",
                    "Frecuentemente",
                    "Siempre"
                ],
                category: "Escucha Activa"
            ),
            TestQuestion(
                text: "¿Cómo manejas los desacuerdos con tus hijos?",
                options: [
                    "Evito el conflicto completamente",
                    "Me frustro y pierdo la paciencia",
                    "A veces manejo bien, a veces no",
                    "Generalmente mantengo la calma y busco soluciones",
                    "Siempre mantengo la calma y busco entendimiento mutuo"
                ],
                category: "Resolución de Conflictos"
            ),
            TestQuestion(
                text: "¿Qué tan efectivo eres explicando cosas complejas a tus hijos?",
                options: [
                    "Muy inefectivo",
                    "Algo inefectivo",
                    "Neutral",
                    "Bastante efectivo",
                    "Muy efectivo"
                ],
                category: "Claridad en la Comunicación"
            )
        ]
    }
    
    private var stressManagementQuestions: [TestQuestion] {
        [
            TestQuestion(
                text: "¿Con qué frecuencia practicas técnicas de relajación?",
                options: [
                    "Nunca",
                    "Raramente",
                    "A veces",
                    "Frecuentemente",
                    "Diariamente"
                ],
                category: "Técnicas de Relajación"
            ),
            TestQuestion(
                text: "¿Cómo manejas los momentos de alta presión con tus hijos?",
                options: [
                    "Me siento completamente abrumado",
                    "Tengo dificultades para mantener la calma",
                    "A veces puedo manejarlo",
                    "Generalmente mantengo la calma",
                    "Siempre mantengo la calma y busco soluciones"
                ],
                category: "Manejo de Presión"
            )
        ]
    }
    
    private var parentingConfidenceQuestions: [TestQuestion] {
        [
            TestQuestion(
                text: "¿Qué tan seguro te sientes tomando decisiones importantes sobre tus hijos?",
                options: [
                    "Muy inseguro",
                    "Algo inseguro",
                    "Neutral",
                    "Bastante seguro",
                    "Muy seguro"
                ],
                category: "Toma de Decisiones"
            ),
            TestQuestion(
                text: "¿Cómo te sientes sobre tu capacidad para establecer límites apropiados?",
                options: [
                    "No creo que pueda hacerlo bien",
                    "Tengo muchas dudas",
                    "A veces me siento capaz",
                    "Generalmente me siento capaz",
                    "Me siento muy capaz"
                ],
                category: "Establecimiento de Límites"
            )
        ]
    }
    
    private var workLifeBalanceQuestions: [TestQuestion] {
        [
            TestQuestion(
                text: "¿Qué tan bien balanceas tu tiempo entre trabajo y familia?",
                options: [
                    "Muy mal",
                    "Algo mal",
                    "Neutral",
                    "Bastante bien",
                    "Muy bien"
                ],
                category: "Balance de Tiempo"
            ),
            TestQuestion(
                text: "¿Con qué frecuencia puedes estar completamente presente cuando estás con tus hijos?",
                options: [
                    "Nunca",
                    "Raramente",
                    "A veces",
                    "Frecuentemente",
                    "Siempre"
                ],
                category: "Presencia"
            )
        ]
    }
}
