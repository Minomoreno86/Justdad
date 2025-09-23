//
//  AmarresMetricsService.swift
//  JustDad - Servicio de Métricas para Corte de Amarres o Brujería
//
//  Maneja estadísticas, puntos, logros y seguimiento del progreso
//

import Foundation
import SwiftUI

// MARK: - Servicio de Métricas
public class AmarresMetricsService: ObservableObject {
    public static let shared = AmarresMetricsService()
    
    @Published public var stats: AmarresStats = AmarresStats()
    @Published public var points: AmarresPoints = AmarresPoints()
    @Published public var achievements: [AmarresAchievement] = []
    @Published public var protectionStreak: ProtectionStreak = ProtectionStreak()
    
    private let userDefaults = UserDefaults.standard
    private let statsKey = "amarres_stats"
    private let pointsKey = "amarres_points"
    private let achievementsKey = "amarres_achievements"
    private let streakKey = "amarres_protection_streak"
    
    private init() {
        loadUserData()
        setupDefaultAchievements()
    }
    
    // MARK: - Gestión de Sesiones
    
    public func recordCompletedSession(_ session: AmarresSession) {
        stats.totalSessions += 1
        stats.completedSessions += 1
        stats.lastSessionDate = session.endTime ?? Date()
        
        // Actualizar contadores específicos
        if let intensityAfter = session.intensityAfter {
            let intensityReduction = session.intensityBefore.numericValue - intensityAfter.numericValue
            if intensityReduction > 0 {
                stats.bindingsBroken += 1
                updateAverageIntensityReduction(intensityReduction)
            }
        }
        
        // Actualizar enfoque favorito
        updateFavoriteApproach(session.approach)
        
        // Actualizar tipo de amarre más común
        if let bindingType = session.bindingType {
            updateMostCommonBindingType(bindingType)
        }
        
        // Calcular puntos
        calculateSessionPoints(session)
        
        // Actualizar racha
        updateProtectionStreak()
        
        // Verificar logros
        _ = checkAchievements()
        
        // Guardar datos
        saveUserData()
        
        print("📊 Sesión registrada - Total: \(stats.totalSessions), Completadas: \(stats.completedSessions)")
    }
    
    public func recordAbandonedSession(_ session: AmarresSession) {
        stats.totalSessions += 1
        stats.lastSessionDate = session.endTime ?? Date()
        
        // Romper racha si estaba activa
        if protectionStreak.isActive {
            protectionStreak.streakBroken = true
        }
        
        saveUserData()
        
        print("📊 Sesión abandonada registrada")
    }
    
    // MARK: - Cálculo de Puntos
    
    private func calculateSessionPoints(_ session: AmarresSession) {
        var earnedPoints = 0
        
        // Puntos base por completar sesión
        earnedPoints += 50
        points.addPoints(50, type: .liberation)
        
        // Puntos por intensidad reducida
        if let intensityAfter = session.intensityAfter {
            let intensityReduction = session.intensityBefore.numericValue - intensityAfter.numericValue
            if intensityReduction > 0 {
                let bonusPoints = intensityReduction * 10
                earnedPoints += bonusPoints
                points.addPoints(bonusPoints, type: .liberation)
            }
        }
        
        // Puntos por síntomas identificados
        let symptomPoints = session.symptoms.count * 5
        earnedPoints += symptomPoints
        points.addPoints(symptomPoints, type: .cleansing)
        
        // Puntos por amarres identificados
        let bindingPoints = session.identifiedBindings.count * 15
        earnedPoints += bindingPoints
        points.addPoints(bindingPoints, type: .liberation)
        
        // Puntos por elementos de limpieza
        let cleansingPoints = session.cleansingElements.count * 5
        earnedPoints += cleansingPoints
        points.addPoints(cleansingPoints, type: .cleansing)
        
        // Puntos por voto de protección
        if !session.protectionVow.isEmpty {
            earnedPoints += 25
            points.addPoints(25, type: .protection)
        }
        
        // Puntos por enfoque específico
        let approachPoints = getApproachBonusPoints(session.approach)
        earnedPoints += approachPoints
        points.addPoints(approachPoints, type: .mastery)
        
        print("💰 Puntos ganados en sesión: \(earnedPoints)")
    }
    
    private func getApproachBonusPoints(_ approach: AmarresApproach) -> Int {
        switch approach {
        case .secular: return 10
        case .spiritual: return 15
        case .traditional: return 20
        }
    }
    
    // MARK: - Actualización de Estadísticas
    
    private func updateAverageIntensityReduction(_ reduction: Int) {
        let totalSessions = stats.completedSessions
        let currentAverage = stats.averageIntensityReduction
        let newAverage = ((currentAverage * Double(totalSessions - 1)) + Double(reduction)) / Double(totalSessions)
        stats.averageIntensityReduction = newAverage
    }
    
    private func updateFavoriteApproach(_ approach: AmarresApproach) {
        // Lógica simple: el enfoque más usado se convierte en favorito
        // En una implementación más compleja, se podría usar un contador
        stats.favoriteApproach = approach
    }
    
    private func updateMostCommonBindingType(_ bindingType: AmarresType) {
        // Lógica simple: el tipo más usado se convierte en el más común
        // En una implementación más compleja, se podría usar un contador
        stats.mostCommonBindingType = bindingType
    }
    
    private func updateProtectionStreak() {
        let today = Date()
        
        if protectionStreak.lastProtectionDate == nil {
            // Primera vez
            protectionStreak.currentStreak = 1
            protectionStreak.longestStreak = 1
        } else if let lastDate = protectionStreak.lastProtectionDate {
            let daysBetween = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if daysBetween == 1 {
                // Día consecutivo
                protectionStreak.currentStreak += 1
                protectionStreak.longestStreak = max(protectionStreak.longestStreak, protectionStreak.currentStreak)
            } else if daysBetween > 1 {
                // Racha rota
                protectionStreak.currentStreak = 1
                protectionStreak.streakBroken = true
            }
            // Si daysBetween == 0, es el mismo día, no hacer nada
        }
        
        protectionStreak.lastProtectionDate = today
        protectionStreak.streakBroken = false
        
        // Actualizar estadísticas
        stats.currentStreak = protectionStreak.currentStreak
        stats.longestStreak = protectionStreak.longestStreak
        stats.protectionDays = protectionStreak.currentStreak
    }
    
    // MARK: - Verificación de Logros
    
    public func checkAchievements() -> [AmarresAchievement] {
        var newAchievements: [AmarresAchievement] = []
        
        for achievement in achievements {
            if !achievement.isUnlocked && isRequirementMet(achievement.requirement) {
                var unlockedAchievement = achievement
                unlockedAchievement = AmarresAchievement(
                    title: achievement.title,
                    description: achievement.description,
                    icon: achievement.icon,
                    color: achievement.color,
                    requirement: achievement.requirement,
                    reward: achievement.reward,
                    isUnlocked: true,
                    unlockedDate: Date()
                )
                
                newAchievements.append(unlockedAchievement)
                
                // Actualizar en la lista principal
                if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
                    achievements[index] = unlockedAchievement
                }
                
                // Otorgar recompensa
                points.addPoints(achievement.reward.points, type: achievement.reward.pointsType)
                
                print("🏆 Logro desbloqueado: \(achievement.title)")
            }
        }
        
        return newAchievements
    }
    
    private func isRequirementMet(_ requirement: AchievementRequirement) -> Bool {
        switch requirement {
        case .sessionsCompleted(let count):
            return stats.completedSessions >= count
        case .bindingsBroken(let count):
            return stats.bindingsBroken >= count
        case .protectionDays(let days):
            return stats.protectionDays >= days
        case .streakDays(let days):
            return stats.currentStreak >= days
        case .levelReached(let level):
            return points.currentLevel == level
        case .pointsEarned(let points, let type):
            switch type {
            case .cleansing:
                return self.points.cleansingPoints >= points
            case .protection:
                return self.points.protectionPoints >= points
            case .liberation:
                return self.points.liberationPoints >= points
            case .mastery:
                return self.points.masteryPoints >= points
            }
        case .approachUsed(_):
            return true // Se asume que se ha usado si se está verificando
        case .bindingTypeBroken(_):
            return true // Se asume que se ha roto si se está verificando
        }
    }
    
    // MARK: - Persistencia de Datos
    
    private func loadUserData() {
        // Cargar estadísticas
        if let statsData = userDefaults.data(forKey: statsKey),
           let loadedStats = try? JSONDecoder().decode(AmarresStats.self, from: statsData) {
            stats = loadedStats
        }
        
        // Cargar puntos
        if let pointsData = userDefaults.data(forKey: pointsKey),
           let loadedPoints = try? JSONDecoder().decode(AmarresPoints.self, from: pointsData) {
            points = loadedPoints
        }
        
        // Cargar logros
        if let achievementsData = userDefaults.data(forKey: achievementsKey),
           let loadedAchievements = try? JSONDecoder().decode([AmarresAchievement].self, from: achievementsData) {
            achievements = loadedAchievements
        }
        
        // Cargar racha de protección
        if let streakData = userDefaults.data(forKey: streakKey),
           let loadedStreak = try? JSONDecoder().decode(ProtectionStreak.self, from: streakData) {
            protectionStreak = loadedStreak
        }
    }
    
    private func saveUserData() {
        // Guardar estadísticas
        if let statsData = try? JSONEncoder().encode(stats) {
            userDefaults.set(statsData, forKey: statsKey)
        }
        
        // Guardar puntos
        if let pointsData = try? JSONEncoder().encode(points) {
            userDefaults.set(pointsData, forKey: pointsKey)
        }
        
        // Guardar logros
        if let achievementsData = try? JSONEncoder().encode(achievements) {
            userDefaults.set(achievementsData, forKey: achievementsKey)
        }
        
        // Guardar racha de protección
        if let streakData = try? JSONEncoder().encode(protectionStreak) {
            userDefaults.set(streakData, forKey: streakKey)
        }
    }
    
    // MARK: - Configuración de Logros por Defecto
    
    private func setupDefaultAchievements() {
        if achievements.isEmpty {
            achievements = createDefaultAchievements()
        }
    }
    
    private func createDefaultAchievements() -> [AmarresAchievement] {
        return [
            // Logros de Sesiones
            AmarresAchievement(
                title: "Primer Paso",
                description: "Completa tu primera sesión de liberación",
                icon: "star.fill",
                color: "gold",
                requirement: .sessionsCompleted(1),
                reward: AchievementReward(points: 50, pointsType: .liberation, title: "Primer Paso", description: "¡Bienvenido al camino de la liberación!")
            ),
            
            AmarresAchievement(
                title: "Aprendiz de la Luz",
                description: "Completa 5 sesiones de liberación",
                icon: "star.circle.fill",
                color: "silver",
                requirement: .sessionsCompleted(5),
                reward: AchievementReward(points: 100, pointsType: .liberation, title: "Aprendiz de la Luz", description: "¡Estás progresando en tu camino!")
            ),
            
            AmarresAchievement(
                title: "Practicante Consciente",
                description: "Completa 10 sesiones de liberación",
                icon: "star.circle.fill",
                color: "bronze",
                requirement: .sessionsCompleted(10),
                reward: AchievementReward(points: 200, pointsType: .liberation, title: "Practicante Consciente", description: "¡Tu dedicación es admirable!")
            ),
            
            // Logros de Amarres Rotos
            AmarresAchievement(
                title: "Rompe-Amarras",
                description: "Rompe 5 amarres exitosamente",
                icon: "scissors",
                color: "purple",
                requirement: .bindingsBroken(5),
                reward: AchievementReward(points: 150, pointsType: .liberation, title: "Rompe-Amarras", description: "¡Eres experto en romper vínculos tóxicos!")
            ),
            
            AmarresAchievement(
                title: "Maestro Rompe-Amarras",
                description: "Rompe 25 amarres exitosamente",
                icon: "scissors.circle.fill",
                color: "purple",
                requirement: .bindingsBroken(25),
                reward: AchievementReward(points: 500, pointsType: .liberation, title: "Maestro Rompe-Amarras", description: "¡Eres un verdadero maestro de la liberación!")
            ),
            
            // Logros de Protección
            AmarresAchievement(
                title: "Guardián Energético",
                description: "Mantén protección activa por 7 días",
                icon: "shield.fill",
                color: "blue",
                requirement: .protectionDays(7),
                reward: AchievementReward(points: 100, pointsType: .protection, title: "Guardián Energético", description: "¡Tu campo energético está protegido!")
            ),
            
            AmarresAchievement(
                title: "Protector de la Luz",
                description: "Mantén protección activa por 30 días",
                icon: "shield.checkered",
                color: "blue",
                requirement: .protectionDays(30),
                reward: AchievementReward(points: 300, pointsType: .protection, title: "Protector de la Luz", description: "¡Tu protección es inquebrantable!")
            ),
            
            // Logros de Racha
            AmarresAchievement(
                title: "Racha de Protección",
                description: "Mantén una racha de 14 días",
                icon: "flame.fill",
                color: "orange",
                requirement: .streakDays(14),
                reward: AchievementReward(points: 200, pointsType: .protection, title: "Racha de Protección", description: "¡Tu consistencia es admirable!")
            ),
            
            AmarresAchievement(
                title: "Maestro de la Consistencia",
                description: "Mantén una racha de 100 días",
                icon: "flame.circle.fill",
                color: "red",
                requirement: .streakDays(100),
                reward: AchievementReward(points: 1000, pointsType: .mastery, title: "Maestro de la Consistencia", description: "¡Tu disciplina es legendaria!")
            ),
            
            // Logros de Nivel
            AmarresAchievement(
                title: "Aprendiz Energético",
                description: "Alcanza el nivel Aprendiz",
                icon: "star.circle.fill",
                color: "blue",
                requirement: .levelReached(.apprentice),
                reward: AchievementReward(points: 100, pointsType: .mastery, title: "Aprendiz Energético", description: "¡Has subido de nivel!")
            ),
            
            AmarresAchievement(
                title: "Guardián de la Luz",
                description: "Alcanza el nivel Guardián",
                icon: "shield.fill",
                color: "green",
                requirement: .levelReached(.guardian),
                reward: AchievementReward(points: 200, pointsType: .mastery, title: "Guardián de la Luz", description: "¡Tu poder protector crece!")
            ),
            
            AmarresAchievement(
                title: "Maestro de la Luz",
                description: "Alcanza el nivel Maestro",
                icon: "crown.fill",
                color: "yellow",
                requirement: .levelReached(.master),
                reward: AchievementReward(points: 500, pointsType: .mastery, title: "Maestro de la Luz", description: "¡Has alcanzado la maestría!")
            ),
            
            AmarresAchievement(
                title: "Gran Maestro Energético",
                description: "Alcanza el nivel Gran Maestro",
                icon: "crown.circle.fill",
                color: "gold",
                requirement: .levelReached(.grandmaster),
                reward: AchievementReward(points: 1000, pointsType: .mastery, title: "Gran Maestro Energético", description: "¡Eres un verdadero maestro de la energía!")
            ),
            
            // Logros de Puntos
            AmarresAchievement(
                title: "Limpiador Experto",
                description: "Gana 500 puntos de limpieza",
                icon: "drop.fill",
                color: "cyan",
                requirement: .pointsEarned(500, .cleansing),
                reward: AchievementReward(points: 100, pointsType: .cleansing, title: "Limpiador Experto", description: "¡Eres un experto en limpieza energética!")
            ),
            
            AmarresAchievement(
                title: "Protector Nato",
                description: "Gana 500 puntos de protección",
                icon: "shield.fill",
                color: "blue",
                requirement: .pointsEarned(500, .protection),
                reward: AchievementReward(points: 100, pointsType: .protection, title: "Protector Nato", description: "¡Tu instinto protector es natural!")
            ),
            
            AmarresAchievement(
                title: "Liberador de Almas",
                description: "Gana 1000 puntos de liberación",
                icon: "scissors",
                color: "purple",
                requirement: .pointsEarned(1000, .liberation),
                reward: AchievementReward(points: 200, pointsType: .liberation, title: "Liberador de Almas", description: "¡Eres un verdadero liberador de almas!")
            ),
            
            AmarresAchievement(
                title: "Maestro de la Maestría",
                description: "Gana 500 puntos de maestría",
                icon: "crown.fill",
                color: "yellow",
                requirement: .pointsEarned(500, .mastery),
                reward: AchievementReward(points: 100, pointsType: .mastery, title: "Maestro de la Maestría", description: "¡Tu maestría es evidente!")
            )
        ]
    }
    
    // MARK: - Métodos de Consulta
    
    public func getProgressToNextLevel() -> Double {
        let currentLevelPoints = points.currentLevel.requiredPoints
        let nextLevelPoints = points.currentLevel.nextLevelPoints
        let progress = Double(points.totalPoints - currentLevelPoints) / Double(nextLevelPoints - currentLevelPoints)
        return min(max(progress, 0.0), 1.0)
    }
    
    public func getPointsToNextLevel() -> Int {
        return points.pointsToNextLevel
    }
    
    public func getUnlockedAchievements() -> [AmarresAchievement] {
        return achievements.filter { $0.isUnlocked }
    }
    
    public func getLockedAchievements() -> [AmarresAchievement] {
        return achievements.filter { !$0.isUnlocked }
    }
    
    public func getAchievementProgress(_ achievement: AmarresAchievement) -> Double {
        switch achievement.requirement {
        case .sessionsCompleted(let count):
            return min(Double(stats.completedSessions) / Double(count), 1.0)
        case .bindingsBroken(let count):
            return min(Double(stats.bindingsBroken) / Double(count), 1.0)
        case .protectionDays(let days):
            return min(Double(stats.protectionDays) / Double(days), 1.0)
        case .streakDays(let days):
            return min(Double(stats.currentStreak) / Double(days), 1.0)
        case .levelReached(let level):
            return points.currentLevel.requiredPoints >= level.requiredPoints ? 1.0 : 0.0
        case .pointsEarned(let points, let type):
            let currentPoints = getPointsForType(type)
            return min(Double(currentPoints) / Double(points), 1.0)
        case .approachUsed(_), .bindingTypeBroken(_):
            return 1.0 // Se asume completado si se está verificando
        }
    }
    
    private func getPointsForType(_ type: PointsType) -> Int {
        switch type {
        case .cleansing:
            return points.cleansingPoints
        case .protection:
            return points.protectionPoints
        case .liberation:
            return points.liberationPoints
        case .mastery:
            return points.masteryPoints
        }
    }
    
    // MARK: - Reset de Datos
    
    public func resetAllData() {
        stats = AmarresStats()
        points = AmarresPoints()
        achievements = createDefaultAchievements()
        protectionStreak = ProtectionStreak()
        saveUserData()
        print("🔄 Todos los datos han sido reseteados")
    }
    
    public func resetStatsOnly() {
        stats = AmarresStats()
        saveUserData()
        print("🔄 Solo las estadísticas han sido reseteadas")
    }
}
