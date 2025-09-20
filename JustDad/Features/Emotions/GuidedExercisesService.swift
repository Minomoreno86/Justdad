//
//  GuidedExercisesService.swift
//  JustDad - Professional Guided Exercises
//
//  Advanced guided exercises for emotional well-being
//

import Foundation
import SwiftUI
import AVFoundation

// MARK: - Guided Exercises Service
class GuidedExercisesService: ObservableObject {
    static let shared = GuidedExercisesService()
    
    @Published var exercises: [GuidedExercise] = []
    @Published var completedExercises: [CompletedExercise] = []
    @Published var currentExercise: GuidedExercise?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    private init() {
        loadExercises()
        loadCompletedExercises()
    }
    
    // MARK: - Exercise Management
    func startExercise(_ exercise: GuidedExercise) {
        currentExercise = exercise
        totalDuration = exercise.duration
        currentTime = 0
        isPlaying = true
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentTime += 1
            if self.currentTime >= self.totalDuration {
                self.completeExercise()
            }
        }
        
        // Play audio if available
        if let audioURL = exercise.audioURL {
            playAudio(from: audioURL)
        }
    }
    
    func pauseExercise() {
        isPlaying = false
        timer?.invalidate()
        audioPlayer?.pause()
    }
    
    func resumeExercise() {
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.currentTime += 1
            if self.currentTime >= self.totalDuration {
                self.completeExercise()
            }
        }
        audioPlayer?.play()
    }
    
    func stopExercise() {
        isPlaying = false
        timer?.invalidate()
        audioPlayer?.stop()
        currentExercise = nil
        currentTime = 0
        totalDuration = 0
    }
    
    private func completeExercise() {
        guard let exercise = currentExercise else { return }
        
        let completed = CompletedExercise(
            exerciseId: exercise.id,
            completedAt: Date(),
            duration: currentTime
        )
        
        completedExercises.append(completed)
        saveCompletedExercises()
        
        stopExercise()
    }
    
    // MARK: - Audio Management
    private func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    // MARK: - Data Management
    private func loadExercises() {
        exercises = GuidedExercise.allExercises
    }
    
    private func loadCompletedExercises() {
        if let data = UserDefaults.standard.data(forKey: "completed_exercises"),
           let completed = try? JSONDecoder().decode([CompletedExercise].self, from: data) {
            completedExercises = completed
        }
    }
    
    private func saveCompletedExercises() {
        if let data = try? JSONEncoder().encode(completedExercises) {
            UserDefaults.standard.set(data, forKey: "completed_exercises")
        }
    }
    
    // MARK: - Statistics
    var totalCompletedExercises: Int {
        completedExercises.count
    }
    
    var favoriteCategory: ExerciseCategory? {
        let categoryCounts = Dictionary(grouping: completedExercises) { completed in
            exercises.first { $0.id == completed.exerciseId }?.category
        }.compactMapValues { $0.count }
        
        return categoryCounts.max { $0.value < $1.value }?.key
    }
    
    var weeklyProgress: [String: Int] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let weeklyCompleted = completedExercises.filter { $0.completedAt >= weekAgo }
        return Dictionary(grouping: weeklyCompleted) { completed in
            exercises.first { $0.id == completed.exerciseId }?.category.title ?? "Unknown"
        }.mapValues { $0.count }
    }
}

// MARK: - Guided Exercise Model
struct GuidedExercise: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: ExerciseCategory
    let duration: TimeInterval
    let difficulty: ExerciseDifficulty
    let benefits: [String]
    let instructions: [String]
    let audioURL: URL?
    let imageName: String
    let isPremium: Bool
    
    init(title: String, description: String, category: ExerciseCategory, duration: TimeInterval, difficulty: ExerciseDifficulty, benefits: [String], instructions: [String], audioURL: URL? = nil, imageName: String, isPremium: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.duration = duration
        self.difficulty = difficulty
        self.benefits = benefits
        self.instructions = instructions
        self.audioURL = audioURL
        self.imageName = imageName
        self.isPremium = isPremium
    }
    
    static let allExercises: [GuidedExercise] = [
        // MARK: - Meditación
        GuidedExercise(
            title: "Meditación de Respiración Consciente",
            description: "Una meditación guiada de 10 minutos para centrarte en el presente",
            category: .meditation,
            duration: 600, // 10 minutos
            difficulty: .beginner,
            benefits: ["Reduce el estrés", "Mejora la concentración", "Calma la mente"],
            instructions: [
                "Siéntate cómodamente con la espalda recta",
                "Cierra los ojos y respira naturalmente",
                "Enfócate en la sensación de la respiración",
                "Cuando tu mente divague, regresa suavemente a la respiración"
            ],
            imageName: "meditation"
        ),
        
        GuidedExercise(
            title: "Meditación de Compasión",
            description: "Cultiva la compasión hacia ti mismo y tus hijos",
            category: .meditation,
            duration: 900, // 15 minutos
            difficulty: .intermediate,
            benefits: ["Desarrolla la compasión", "Mejora las relaciones", "Reduce la culpa"],
            instructions: [
                "Siéntate cómodamente y cierra los ojos",
                "Imagina una luz cálida en tu corazón",
                "Envía compasión a ti mismo",
                "Extiende esa compasión a tus hijos",
                "Mantén esa sensación de amor y comprensión"
            ],
            imageName: "heart"
        ),
        
        // MARK: - Respiración
        GuidedExercise(
            title: "Respiración 4-7-8",
            description: "Técnica de respiración para calmar el sistema nervioso",
            category: .breathing,
            duration: 300, // 5 minutos
            difficulty: .beginner,
            benefits: ["Calma inmediata", "Reduce la ansiedad", "Mejora el sueño"],
            instructions: [
                "Inhala por la nariz contando hasta 4",
                "Mantén la respiración contando hasta 7",
                "Exhala por la boca contando hasta 8",
                "Repite el ciclo 4 veces"
            ],
            imageName: "lungs"
        ),
        
        GuidedExercise(
            title: "Respiración de Coherencia Cardíaca",
            description: "Sincroniza tu respiración con tu ritmo cardíaco",
            category: .breathing,
            duration: 600, // 10 minutos
            difficulty: .intermediate,
            benefits: ["Equilibra el sistema nervioso", "Mejora la claridad mental", "Reduce el cortisol"],
            instructions: [
                "Coloca una mano en el corazón",
                "Respira suavemente a un ritmo de 5 segundos",
                "Siente la conexión entre respiración y latidos",
                "Mantén un ritmo constante y relajado"
            ],
            imageName: "heart.circle"
        ),
        
        // MARK: - Calma
        GuidedExercise(
            title: "Relajación Muscular Progresiva",
            description: "Libera la tensión muscular paso a paso",
            category: .calm,
            duration: 1200, // 20 minutos
            difficulty: .beginner,
            benefits: ["Libera tensión física", "Mejora el sueño", "Reduce el dolor"],
            instructions: [
                "Acuéstate cómodamente",
                "Tensa cada grupo muscular por 5 segundos",
                "Relaja completamente por 10 segundos",
                "Continúa desde los pies hasta la cabeza"
            ],
            imageName: "figure.walk"
        ),
        
        GuidedExercise(
            title: "Visualización de Lugar Seguro",
            description: "Crea un refugio mental para momentos difíciles",
            category: .calm,
            duration: 900, // 15 minutos
            difficulty: .intermediate,
            benefits: ["Crea un refugio mental", "Reduce la ansiedad", "Mejora la resiliencia"],
            instructions: [
                "Cierra los ojos y respira profundamente",
                "Imagina un lugar donde te sientas completamente seguro",
                "Usa todos tus sentidos para crear la imagen",
                "Permanece en ese lugar por unos minutos"
            ],
            imageName: "house"
        ),
        
        // MARK: - Desahogo
        GuidedExercise(
            title: "Liberación Emocional Segura",
            description: "Expresa y libera emociones de forma saludable",
            category: .emotionalRelease,
            duration: 1800, // 30 minutos
            difficulty: .intermediate,
            benefits: ["Libera emociones reprimidas", "Mejora el bienestar", "Reduce la tensión"],
            instructions: [
                "Encuentra un espacio privado",
                "Permítete sentir todas las emociones",
                "Expresa lo que sientes (llora, grita, escribe)",
                "No juzgues tus emociones",
                "Termina con respiraciones profundas"
            ],
            imageName: "person.crop.circle"
        ),
        
        GuidedExercise(
            title: "Escritura Terapéutica",
            description: "Libera pensamientos y sentimientos a través de la escritura",
            category: .emotionalRelease,
            duration: 1200, // 20 minutos
            difficulty: .beginner,
            benefits: ["Clarifica pensamientos", "Libera emociones", "Mejora la autocomprensión"],
            instructions: [
                "Toma papel y lápiz",
                "Escribe sin parar por 20 minutos",
                "No te preocupes por la gramática o coherencia",
                "Escribe lo que sientes en este momento",
                "Al final, puedes quemar o guardar el papel"
            ],
            imageName: "pencil"
        ),
        
        // MARK: - Manejo de Ira
        GuidedExercise(
            title: "Técnica de Pausa",
            description: "Detén la respuesta automática de ira",
            category: .angerManagement,
            duration: 300, // 5 minutos
            difficulty: .beginner,
            benefits: ["Previene arrebatos", "Mejora el control", "Preserva relaciones"],
            instructions: [
                "Cuando sientas ira, haz una pausa",
                "Respira profundamente 3 veces",
                "Cuenta hasta 10 lentamente",
                "Pregúntate: '¿Qué necesito ahora?'",
                "Responde desde la calma"
            ],
            imageName: "pause.circle"
        ),
        
        GuidedExercise(
            title: "Transformación de Ira",
            description: "Convierte la ira en energía constructiva",
            category: .angerManagement,
            duration: 900, // 15 minutos
            difficulty: .intermediate,
            benefits: ["Transforma energía negativa", "Mejora la comunicación", "Reduce conflictos"],
            instructions: [
                "Reconoce la ira sin juzgarla",
                "Identifica la necesidad no satisfecha",
                "Respira profundamente",
                "Encuentra una forma constructiva de expresar tu necesidad",
                "Actúa desde el amor, no desde el miedo"
            ],
            imageName: "arrow.triangle.2.circlepath"
        ),
        
        // MARK: - Sueño
        GuidedExercise(
            title: "Relajación para Dormir",
            description: "Prepara tu mente y cuerpo para un sueño reparador",
            category: .sleep,
            duration: 1800, // 30 minutos
            difficulty: .beginner,
            benefits: ["Mejora la calidad del sueño", "Reduce el insomnio", "Relaja el cuerpo"],
            instructions: [
                "Acuéstate en tu cama",
                "Respira profundamente y relaja cada músculo",
                "Imagina una escalera que desciende",
                "Con cada escalón, te sientes más relajado",
                "Permítete dormir cuando llegues al final"
            ],
            imageName: "moon"
        ),
        
        GuidedExercise(
            title: "Meditación de Gratitud Nocturna",
            description: "Termina el día con gratitud y paz",
            category: .sleep,
            duration: 600, // 10 minutos
            difficulty: .beginner,
            benefits: ["Mejora el estado de ánimo", "Facilita el sueño", "Cultiva la gratitud"],
            instructions: [
                "Acuéstate cómodamente",
                "Piensa en 3 cosas por las que estés agradecido hoy",
                "Siente la gratitud en tu corazón",
                "Imagina enviando gratitud a tus hijos",
                "Permítete dormir en paz"
            ],
            imageName: "star"
        ),
        
        // MARK: - Fortaleza
        GuidedExercise(
            title: "Afirmaciones de Fortaleza",
            description: "Fortalece tu confianza y resiliencia",
            category: .strength,
            duration: 600, // 10 minutos
            difficulty: .beginner,
            benefits: ["Aumenta la confianza", "Mejora la autoestima", "Desarrolla resiliencia"],
            instructions: [
                "Siéntate cómodamente",
                "Repite estas afirmaciones:",
                "'Soy un buen padre'",
                "'Puedo superar cualquier desafío'",
                "'Merezco amor y felicidad'",
                "Siente la verdad de cada afirmación"
            ],
            imageName: "shield"
        ),
        
        GuidedExercise(
            title: "Visualización de Éxito",
            description: "Visualiza el futuro que deseas para ti y tus hijos",
            category: .strength,
            duration: 1200, // 20 minutos
            difficulty: .intermediate,
            benefits: ["Clarifica objetivos", "Aumenta la motivación", "Mejora la confianza"],
            instructions: [
                "Cierra los ojos y respira profundamente",
                "Imagina tu vida ideal en 1 año",
                "Ve a tus hijos felices y saludables",
                "Siente la satisfacción de tus logros",
                "Mantén esa imagen positiva"
            ],
            imageName: "target"
        ),
        
        // MARK: - Paternidad
        GuidedExercise(
            title: "Conexión con tus Hijos",
            description: "Fortalece el vínculo emocional con tus hijos",
            category: .parenting,
            duration: 900, // 15 minutos
            difficulty: .beginner,
            benefits: ["Mejora la relación", "Aumenta la comprensión", "Reduce conflictos"],
            instructions: [
                "Siéntate cómodamente",
                "Imagina a cada uno de tus hijos",
                "Envíales amor incondicional",
                "Visualiza momentos felices juntos",
                "Comprométete a ser el mejor padre posible"
            ],
            imageName: "person.2"
        ),
        
        GuidedExercise(
            title: "Manejo de Culpa Parental",
            description: "Libera la culpa y abraza la imperfección",
            category: .parenting,
            duration: 1200, // 20 minutos
            difficulty: .intermediate,
            benefits: ["Reduce la culpa", "Mejora la autoaceptación", "Libera la perfección"],
            instructions: [
                "Reconoce que eres humano",
                "Perdónate por los errores del pasado",
                "Acepta que haces lo mejor que puedes",
                "Comprométete a aprender y crecer",
                "Enfócate en el amor que das"
            ],
            imageName: "heart.text.square"
        )
    ]
}

// MARK: - Exercise Category
enum ExerciseCategory: String, CaseIterable, Codable {
    case meditation = "meditation"
    case breathing = "breathing"
    case calm = "calm"
    case emotionalRelease = "emotionalRelease"
    case angerManagement = "angerManagement"
    case sleep = "sleep"
    case strength = "strength"
    case parenting = "parenting"
    
    var title: String {
        switch self {
        case .meditation: return "Meditación"
        case .breathing: return "Respiración"
        case .calm: return "Calma"
        case .emotionalRelease: return "Desahogo"
        case .angerManagement: return "Manejo de Ira"
        case .sleep: return "Sueño"
        case .strength: return "Fortaleza"
        case .parenting: return "Paternidad"
        }
    }
    
    var icon: String {
        switch self {
        case .meditation: return "brain.head.profile"
        case .breathing: return "lungs"
        case .calm: return "leaf"
        case .emotionalRelease: return "heart.circle"
        case .angerManagement: return "flame"
        case .sleep: return "moon"
        case .strength: return "shield"
        case .parenting: return "person.2"
        }
    }
    
    var color: Color {
        switch self {
        case .meditation: return .purple
        case .breathing: return .blue
        case .calm: return .green
        case .emotionalRelease: return .pink
        case .angerManagement: return .red
        case .sleep: return .indigo
        case .strength: return .orange
        case .parenting: return .teal
        }
    }
    
    var description: String {
        switch self {
        case .meditation: return "Prácticas de mindfulness y atención plena"
        case .breathing: return "Técnicas de respiración para calmar la mente"
        case .calm: return "Ejercicios de relajación y tranquilidad"
        case .emotionalRelease: return "Liberación segura de emociones reprimidas"
        case .angerManagement: return "Control y transformación de la ira"
        case .sleep: return "Técnicas para mejorar la calidad del sueño"
        case .strength: return "Fortalecimiento de la resiliencia personal"
        case .parenting: return "Ejercicios específicos para padres"
        }
    }
}

// MARK: - Exercise Difficulty
enum ExerciseDifficulty: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var title: String {
        switch self {
        case .beginner: return "Principiante"
        case .intermediate: return "Intermedio"
        case .advanced: return "Avanzado"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// MARK: - Completed Exercise
struct CompletedExercise: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let completedAt: Date
    let duration: TimeInterval
    
    init(exerciseId: UUID, completedAt: Date, duration: TimeInterval) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.completedAt = completedAt
        self.duration = duration
    }
}
