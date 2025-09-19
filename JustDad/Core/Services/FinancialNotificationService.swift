//
//  FinancialNotificationService.swift
//  JustDad - Financial Notifications Service
//
//  Professional notification system for budget alerts, spending reminders, and financial goals
//

import Foundation
import UserNotifications
import Combine

@MainActor
class FinancialNotificationService: NSObject, ObservableObject {
    static let shared = FinancialNotificationService()
    
    @Published var isEnabled: Bool = true
    @Published var budgetAlertsEnabled: Bool = true
    @Published var spendingRemindersEnabled: Bool = true
    @Published var goalRemindersEnabled: Bool = true
    @Published var weeklyReportsEnabled: Bool = true
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Notification Types
    enum FinancialNotificationType: String, CaseIterable {
        case budgetAlert = "BUDGET_ALERT"
        case spendingReminder = "SPENDING_REMINDER"
        case goalReminder = "GOAL_REMINDER"
        case weeklyReport = "WEEKLY_REPORT"
        case monthlySummary = "MONTHLY_SUMMARY"
        case overspendAlert = "OVERSPEND_ALERT"
        case savingsGoal = "SAVINGS_GOAL"
        case billReminder = "BILL_REMINDER"
        
        var displayName: String {
            switch self {
            case .budgetAlert: return "Alertas de Presupuesto"
            case .spendingReminder: return "Recordatorios de Gastos"
            case .goalReminder: return "Recordatorios de Metas"
            case .weeklyReport: return "Reportes Semanales"
            case .monthlySummary: return "Resúmenes Mensuales"
            case .overspendAlert: return "Alertas de Exceso"
            case .savingsGoal: return "Metas de Ahorro"
            case .billReminder: return "Recordatorios de Facturas"
            }
        }
        
        var icon: String {
            switch self {
            case .budgetAlert: return "exclamationmark.triangle.fill"
            case .spendingReminder: return "creditcard.fill"
            case .goalReminder: return "target"
            case .weeklyReport: return "chart.bar.fill"
            case .monthlySummary: return "calendar.badge.clock"
            case .overspendAlert: return "exclamationmark.octagon.fill"
            case .savingsGoal: return "banknote.fill"
            case .billReminder: return "doc.text.fill"
            }
        }
    }
    
    // MARK: - Alert Thresholds
    enum BudgetAlertThreshold: Double, CaseIterable {
        case warning = 0.75    // 75% of budget
        case critical = 0.90   // 90% of budget
        case exceeded = 1.0    // 100% of budget
        
        var displayName: String {
            switch self {
            case .warning: return "Advertencia (75%)"
            case .critical: return "Crítico (90%)"
            case .exceeded: return "Excedido (100%)"
            }
        }
        
        var color: String {
            switch self {
            case .warning: return "orange"
            case .critical: return "red"
            case .exceeded: return "purple"
            }
        }
    }
    
    override init() {
        super.init()
        setupNotificationCategories()
        loadUserPreferences()
    }
    
    // MARK: - Permission Management
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    // MARK: - User Preferences
    private func loadUserPreferences() {
        budgetAlertsEnabled = UserDefaults.standard.bool(forKey: "budgetAlertsEnabled")
        spendingRemindersEnabled = UserDefaults.standard.bool(forKey: "spendingRemindersEnabled")
        goalRemindersEnabled = UserDefaults.standard.bool(forKey: "goalRemindersEnabled")
        weeklyReportsEnabled = UserDefaults.standard.bool(forKey: "weeklyReportsEnabled")
    }
    
    func updatePreference(_ key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
        loadUserPreferences()
    }
    
    // MARK: - Budget Alerts
    func scheduleBudgetAlert(
        category: String,
        spent: Decimal,
        budget: Decimal,
        threshold: BudgetAlertThreshold
    ) {
        guard budgetAlertsEnabled else { return }
        
        let percentage = Double(truncating: (spent / budget) as NSNumber)
        let remaining = budget - spent
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Presupuesto \(threshold.displayName)"
        content.body = "Has gastado \(String(format: "%.1f", percentage * 100))% de tu presupuesto en \(category). Restante: $\(String(format: "%.2f", Double(truncating: remaining as NSNumber)))"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = FinancialNotificationType.budgetAlert.rawValue
        
        content.userInfo = [
            "type": FinancialNotificationType.budgetAlert.rawValue,
            "category": category,
            "spent": Double(truncating: spent as NSNumber),
            "budget": Double(truncating: budget as NSNumber),
            "percentage": percentage,
            "threshold": threshold.rawValue
        ]
        
        // Schedule immediately for budget alerts
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_alert_\(category)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule budget alert: \(error)")
            } else {
                print("✅ Scheduled budget alert for \(category)")
            }
        }
    }
    
    // MARK: - Spending Reminders
    func scheduleSpendingReminder() {
        guard spendingRemindersEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "💳 Recordatorio de Gastos"
        content.body = "¿Has registrado tus gastos de hoy? Mantén tu presupuesto actualizado."
        content.sound = .default
        content.categoryIdentifier = FinancialNotificationType.spendingReminder.rawValue
        
        content.userInfo = [
            "type": FinancialNotificationType.spendingReminder.rawValue,
            "date": Date().timeIntervalSince1970
        ]
        
        // Schedule for 8 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "spending_reminder_daily",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule spending reminder: \(error)")
            } else {
                print("✅ Scheduled daily spending reminder")
            }
        }
    }
    
    // MARK: - Weekly Reports
    func scheduleWeeklyReport() {
        guard weeklyReportsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📊 Resumen Semanal"
        content.body = "Revisa tu resumen financiero de esta semana y planifica la próxima."
        content.sound = .default
        content.categoryIdentifier = FinancialNotificationType.weeklyReport.rawValue
        
        content.userInfo = [
            "type": FinancialNotificationType.weeklyReport.rawValue,
            "week": Calendar.current.component(.weekOfYear, from: Date())
        ]
        
        // Schedule for Sunday at 9 AM
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weekly_report",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule weekly report: \(error)")
            } else {
                print("✅ Scheduled weekly report")
            }
        }
    }
    
    // MARK: - Monthly Summary
    func scheduleMonthlySummary() {
        let content = UNMutableNotificationContent()
        content.title = "📅 Resumen Mensual"
        content.body = "Revisa tu análisis financiero del mes y establece metas para el próximo."
        content.sound = .default
        content.categoryIdentifier = FinancialNotificationType.monthlySummary.rawValue
        
        content.userInfo = [
            "type": FinancialNotificationType.monthlySummary.rawValue,
            "month": Calendar.current.component(.month, from: Date())
        ]
        
        // Schedule for 1st of each month at 10 AM
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "monthly_summary",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule monthly summary: \(error)")
            } else {
                print("✅ Scheduled monthly summary")
            }
        }
    }
    
    // MARK: - Savings Goal Reminders
    func scheduleSavingsGoalReminder(goalName: String, currentAmount: Decimal, targetAmount: Decimal) {
        guard goalRemindersEnabled else { return }
        
        let percentage = Double(truncating: (currentAmount / targetAmount) as NSNumber)
        let remaining = targetAmount - currentAmount
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Meta de Ahorro: \(goalName)"
        content.body = "Progreso: \(String(format: "%.1f", percentage * 100))%. Faltan $\(String(format: "%.2f", Double(truncating: remaining as NSNumber)))"
        content.sound = .default
        content.categoryIdentifier = FinancialNotificationType.savingsGoal.rawValue
        
        content.userInfo = [
            "type": FinancialNotificationType.savingsGoal.rawValue,
            "goalName": goalName,
            "currentAmount": Double(truncating: currentAmount as NSNumber),
            "targetAmount": Double(truncating: targetAmount as NSNumber),
            "percentage": percentage
        ]
        
        // Schedule for every 3 days
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: true)
        let request = UNNotificationRequest(
            identifier: "savings_goal_\(goalName.replacingOccurrences(of: " ", with: "_"))",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule savings goal reminder: \(error)")
            } else {
                print("✅ Scheduled savings goal reminder for \(goalName)")
            }
        }
    }
    
    // MARK: - Bill Reminders
    func scheduleBillReminder(billName: String, dueDate: Date, amount: Decimal) {
        let content = UNMutableNotificationContent()
        content.title = "📄 Recordatorio de Factura"
        content.body = "\(billName) vence el \(dueDate.formatted(date: .abbreviated, time: .omitted)). Monto: $\(String(format: "%.2f", Double(truncating: amount as NSNumber)))"
        content.sound = .default
        content.categoryIdentifier = FinancialNotificationType.billReminder.rawValue
        
        content.userInfo = [
            "type": FinancialNotificationType.billReminder.rawValue,
            "billName": billName,
            "dueDate": dueDate.timeIntervalSince1970,
            "amount": Double(truncating: amount as NSNumber)
        ]
        
        // Schedule 3 days before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -3, to: dueDate) ?? dueDate
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "bill_reminder_\(billName.replacingOccurrences(of: " ", with: "_"))",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule bill reminder: \(error)")
            } else {
                print("✅ Scheduled bill reminder for \(billName)")
            }
        }
    }
    
    // MARK: - Notification Categories
    private func setupNotificationCategories() {
        let budgetAlertCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.budgetAlert.rawValue,
            actions: [
                UNNotificationAction(identifier: "VIEW_BUDGET", title: "Ver Presupuesto", options: [.foreground]),
                UNNotificationAction(identifier: "ADD_EXPENSE", title: "Agregar Gasto", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let spendingReminderCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.spendingReminder.rawValue,
            actions: [
                UNNotificationAction(identifier: "LOG_EXPENSE", title: "Registrar Gasto", options: [.foreground]),
                UNNotificationAction(identifier: "VIEW_FINANCE", title: "Ver Finanzas", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let goalReminderCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.goalReminder.rawValue,
            actions: [
                UNNotificationAction(identifier: "VIEW_GOALS", title: "Ver Metas", options: [.foreground]),
                UNNotificationAction(identifier: "UPDATE_PROGRESS", title: "Actualizar Progreso", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let weeklyReportCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.weeklyReport.rawValue,
            actions: [
                UNNotificationAction(identifier: "VIEW_REPORT", title: "Ver Reporte", options: [.foreground]),
                UNNotificationAction(identifier: "SHARE_REPORT", title: "Compartir", options: []),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let monthlySummaryCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.monthlySummary.rawValue,
            actions: [
                UNNotificationAction(identifier: "VIEW_ANALYTICS", title: "Ver Análisis", options: [.foreground]),
                UNNotificationAction(identifier: "SET_GOALS", title: "Establecer Metas", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let savingsGoalCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.savingsGoal.rawValue,
            actions: [
                UNNotificationAction(identifier: "VIEW_GOAL", title: "Ver Meta", options: [.foreground]),
                UNNotificationAction(identifier: "ADD_SAVINGS", title: "Agregar Ahorro", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let billReminderCategory = UNNotificationCategory(
            identifier: FinancialNotificationType.billReminder.rawValue,
            actions: [
                UNNotificationAction(identifier: "PAY_BILL", title: "Pagar Factura", options: [.foreground]),
                UNNotificationAction(identifier: "VIEW_BILLS", title: "Ver Facturas", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Descartar", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            budgetAlertCategory,
            spendingReminderCategory,
            goalReminderCategory,
            weeklyReportCategory,
            monthlySummaryCategory,
            savingsGoalCategory,
            billReminderCategory
        ])
    }
    
    // MARK: - Cleanup
    func cancelAllFinancialNotifications() {
        let identifiers = FinancialNotificationType.allCases.map { $0.rawValue }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelNotificationType(_ type: FinancialNotificationType) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [type.rawValue])
    }
    
    // MARK: - Debug
    func getPendingFinancialNotifications() async -> [UNNotificationRequest] {
        let allPending = await notificationCenter.pendingNotificationRequests()
        return allPending.filter { request in
            FinancialNotificationType.allCases.contains { $0.rawValue == request.content.categoryIdentifier }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension FinancialNotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "VIEW_BUDGET", "VIEW_FINANCE", "VIEW_ANALYTICS":
            // Navigate to finance view
            NotificationCenter.default.post(name: .navigateToFinance, object: nil)
            
        case "ADD_EXPENSE", "LOG_EXPENSE":
            // Navigate to add expense
            NotificationCenter.default.post(name: .navigateToAddExpense, object: nil)
            
        case "VIEW_GOALS", "SET_GOALS":
            // Navigate to goals view
            NotificationCenter.default.post(name: .navigateToGoals, object: nil)
            
        case "VIEW_REPORT", "SHARE_REPORT":
            // Navigate to reports view
            NotificationCenter.default.post(name: .navigateToReports, object: nil)
            
        case "ADD_SAVINGS", "UPDATE_PROGRESS":
            // Navigate to savings view
            NotificationCenter.default.post(name: .navigateToSavings, object: nil)
            
        case "PAY_BILL", "VIEW_BILLS":
            // Navigate to bills view
            NotificationCenter.default.post(name: .navigateToBills, object: nil)
            
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToFinance = Notification.Name("navigateToFinance")
    static let navigateToAddExpense = Notification.Name("navigateToAddExpense")
    static let navigateToGoals = Notification.Name("navigateToGoals")
    static let navigateToReports = Notification.Name("navigateToReports")
    static let navigateToSavings = Notification.Name("navigateToSavings")
    static let navigateToBills = Notification.Name("navigateToBills")
}
