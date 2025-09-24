//
//  HomeViewModel.swift
//  JustDad - Home Dashboard ViewModel
//
//  Manages home screen data, navigation, and business logic
//

import SwiftUI
import Combine
import Foundation

// Import required types from the project
// These types are defined in other files in the project

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Navigation
    private let selectedTab: Binding<MainTabView.Tab>
    
    // MARK: - Published Properties
    @Published var currentTime = Date()
    @Published var username = "Jorge" // TODO: Get from UserDefaults or Profile
    @Published var isRefreshing = false
    @Published var todaysTasks: [String] = []
    @Published var todaysVisits: [AgendaVisit] = []
    @Published var recentActivities: [ActivityItem] = []
    @Published var dashboardStats = DashboardStats()
    @Published var todaysOverview = TodaysOverview()
    
    // MARK: - Services
    private let agendaRepository: AgendaRepositoryProtocol
    private let persistenceService: PersistenceService
    private let journalingService: IntelligentJournalingService
    private let userService: UserServiceProtocol
    
    // MARK: - Timers
    private var timeTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        selectedTab: Binding<MainTabView.Tab>,
        agendaRepository: AgendaRepositoryProtocol? = nil,
        persistenceService: PersistenceService? = nil,
        journalingService: IntelligentJournalingService? = nil,
        userService: UserServiceProtocol = UserService.shared
    ) {
        self.selectedTab = selectedTab
        self.agendaRepository = agendaRepository ?? InMemoryAgendaRepository()
        self.persistenceService = persistenceService ?? PersistenceService.shared
        self.journalingService = journalingService ?? IntelligentJournalingService.shared
        self.userService = userService
        
        setupTimeTimer()
        loadInitialData()
    }
    
    deinit {
        timeTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    func refreshData() async {
        isRefreshing = true
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTodaysVisits() }
            group.addTask { await self.loadDashboardStats() }
            group.addTask { await self.loadRecentActivities() }
            group.addTask { await self.loadTodaysOverview() }
            group.addTask { await self.loadUserProfile() }
        }
        
        isRefreshing = false
    }
    
    func onAppear() {
        Task {
            await refreshData()
        }
    }
    
    func navigateToAgenda() {
        selectedTab.wrappedValue = .agenda
    }
    
    func navigateToFinance() {
        selectedTab.wrappedValue = .finance
    }
    
    func navigateToEmotions() {
        selectedTab.wrappedValue = .emotions
    }
    
    func navigateToCommunity() {
        selectedTab.wrappedValue = .community
    }
    
    func openSOS() {
        // TODO: Implement SOS functionality
        print("Opening SOS")
    }
    
    func addNewVisit() {
        selectedTab.wrappedValue = .agenda
        // TODO: Also trigger navigation to new visit form within agenda
    }
    
    func addNewExpense() {
        selectedTab.wrappedValue = .finance
        // TODO: Also trigger navigation to new expense form within finance
    }
    
    func writeJournalEntry() {
        selectedTab.wrappedValue = .emotions
        // TODO: Also trigger navigation to journal entry within emotions
    }
    
    // MARK: - Private Methods
    private func setupTimeTimer() {
        timeTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = Date()
            }
        }
    }
    
    private func loadInitialData() {
        Task {
            await refreshData()
        }
    }
    
    private func loadTodaysVisits() async {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        let dateRange = DateInterval(start: today, end: tomorrow)
        
        do {
            todaysVisits = try await agendaRepository.getVisits(in: dateRange)
            
            // Update tasks based on visits
            todaysTasks = todaysVisits.map { visit in
                "\(visit.title) - \(visit.startDate.formatted(date: .omitted, time: .shortened))"
            }
        } catch {
            print("❌ Error loading today's visits: \(error)")
            todaysVisits = []
            todaysTasks = []
        }
    }
    
    private func loadDashboardStats() async {
        let calendar = Calendar.current
        let now = Date()
        
        do {
            // Load visits this week
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let weekEnd = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            let weekRange = DateInterval(start: weekStart, end: weekEnd)
            let thisWeekVisits = try await agendaRepository.getVisits(in: weekRange)
            
            // Load monthly expenses
            let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let monthEnd = calendar.dateInterval(of: .month, for: now)?.end ?? now
            let monthlyExpenses = try persistenceService.fetch(FinancialEntry.self)
            let filteredMonthlyExpenses = monthlyExpenses.filter { expense in
                expense.date >= monthStart && expense.date <= monthEnd
            }
            let totalMonthlyExpenses = filteredMonthlyExpenses.reduce(0) { $0 + $1.amount }
            
            // Load quality time (approximate based on visit durations)
            let totalQualityTime = thisWeekVisits.reduce(0) { total, visit in
                total + visit.endDate.timeIntervalSince(visit.startDate) / 3600 // Convert to hours
            }
            
            dashboardStats = DashboardStats(
                visitsThisWeek: thisWeekVisits.count,
                monthlyExpenses: Double(truncating: totalMonthlyExpenses as NSNumber),
                qualityTimeHours: Int(totalQualityTime),
                activitiesThisWeek: thisWeekVisits.filter { $0.visitType == .activity }.count
            )
        } catch {
            print("❌ Error loading dashboard stats: \(error)")
            dashboardStats = DashboardStats()
        }
    }
    
    private func loadRecentActivities() async {
        // Load recent activities from all services
        var activities: [ActivityItem] = []
        
        do {
            // Recent visits - get all visits and take the most recent
            let allVisits = try await agendaRepository.getVisits(in: DateInterval(start: Date().addingTimeInterval(-30*24*60*60), end: Date()))
            let recentVisits = Array(allVisits.sorted { $0.startDate > $1.startDate }.prefix(3))
            activities.append(contentsOf: recentVisits.map { visit in
                ActivityItem(
                    id: visit.id.uuidString,
                    type: .visit,
                    title: "Visita programada",
                    subtitle: visit.title,
                    timestamp: visit.startDate,
                    icon: "calendar.circle.fill",
                    color: .blue
                )
            })
            
            // Recent expenses
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            let recentExpenses = Array(allExpenses.sorted { $0.date > $1.date }.prefix(2))
            activities.append(contentsOf: recentExpenses.map { expense in
                ActivityItem(
                    id: expense.id.uuidString,
                    type: .expense,
                    title: "Gasto registrado",
                    subtitle: "\(expense.category.displayName) - $\(expense.amount)",
                    timestamp: expense.date,
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
            })
            
            // Recent emotions from journaling service
            let recentEmotions = Array(journalingService.emotionEntries.prefix(2))
            activities.append(contentsOf: recentEmotions.map { emotion in
                ActivityItem(
                    id: emotion.id.uuidString,
                    type: .emotion,
                    title: "Estado emocional actualizado",
                    subtitle: emotion.emotion.displayName,
                    timestamp: emotion.timestamp,
                    icon: "heart.circle.fill",
                    color: .pink
                )
            })
            
            // Recent journal entries
            let recentJournalEntries = Array(journalingService.journalEntries.prefix(2))
            activities.append(contentsOf: recentJournalEntries.map { entry in
                ActivityItem(
                    id: entry.id.uuidString,
                    type: .journal,
                    title: "Entrada de diario",
                    subtitle: entry.prompt.text,
                    timestamp: entry.date,
                    icon: "book.circle.fill",
                    color: .purple
                )
            })
            
            // Sort by timestamp and take most recent
            recentActivities = activities
                .sorted { $0.timestamp > $1.timestamp }
                .prefix(5)
                .map { $0 }
        } catch {
            print("❌ Error loading recent activities: \(error)")
            recentActivities = []
        }
    }
    
    private func loadTodaysOverview() async {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        
        do {
            // Count today's visits
            let todaysVisitCount = todaysVisits.count
            
            // Get today's expenses
            let allExpenses = try persistenceService.fetch(FinancialEntry.self)
            let todaysExpenses = allExpenses.filter { expense in
                expense.date >= today && expense.date < tomorrow
            }
            let totalTodaysExpenses = todaysExpenses.reduce(0) { $0 + $1.amount }
            
            // Get current mood (most recent emotion entry)
            let currentMood = journalingService.emotionEntries.first?.emotion
            
            todaysOverview = TodaysOverview(
                pendingTasks: todaysVisitCount,
                nextAppointment: todaysVisits.first?.startDate,
                currentMood: currentMood,
                todaysExpenses: Double(truncating: totalTodaysExpenses as NSNumber)
            )
        } catch {
            print("❌ Error loading today's overview: \(error)")
            todaysOverview = TodaysOverview()
        }
    }
    
    private func loadUserProfile() async {
        // TODO: Load user profile data
        username = await userService.getCurrentUsername() ?? "Usuario"
    }
    
    // MARK: - Computed Properties
    var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: currentTime)
        switch hour {
        case 5..<12: return "Buenos días"
        case 12..<18: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }
    
    var nextAppointmentText: String {
        guard let nextAppointment = todaysOverview.nextAppointment else {
            return "Sin citas hoy"
        }
        
        let timeInterval = nextAppointment.timeIntervalSince(Date())
        if timeInterval < 0 {
            return "Cita pasada"
        } else if timeInterval < 3600 { // Less than 1 hour
            let minutes = Int(timeInterval / 60)
            return "En \(minutes) min"
        } else {
            let hours = Int(timeInterval / 3600)
            return "En \(hours)h"
        }
    }
    
    var hasPendingTasks: Bool {
        !todaysTasks.isEmpty
    }
    
    var hasUpcomingAppointments: Bool {
        todaysOverview.nextAppointment != nil
    }
}

// MARK: - Supporting Data Models
struct DashboardStats {
    let visitsThisWeek: Int
    let monthlyExpenses: Double
    let qualityTimeHours: Int
    let activitiesThisWeek: Int
    
    init(
        visitsThisWeek: Int = 0,
        monthlyExpenses: Double = 0,
        qualityTimeHours: Int = 0,
        activitiesThisWeek: Int = 0
    ) {
        self.visitsThisWeek = visitsThisWeek
        self.monthlyExpenses = monthlyExpenses
        self.qualityTimeHours = qualityTimeHours
        self.activitiesThisWeek = activitiesThisWeek
    }
}

struct TodaysOverview {
    let pendingTasks: Int
    let nextAppointment: Date?
    let currentMood: EmotionalState?
    let todaysExpenses: Double
    
    init(
        pendingTasks: Int = 0,
        nextAppointment: Date? = nil,
        currentMood: EmotionalState? = nil,
        todaysExpenses: Double = 0
    ) {
        self.pendingTasks = pendingTasks
        self.nextAppointment = nextAppointment
        self.currentMood = currentMood
        self.todaysExpenses = todaysExpenses
    }
}

struct ActivityItem: Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let subtitle: String
    let timestamp: Date
    let icon: String
    let color: Color
}

enum ActivityType {
    case visit
    case expense
    case emotion
    case journal
}

// MARK: - Service Protocols
protocol UserServiceProtocol {
    func getCurrentUsername() async -> String?
}

// MARK: - User Service Implementation
class UserService: UserServiceProtocol {
    static let shared = UserService()
    
    func getCurrentUsername() async -> String? {
        // TODO: Implement real data loading
        return "Jorge"
    }
}

// MARK: - Supporting Types (Using existing models from the project)
// Using types from:
// - Visit, AgendaVisitType from Core/Models/AgendaTypes.swift and Core/Models/CoreDataModels.swift
// - FinancialEntry, ExpenseCategory from Core/Models/CoreDataModels.swift
// - EmotionalEntry, EmotionalState from Features/Emotions/EmotionModels.swift and Core/Models/CoreDataModels.swift

// Type aliases for clarity (using existing types)
// AgendaVisit already exists in Core/Models/AgendaTypes.swift
// EmotionEntry already exists in Features/Emotions/EmotionModels.swift
typealias Expense = FinancialEntry
typealias ExpenseCategory = FinancialEntry.ExpenseCategory
