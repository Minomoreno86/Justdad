//
//  ForgivenessSettingsView.swift
//  JustDad - Forgiveness Therapy Settings
//
//  Configuraciones para la Terapia del Perdón Pránica
//

import SwiftUI

struct ForgivenessSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var forgivenessService = ForgivenessService.shared
    
    var body: some View {
        NavigationStack {
            Form {
                // Audio Settings
                audioSettingsSection
                
                // Haptic Feedback
                hapticSettingsSection
                
                // Breathing Patterns
                breathingSettingsSection
                
                // Reminders
                reminderSettingsSection
                
                // Progress Notifications
                progressNotificationsSection
                
                // Data Management
                dataManagementSection
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Audio Settings Section
    
    private var audioSettingsSection: some View {
        Section {
            Toggle("Audio Binaural (528Hz)", isOn: $forgivenessService.settings.enableBinauralAudio)
            
            if forgivenessService.settings.enableBinauralAudio {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frecuencia del Amor y Sanación")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.pink)
                        Text("528Hz - Frecuencia de reparación del ADN")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Audio")
        } footer: {
            Text("El audio binaural ayuda a sincronizar las ondas cerebrales y facilita el proceso de sanación.")
        }
    }
    
    // MARK: - Haptic Settings Section
    
    private var hapticSettingsSection: some View {
        Section {
            Toggle("Vibración Háptica", isOn: $forgivenessService.settings.enableHapticFeedback)
            
            if forgivenessService.settings.enableHapticFeedback {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipos de Vibración")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "hand.tap")
                            .foregroundColor(.blue)
                        Text("Suave - Durante respiración")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.orange)
                        Text("Media - Al cortar cordones")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.red)
                        Text("Fuerte - Al sellar liberación")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Feedback Táctil")
        } footer: {
            Text("Las vibraciones sincronizadas mejoran la experiencia sensorial y la conexión mente-cuerpo.")
        }
    }
    
    // MARK: - Breathing Settings Section
    
    private var breathingSettingsSection: some View {
        Section {
            Picker("Patrón de Respiración", selection: $forgivenessService.settings.preferredBreathingPattern) {
                ForEach(BreathingPattern.allCases) { pattern in
                    VStack(alignment: .leading) {
                        Text(pattern.title)
                            .font(.body)
                        Text(pattern.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(pattern)
                }
            }
            .pickerStyle(NavigationLinkPickerStyle())
        } header: {
            Text("Respiración")
        } footer: {
            Text("Elige el patrón de respiración que más te ayude a relajarte y conectarte.")
        }
    }
    
    // MARK: - Reminder Settings Section
    
    private var reminderSettingsSection: some View {
        Section {
            Toggle("Recordatorios Diarios", isOn: .constant(true))
            
            if true { // Always show when reminders are enabled
                DatePicker(
                    "Hora del Recordatorio",
                    selection: Binding(
                        get: { forgivenessService.settings.reminderTime ?? Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date() },
                        set: { forgivenessService.settings.reminderTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mensaje de Recordatorio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("💝 Es hora de tu sesión de perdón. Tómate 15 minutos para liberar y sanar.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(UIColor.systemGray6))
                        )
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Recordatorios")
        } footer: {
            Text("Los recordatorios te ayudan a mantener la consistencia en tu práctica de 21 días.")
        }
    }
    
    // MARK: - Progress Notifications Section
    
    private var progressNotificationsSection: some View {
        Section {
            Toggle("Notificaciones de Progreso", isOn: $forgivenessService.settings.enableProgressNotifications)
            
            if forgivenessService.settings.enableProgressNotifications {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recibirás notificaciones para:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completar fases")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Rachas de días consecutivos")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Logros especiales")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Notificaciones")
        } footer: {
            Text("Mantente motivado con notificaciones que celebran tu progreso.")
        }
    }
    
    // MARK: - Data Management Section
    
    private var dataManagementSection: some View {
        Section {
            Button(action: {
                // Export data
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.blue)
                    Text("Exportar Datos")
                    Spacer()
                }
            }
            
            Button(action: {
                // Reset progress
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                    Text("Reiniciar Progreso")
                    Spacer()
                }
            }
            .foregroundColor(.orange)
            
            Button(action: {
                // Delete all data
                showingDeleteAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Eliminar Todos los Datos")
                    Spacer()
                }
            }
            .foregroundColor(.red)
        } header: {
            Text("Gestión de Datos")
        } footer: {
            Text("Administra tus datos de sesiones y progreso.")
        }
    }
    
    // MARK: - Alert States
    
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    
    // MARK: - Helper Methods
    
    private func saveSettings() {
        // Settings are automatically saved through @StateObject binding
        // Additional save logic can be added here if needed
    }
    
    private func resetProgress() {
        // Reset all forgiveness progress
        forgivenessService.currentSessions.removeAll()
        // Save changes
    }
    
    private func deleteAllData() {
        // Delete all forgiveness data
        forgivenessService.currentSessions.removeAll()
        forgivenessService.currentProgress.removeAll()
        // Save changes
    }
}

// MARK: - Alert Extensions

extension ForgivenessSettingsView {
    private var resetAlert: some View {
        EmptyView()
            .alert("Reiniciar Progreso", isPresented: $showingResetAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Reiniciar", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("¿Estás seguro de que quieres reiniciar todo tu progreso? Esta acción no se puede deshacer.")
            }
    }
    
    private var deleteAlert: some View {
        EmptyView()
            .alert("Eliminar Datos", isPresented: $showingDeleteAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("¿Estás seguro de que quieres eliminar todos tus datos de Terapia del Perdón? Esta acción no se puede deshacer.")
            }
    }
}

#Preview {
    ForgivenessSettingsView()
}
