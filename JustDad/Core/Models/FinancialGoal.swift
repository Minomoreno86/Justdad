//
//  FinancialGoal.swift
//  JustDad - Financial Goal Model
//
//  Professional model for managing financial goals and achievements.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Financial Goal Model
@Model
final class FinancialGoal {
    var id: UUID
    var title: String
    var goalDescription: String?
    var targetAmount: Decimal
    var currentAmount: Decimal
    var targetDate: Date
    var category: GoalCategory
    var priority: GoalPriority
    var isActive: Bool
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Computed Properties
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(truncating: NSDecimalNumber(decimal: currentAmount / targetAmount)), 1.0)
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: now, to: targetDate).day ?? 0
        return max(0, days)
    }
    
    var isOverdue: Bool {
        return targetDate < Date() && !isCompleted
    }
    
    var isOnTrack: Bool {
        let daysElapsed = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
        let expectedProgress = Double(daysElapsed) / Double(daysElapsed + daysRemaining)
        return progressPercentage >= expectedProgress * 0.8 // 80% tolerance
    }
    
    var weeklyTarget: Decimal {
        guard daysRemaining > 0 else { return 0 }
        let remainingAmount = targetAmount - currentAmount
        return remainingAmount / Decimal(daysRemaining / 7)
    }
    
    init(title: String, description: String? = nil, targetAmount: Decimal, targetDate: Date, category: GoalCategory, priority: GoalPriority = .medium) {
        self.id = UUID()
        self.title = title
        self.goalDescription = description
        self.targetAmount = targetAmount
        self.currentAmount = 0
        self.targetDate = targetDate
        self.category = category
        self.priority = priority
        self.isActive = true
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Goal Category
enum GoalCategory: String, CaseIterable, Codable, Identifiable {
    case emergency = "emergency"
    case education = "education"
    case vacation = "vacation"
    case home = "home"
    case transportation = "transportation"
    case entertainment = "entertainment"
    case food = "food"
    case gifts = "gifts"
    case custom = "custom"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .emergency: return "Fondo de Emergencia"
        case .education: return "Educación"
        case .vacation: return "Vacaciones"
        case .home: return "Hogar"
        case .transportation: return "Transporte"
        case .entertainment: return "Entretenimiento"
        case .food: return "Alimentación"
        case .gifts: return "Regalos"
        case .custom: return "Personalizada"
        }
    }
    
    var iconName: String {
        switch self {
        case .emergency: return "shield.fill"
        case .education: return "book.fill"
        case .vacation: return "airplane"
        case .home: return "house.fill"
        case .transportation: return "car.fill"
        case .entertainment: return "tv.fill"
        case .food: return "fork.knife"
        case .gifts: return "gift.fill"
        case .custom: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .emergency: return .green
        case .education: return .blue
        case .vacation: return .cyan
        case .home: return .brown
        case .transportation: return .red
        case .entertainment: return .purple
        case .food: return .orange
        case .gifts: return .pink
        case .custom: return .gray
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .emergency:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .education:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .vacation:
            return LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .home:
            return LinearGradient(colors: [.brown, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .transportation:
            return LinearGradient(colors: [.red, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .entertainment:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .food:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gifts:
            return LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .custom:
            return LinearGradient(colors: [.gray, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Goal Priority
enum GoalPriority: String, CaseIterable, Codable, Identifiable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        case .urgent: return "Urgente"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .low: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .high: return "3.circle.fill"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Goal Achievement
@Model
final class GoalAchievement {
    var id: UUID
    var goalId: UUID
    var achievementType: AchievementType
    var earnedAt: Date
    var badgeIcon: String
    var badgeTitle: String
    var badgeDescription: String
    var isCelebrated: Bool
    
    init(goalId: UUID, achievementType: AchievementType) {
        self.id = UUID()
        self.goalId = goalId
        self.achievementType = achievementType
        self.earnedAt = Date()
        self.badgeIcon = achievementType.iconName
        self.badgeTitle = achievementType.title
        self.badgeDescription = achievementType.description
        self.isCelebrated = false
    }
}

// MARK: - Achievement Type
enum AchievementType: String, CaseIterable, Codable, Identifiable {
    case goalCompleted = "goal_completed"
    case goalCompletedOnTime = "goal_completed_on_time"
    case goalCompletedEarly = "goal_completed_early"
    case goalProgress25 = "goal_progress_25"
    case goalProgress50 = "goal_progress_50"
    case goalProgress75 = "goal_progress_75"
    case goalStreak3 = "goal_streak_3"
    case goalStreak5 = "goal_streak_5"
    case goalStreak10 = "goal_streak_10"
    case superSaver = "super_saver"
    case persistent = "persistent"
    case precise = "precise"
    case fatherExemplar = "father_exemplar"
    case smartSaver = "smart_saver"
    case celebration = "celebration"
    case homeSecure = "home_secure"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .goalCompleted: return "Meta Cumplida"
        case .goalCompletedOnTime: return "A Tiempo"
        case .goalCompletedEarly: return "Súper Ahorrador"
        case .goalProgress25: return "En Camino"
        case .goalProgress50: return "En Racha"
        case .goalProgress75: return "Casi Ahí"
        case .goalStreak3: return "Constante"
        case .goalStreak5: return "Persistente"
        case .goalStreak10: return "Inquebrantable"
        case .superSaver: return "Súper Ahorrador"
        case .persistent: return "Persistente"
        case .precise: return "Preciso"
        case .fatherExemplar: return "Padre Ejemplar"
        case .smartSaver: return "Ahorrador Inteligente"
        case .celebration: return "Celebración"
        case .homeSecure: return "Hogar Seguro"
        }
    }
    
    var description: String {
        switch self {
        case .goalCompleted: return "¡Has cumplido tu meta financiera!"
        case .goalCompletedOnTime: return "Cumpliste tu meta exactamente a tiempo"
        case .goalCompletedEarly: return "¡Cumpliste tu meta antes de lo esperado!"
        case .goalProgress25: return "Has completado el 25% de tu meta"
        case .goalProgress50: return "¡Ya vas por la mitad de tu meta!"
        case .goalProgress75: return "¡Estás muy cerca de cumplir tu meta!"
        case .goalStreak3: return "Has cumplido 3 metas consecutivas"
        case .goalStreak5: return "¡Increíble! 5 metas cumplidas seguidas"
        case .goalStreak10: return "¡Eres imparable! 10 metas cumplidas"
        case .superSaver: return "Tu capacidad de ahorro es excepcional"
        case .persistent: return "Tu constancia te ha llevado al éxito"
        case .precise: return "Cumpliste tu meta exactamente en la fecha"
        case .fatherExemplar: return "Eres un ejemplo para tu familia"
        case .smartSaver: return "Tu estrategia de ahorro es inteligente"
        case .celebration: return "¡Es hora de celebrar tus logros!"
        case .homeSecure: return "Has asegurado el futuro de tu hogar"
        }
    }
    
    var iconName: String {
        switch self {
        case .goalCompleted: return "trophy.fill"
        case .goalCompletedOnTime: return "clock.badge.checkmark.fill"
        case .goalCompletedEarly: return "rocket.fill"
        case .goalProgress25: return "chart.line.uptrend.xyaxis"
        case .goalProgress50: return "flame.fill"
        case .goalProgress75: return "diamond.fill"
        case .goalStreak3: return "star.fill"
        case .goalStreak5: return "star.circle.fill"
        case .goalStreak10: return "star.square.fill"
        case .superSaver: return "sparkles"
        case .persistent: return "hand.raised.fill"
        case .precise: return "target"
        case .fatherExemplar: return "person.2.fill"
        case .smartSaver: return "brain.head.profile"
        case .celebration: return "party.popper.fill"
        case .homeSecure: return "house.and.flag.fill"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .goalCompleted:
            return LinearGradient(colors: [.yellow, .orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalCompletedOnTime:
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalCompletedEarly:
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalProgress25:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalProgress50:
            return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalProgress75:
            return LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalStreak3:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalStreak5:
            return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .goalStreak10:
            return LinearGradient(colors: [.red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .superSaver:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .persistent:
            return LinearGradient(colors: [.brown, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .precise:
            return LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .fatherExemplar:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .smartSaver:
            return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .celebration:
            return LinearGradient(colors: [.pink, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .homeSecure:
            return LinearGradient(colors: [.brown, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .goalCompleted: return .yellow
        case .goalCompletedOnTime: return .green
        case .goalCompletedEarly: return .blue
        case .goalProgress25: return .blue
        case .goalProgress50: return .orange
        case .goalProgress75: return .cyan
        case .goalStreak3: return .yellow
        case .goalStreak5: return .orange
        case .goalStreak10: return .red
        case .superSaver: return .purple
        case .persistent: return .brown
        case .precise: return .green
        case .fatherExemplar: return .blue
        case .smartSaver: return .purple
        case .celebration: return .pink
        case .homeSecure: return .brown
        }
    }
}
