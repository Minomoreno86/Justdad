//
//  FinancialNotificationSettingsView.swift
//  JustDad - Financial Notification Settings
//
//  Professional settings view for configuring financial notifications and alerts
//

import SwiftUI

struct FinancialNotificationSettingsView: View {
    @ObservedObject private var notificationService = FinancialNotificationService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingPermissionAlert = false
    @State private var permissionAlertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Notification Types
                    notificationTypesSection
                    
                    // Budget Alerts
                    budgetAlertsSection
                    
                    // Reminder Times
                    reminderTimesSection
                    
                    // Test Notifications
                    testNotificationsSection
                    
                    // Debug Info
                    debugSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Notificaciones Financieras")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Permisos") {
                        requestNotificationPermission()
                    }
                }
            }
        }
        .alert("Permisos de Notificación", isPresented: $showingPermissionAlert) {
            Button("Configurar") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text(permissionAlertMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Notificaciones Inteligentes")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Mantén el control de tus finanzas con alertas personalizadas y recordatorios inteligentes.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Notification Types Section
    private var notificationTypesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tipos de Notificaciones")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(FinancialNotificationService.FinancialNotificationType.allCases, id: \.self) { type in
                NotificationTypeRow(
                    type: type,
                    isEnabled: isNotificationTypeEnabled(type)
                ) { enabled in
                    toggleNotificationType(type, enabled: enabled)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Budget Alerts Section
    private var budgetAlertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Alertas de Presupuesto")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(FinancialNotificationService.BudgetAlertThreshold.allCases, id: \.self) { threshold in
                    BudgetThresholdRow(threshold: threshold)
                }
            }
            
            Text("Recibirás alertas cuando alcances estos porcentajes de tu presupuesto mensual.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Reminder Times Section
    private var reminderTimesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Horarios de Recordatorios")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ReminderTimeRow(
                    title: "Recordatorio Diario",
                    subtitle: "Registra tus gastos",
                    time: "8:00 PM",
                    icon: "creditcard.fill"
                )
                
                ReminderTimeRow(
                    title: "Resumen Semanal",
                    subtitle: "Revisa tu progreso",
                    time: "Domingo 9:00 AM",
                    icon: "chart.bar.fill"
                )
                
                ReminderTimeRow(
                    title: "Resumen Mensual",
                    subtitle: "Análisis completo",
                    time: "1er día 10:00 AM",
                    icon: "calendar.badge.clock"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Test Notifications Section
    private var testNotificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Probar Notificaciones")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Button("Probar Alerta de Presupuesto") {
                    testBudgetAlert()
                }
                .buttonStyle(TestNotificationButtonStyle())
                
                Button("Probar Recordatorio de Gastos") {
                    testSpendingReminder()
                }
                .buttonStyle(TestNotificationButtonStyle())
                
                Button("Probar Resumen Semanal") {
                    testWeeklyReport()
                }
                .buttonStyle(TestNotificationButtonStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Debug Section
    private var debugSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Información de Debug")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Estado: \(notificationService.isEnabled ? "Habilitado" : "Deshabilitado")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Alertas de Presupuesto: \(notificationService.budgetAlertsEnabled ? "Sí" : "No")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Recordatorios de Gastos: \(notificationService.spendingRemindersEnabled ? "Sí" : "No")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Helper Methods
    private func isNotificationTypeEnabled(_ type: FinancialNotificationService.FinancialNotificationType) -> Bool {
        switch type {
        case .budgetAlert: return notificationService.budgetAlertsEnabled
        case .spendingReminder: return notificationService.spendingRemindersEnabled
        case .goalReminder: return notificationService.goalRemindersEnabled
        case .weeklyReport: return notificationService.weeklyReportsEnabled
        case .monthlySummary: return true // Always enabled
        case .overspendAlert: return notificationService.budgetAlertsEnabled
        case .savingsGoal: return notificationService.goalRemindersEnabled
        case .billReminder: return true // Always enabled
        }
    }
    
    private func toggleNotificationType(_ type: FinancialNotificationService.FinancialNotificationType, enabled: Bool) {
        switch type {
        case .budgetAlert, .overspendAlert:
            notificationService.updatePreference("budgetAlertsEnabled", value: enabled)
        case .spendingReminder:
            notificationService.updatePreference("spendingRemindersEnabled", value: enabled)
        case .goalReminder, .savingsGoal:
            notificationService.updatePreference("goalRemindersEnabled", value: enabled)
        case .weeklyReport:
            notificationService.updatePreference("weeklyReportsEnabled", value: enabled)
        case .monthlySummary, .billReminder:
            break // Always enabled
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            let granted = await notificationService.requestNotificationPermission()
            if !granted {
                permissionAlertMessage = "Las notificaciones están deshabilitadas. Ve a Configuración > Notificaciones > JustDad para habilitarlas."
                showingPermissionAlert = true
            }
        }
    }
    
    private func testBudgetAlert() {
        notificationService.scheduleBudgetAlert(
            category: "Manutención",
            spent: 750,
            budget: 1000,
            threshold: .warning
        )
    }
    
    private func testSpendingReminder() {
        notificationService.scheduleSpendingReminder()
    }
    
    private func testWeeklyReport() {
        notificationService.scheduleWeeklyReport()
    }
}

// MARK: - Notification Type Row
struct NotificationTypeRow: View {
    let type: FinancialNotificationService.FinancialNotificationType
    let isEnabled: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(notificationDescription(for: type))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isEnabled },
                set: { onToggle($0) }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding(.vertical, 8)
    }
    
    private func notificationDescription(for type: FinancialNotificationService.FinancialNotificationType) -> String {
        switch type {
        case .budgetAlert: return "Alertas cuando te acerques al límite de presupuesto"
        case .spendingReminder: return "Recordatorios diarios para registrar gastos"
        case .goalReminder: return "Notificaciones sobre el progreso de tus metas"
        case .weeklyReport: return "Resúmenes semanales de tu situación financiera"
        case .monthlySummary: return "Análisis mensual completo de tus finanzas"
        case .overspendAlert: return "Alertas inmediatas cuando excedas el presupuesto"
        case .savingsGoal: return "Recordatorios sobre tus metas de ahorro"
        case .billReminder: return "Notificaciones de facturas próximas a vencer"
        }
    }
}

// MARK: - Budget Threshold Row
struct BudgetThresholdRow: View {
    let threshold: FinancialNotificationService.BudgetAlertThreshold
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(threshold.color))
                .frame(width: 12, height: 12)
            
            Text(threshold.displayName)
                .font(.body)
            
            Spacer()
            
            Text("\(Int(threshold.rawValue * 100))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Reminder Time Row
struct ReminderTimeRow: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Test Notification Button Style
struct TestNotificationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    FinancialNotificationSettingsView()
}
