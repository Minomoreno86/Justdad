//
//  MockData.swift
//  JustDad - Mock data collections
//
//  Centralized mock data for app development and testing
//

import Foundation

// MARK: - Mood Enum
enum Mood: String, CaseIterable {
    case happy, neutral, stressed
}

// MARK: - Mock Types
struct MockVisit: Identifiable {
    let id = UUID()
    var date: Date
    var title: String
    var notes: String?
    var type: VisitType
    
    struct VisitType {
        let name: String
        let color: String
        let icon: String
        
        static let checkup = VisitType(name: "Checkup", color: "blue", icon: "stethoscope")
        static let vaccination = VisitType(name: "Vacunación", color: "green", icon: "shield.fill")
        static let consultation = VisitType(name: "Consulta", color: "orange", icon: "person.crop.circle.badge.questionmark")
        static let emergency = VisitType(name: "Emergencia", color: "red", icon: "exclamationmark.triangle.fill")
    }
}

struct MockExpense: Identifiable {
    let id = UUID()
    var type: String
    var amount: Double
    var date: Date
    var receiptName: String?
}

struct MockJournalEntry: Identifiable {
    let id = UUID()
    
    enum Kind {
        case text
        case audio
        case photo
    }
    
    var kind: Kind
    var title: String
    var content: String
    var date: Date
    var tags: [String]
    var mood: Mood
}

struct MockCommunityPost: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var author: String
    var date: Date
    var category: String
    var isLiked: Bool = false
    var likesCount: Int = 0
    var commentsCount: Int = 0
}

// MARK: - Mock Data Collections
struct MockData {
    // MARK: - Visit Data
    static let visits: [MockVisit] = [
        MockVisit(
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
            title: "Doctor checkup",
            notes: "Regular pediatric visit for growth monitoring",
            type: .checkup
        ),
        MockVisit(
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            title: "Dental appointment",
            notes: "First dental visit - teeth cleaning",
            type: .consultation
        )
    ]
    
    // MARK: - Expense Data
    static let expenses: [MockExpense] = [
        MockExpense(
            type: "Healthcare",
            amount: 125.50,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            receiptName: "receipt_doctor_visit.pdf"
        ),
        MockExpense(
            type: "Education",
            amount: 89.99,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            receiptName: "receipt_books.pdf"
        ),
        MockExpense(
            type: "Food",
            amount: 42.30,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            receiptName: nil
        )
    ]
    
    // MARK: - Journal Data
    static let journal: [MockJournalEntry] = [
        MockJournalEntry(
            kind: .text,
            title: "Picnic con Sofía",
            content: "Hoy jugamos en el parque y leímos su libro favorito.",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            tags: ["hija", "parque", "recuerdo"],
            mood: .happy
        ),
        MockJournalEntry(
            kind: .photo,
            title: "Tarea de ciencias",
            content: "Foto del experimento del volcán, nos divertimos mucho.",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            tags: ["escuela", "aprendizaje"],
            mood: .neutral
        ),
        MockJournalEntry(
            kind: .audio,
            title: "Noche difícil",
            content: "Me sentí ansioso, respiré 4-7-8 y mejoré.",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            tags: ["emociones", "autocuidado"],
            mood: .stressed
        ),
        MockJournalEntry(
            kind: .text,
            title: "Pequeña victoria",
            content: "Pude registrar los gastos del mes a tiempo.",
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
            tags: ["finanzas", "logro"],
            mood: .happy
        )
    ]
    
    // MARK: - Community Data
    static let communityPosts: [MockCommunityPost] = [
        MockCommunityPost(
            title: "Consejos para regresión del sueño",
            content: "¿Alguien tiene consejos para la regresión del sueño a los 18 meses? Mi hijo se despierta cada hora.",
            author: "PapáDeDos",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            category: "Consejos",
            isLiked: false,
            likesCount: 5,
            commentsCount: 3
        ),
        MockCommunityPost(
            title: "Introduciendo alimentos sólidos",
            content: "¿Consejos para introducir comida sólida? Mi bebé de 6 meses parece interesado pero tengo miedo de que se atragante.",
            author: "PrimerPapá",
            date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
            category: "Preguntas",
            isLiked: true,
            likesCount: 8,
            commentsCount: 7
        ),
        MockCommunityPost(
            title: "Actividades para días lluviosos",
            content: "¿Ideas de actividades en interiores para días lluviosos? Se me acaban las ideas con mi hijo de 2 años.",
            author: "PapáActivo",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            category: "Experiencias",
            isLiked: false,
            likesCount: 12,
            commentsCount: 15
        ),
        MockCommunityPost(
            title: "Equilibrio trabajo-familia",
            content: "¿Cómo manejan el estrés del trabajo cuando solo quieren estar presentes para sus hijos?",
            author: "PapáTrabajador",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            category: "Preguntas",
            isLiked: false,
            likesCount: 20,
            commentsCount: 25
        ),
        MockCommunityPost(
            title: "Apoyo para papás",
            content: "A todos los papás - ¡lo están haciendo genial! Algunos días son más difíciles que otros pero podemos con esto.",
            author: "PapáFuerte",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            category: "Experiencias",
            isLiked: true,
            likesCount: 45,
            commentsCount: 30
        )
    ]
    
    // MARK: - Helper Methods
    static func recentExpenses(limit: Int = 5) -> [MockExpense] {
        return Array(expenses.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    static func upcomingVisits(limit: Int = 3) -> [MockVisit] {
        let futureVisits = visits.filter { $0.date > Date() }
        return Array(futureVisits.sorted { $0.date < $1.date }.prefix(limit))
    }
    
    static func recentJournalEntries(limit: Int = 5) -> [MockJournalEntry] {
        return Array(journal.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    static func recentCommunityPosts(limit: Int = 10) -> [MockCommunityPost] {
        return Array(communityPosts.sorted { $0.date > $1.date }.prefix(limit))
    }
}

// MARK: - Compatibility Extensions
extension MockData {
    static var sampleEntries: [MockJournalEntry] { journal }
}
