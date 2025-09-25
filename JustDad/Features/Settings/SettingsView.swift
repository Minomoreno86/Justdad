//
//  SettingsView.swift
//  SoloPapá - App settings and preferences
//
//  Biometric auth, data export, app preferences
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingExportSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingProfileSheet = false
    @State private var profileUpdated = false
    @State private var isCreatingBackup = false
    @State private var backupProgress: Double = 0.0
    @State private var backupStatus = "Preparando copia de seguridad..."
    @State private var showingBackupAlert = false
    @State private var backupMessage = ""
    @State private var storageUsage: String = "Calculando..."
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    Button(action: {
                        showingProfileSheet = true
                    }) {
                        HStack {
                            // Profile Image
                            if let imageData = appState.userProfileImageData,
                               let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text("P")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(appState.userName.isEmpty ? "Papá Usuario" : appState.userName)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .animation(.easeInOut(duration: 0.3), value: appState.userName)
                                    
                                    // Indicator when profile is configured
                                    if !appState.userName.isEmpty {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .scaleEffect(profileUpdated ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: profileUpdated)
                                    }
                                }
                                
                                Text(appState.userAge.isEmpty ? "Configuración de perfil" : "\(appState.userAge) años")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .animation(.easeInOut(duration: 0.3), value: appState.userAge)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Security section
                Section("Seguridad") {
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Face ID / Touch ID")
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.biometricAuthEnabled)
                    }
                }
                
                // Appearance section
                Section("Apariencia") {
                    HStack {
                        Image(systemName: "moon.circle")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Modo oscuro")
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.darkModeEnabled)
                            .onChange(of: appState.darkModeEnabled) { oldValue, newValue in
                                appState.saveState()
                            }
                    }
                    
                    Button(action: {
                        // TODO: Implement text size settings
                        print("Configurar tamaño de texto")
                    }) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Tamaño de texto")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("Mediano")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // TODO: Implement language settings
                        print("Configurar idioma")
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Idioma")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("Español")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Data section
                Section("Datos") {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Exportar mis datos")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        createLocalBackup()
                    }) {
                        HStack {
                            Image(systemName: "icloud.and.arrow.down")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Copia de seguridad local")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if isCreatingBackup {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(isCreatingBackup)
                    
                    if isCreatingBackup {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(backupStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: backupProgress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("\(Int(backupProgress * 100))% completado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Uso de almacenamiento")
                        
                        Spacer()
                        
                        Text(storageUsage)
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notifications section
                Section("Notificaciones") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Recordatorios de visitas")
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.visitRemindersEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "heart.circle")
                            .foregroundColor(.pink)
                            .frame(width: 24)
                        
                        Text("Check-in emocional diario")
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.emotionalCheckInEnabled)
                    }
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Alertas de emergencia")
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.emergencyAlertsEnabled)
                    }
                }
                
                // Support section
                Section("Soporte") {
                    Button(action: {
                        // TODO: Implement help center
                        print("Abrir centro de ayuda")
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("Centro de ayuda")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // TODO: Implement support contact
                        print("Contactar soporte")
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Contactar soporte")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // TODO: Implement app rating
                        print("Calificar la app")
                    }) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            
                            Text("Calificar la app")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Danger zone
                Section("Zona de Riesgo") {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Eliminar todos los datos")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        // TODO: Implement reset app
                        print("Resetear aplicación")
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Resetear aplicación")
                                .foregroundColor(.orange)
                            
                            Spacer()
                        }
                    }
                }
                
                // App info
                Section {
                    VStack(spacing: 8) {
                        Text("SoloPapá v1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Hecho con ❤️ para papás valientes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Configuración")
            .sheet(isPresented: $showingExportSheet) {
                ExportDataSheet()
            }
            .sheet(isPresented: $showingProfileSheet) {
                ProfileSettingsSheet()
            }
            .onChange(of: appState.userName) { oldValue, newValue in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    profileUpdated = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    profileUpdated = false
                }
            }
                .alert("¿Eliminar todos los datos?", isPresented: $showingDeleteConfirmation) {
                    Button("Cancelar", role: .cancel) { }
                    Button("Eliminar", role: .destructive) {
                        deleteAllAppData()
                    }
                } message: {
                    Text("Esta acción no se puede deshacer. Todos tus datos locales serán eliminados permanentemente.")
                }
                .alert("Copia de Seguridad", isPresented: $showingBackupAlert) {
                    Button("OK") { }
                } message: {
                    Text(backupMessage)
                }
                .onAppear {
                    calculateStorageUsage()
                }
        }
    }
    
    // MARK: - Backup Functions
    private func createLocalBackup() {
        isCreatingBackup = true
        backupProgress = 0.0
        backupStatus = "Preparando copia de seguridad..."
        
        Task {
            await performLocalBackup()
        }
    }
    
    private func performLocalBackup() async {
        // Step 1: Prepare backup directory
        await updateBackupProgress(0.1, "Creando directorio de respaldo...")
        let backupURL = await createBackupDirectory()
        
        guard let backupURL = backupURL else {
            await showBackupError("No se pudo crear el directorio de respaldo")
            return
        }
        
        // Step 2: Backup user data
        await updateBackupProgress(0.2, "Respaldo de datos del usuario...")
        let userDataBackup = await backupUserData(to: backupURL)
        
        // Step 3: Backup journal entries
        await updateBackupProgress(0.4, "Respaldo de entradas del diario...")
        let journalBackup = await backupJournalData(to: backupURL)
        
        // Step 4: Backup financial data
        await updateBackupProgress(0.6, "Respaldo de datos financieros...")
        let financeBackup = await backupFinancialData(to: backupURL)
        
        // Step 5: Backup agenda data
        await updateBackupProgress(0.8, "Respaldo de datos de agenda...")
        let agendaBackup = await backupAgendaData(to: backupURL)
        
        // Step 6: Create backup manifest
        await updateBackupProgress(0.9, "Creando manifiesto de respaldo...")
        let manifestCreated = await createBackupManifest(
            userData: userDataBackup,
            journal: journalBackup,
            finance: financeBackup,
            agenda: agendaBackup,
            to: backupURL
        )
        
        // Step 7: Complete backup
        await updateBackupProgress(1.0, "Copia de seguridad completada")
        
        await MainActor.run {
            isCreatingBackup = false
            if manifestCreated {
                backupMessage = "✅ Copia de seguridad creada exitosamente en:\n\(backupURL.path)"
            } else {
                backupMessage = "⚠️ Copia de seguridad creada con advertencias"
            }
            showingBackupAlert = true
        }
    }
    
    private func updateBackupProgress(_ progress: Double, _ status: String) async {
        await MainActor.run {
            backupProgress = progress
            backupStatus = status
        }
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
    }
    
    private func showBackupError(_ message: String) async {
        await MainActor.run {
            isCreatingBackup = false
            backupMessage = "❌ Error: \(message)"
            showingBackupAlert = true
        }
    }
    
    private func createBackupDirectory() async -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupPath = documentsPath.appendingPathComponent("JustDad_Backup_\(Date().timeIntervalSince1970)")
        
        do {
            try FileManager.default.createDirectory(at: backupPath, withIntermediateDirectories: true)
            return backupPath
        } catch {
            print("Error creating backup directory: \(error)")
            return nil
        }
    }
    
    private func backupUserData(to backupURL: URL) async -> Bool {
        let userDataFile = backupURL.appendingPathComponent("user_data.json")
        let userData: [String: Any] = [
            "userName": appState.userName,
            "userAge": appState.userAge,
            "biometricAuthEnabled": appState.biometricAuthEnabled,
            "notificationsEnabled": appState.notificationsEnabled,
            "darkModeEnabled": appState.darkModeEnabled,
            "hasCompletedOnboarding": appState.hasCompletedOnboarding,
            "backupDate": Date().iso8601String
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userData, options: .prettyPrinted)
            try jsonData.write(to: userDataFile)
            return true
        } catch {
            print("Error backing up user data: \(error)")
            return false
        }
    }
    
    private func backupJournalData(to backupURL: URL) async -> Bool {
        // TODO: Implement real journal data backup
        let journalFile = backupURL.appendingPathComponent("journal_data.json")
        let journalData = [
            "entries": [],
            "emotions": [],
            "audioNotes": []
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: journalData, options: .prettyPrinted)
            try jsonData.write(to: journalFile)
            return true
        } catch {
            print("Error backing up journal data: \(error)")
            return false
        }
    }
    
    private func backupFinancialData(to backupURL: URL) async -> Bool {
        // TODO: Implement real financial data backup
        let financeFile = backupURL.appendingPathComponent("financial_data.json")
        let financeData = [
            "transactions": [],
            "goals": [],
            "budgets": []
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: financeData, options: .prettyPrinted)
            try jsonData.write(to: financeFile)
            return true
        } catch {
            print("Error backing up financial data: \(error)")
            return false
        }
    }
    
    private func backupAgendaData(to backupURL: URL) async -> Bool {
        // TODO: Implement real agenda data backup
        let agendaFile = backupURL.appendingPathComponent("agenda_data.json")
        let agendaData = [
            "visits": [],
            "reminders": [],
            "appointments": []
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: agendaData, options: .prettyPrinted)
            try jsonData.write(to: agendaFile)
            return true
        } catch {
            print("Error backing up agenda data: \(error)")
            return false
        }
    }
    
    private func createBackupManifest(userData: Bool, journal: Bool, finance: Bool, agenda: Bool, to backupURL: URL) async -> Bool {
        let manifestFile = backupURL.appendingPathComponent("backup_manifest.json")
        let manifest: [String: Any] = [
            "appVersion": "1.0.0",
            "backupDate": Date().iso8601String,
            "components": [
                "userData": userData,
                "journal": journal,
                "finance": finance,
                "agenda": agenda
            ],
            "totalComponents": 4,
            "successfulComponents": [userData, journal, finance, agenda].filter { $0 }.count
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: manifest, options: .prettyPrinted)
            try jsonData.write(to: manifestFile)
            return true
        } catch {
            print("Error creating backup manifest: \(error)")
            return false
        }
    }
    
    // MARK: - Storage Functions
    private func calculateStorageUsage() {
        Task {
            let usage = await getAppStorageUsage()
            await MainActor.run {
                storageUsage = usage
            }
        }
    }
    
    private func getAppStorageUsage() async -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        
        var totalSize: Int64 = 0
        
        // Calculate Documents directory size
        if let documentsSize = await calculateDirectorySize(at: documentsPath) {
            totalSize += documentsSize
        }
        
        // Calculate Library directory size
        if let librarySize = await calculateDirectorySize(at: libraryPath) {
            totalSize += librarySize
        }
        
        return formatBytes(totalSize)
    }
    
    private func calculateDirectorySize(at url: URL) async -> Int64? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                var totalSize: Int64 = 0
                
                if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                            if let fileSize = resourceValues.fileSize {
                                totalSize += Int64(fileSize)
                            }
                        } catch {
                            // Skip files that can't be accessed
                            continue
                        }
                    }
                }
                
                continuation.resume(returning: totalSize)
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Data Deletion Functions
    private func deleteAllAppData() {
        Task {
            await performDataDeletion()
        }
    }
    
    private func performDataDeletion() async {
        // Step 1: Clear UserDefaults
        await clearUserDefaults()
        
        // Step 2: Clear SwiftData
        await clearSwiftData()
        
        // Step 3: Clear Documents directory
        await clearDocumentsDirectory()
        
        // Step 4: Reset AppState
        await MainActor.run {
            resetAppState()
        }
    }
    
    private func clearUserDefaults() async {
        let defaults = UserDefaults.standard
        let keys = [
            "biometricAuthEnabled", "notificationsEnabled", "visitRemindersEnabled",
            "emotionalCheckInEnabled", "emergencyAlertsEnabled", "darkModeEnabled",
            "hasCompletedOnboarding", "userName", "userAge", "userProfileImageData"
        ]
        
        for key in keys {
            defaults.removeObject(forKey: key)
        }
    }
    
    private func clearSwiftData() async {
        // Clear all SwiftData models
        let persistenceService = PersistenceService.shared
        
        // Clear all data types
        do {
            // Clear visits
            let visits = try persistenceService.fetchVisits()
            for visit in visits {
                try await persistenceService.delete(visit)
            }
            
            // Clear financial entries
            let financialEntries = try persistenceService.fetchFinancialEntries()
            for entry in financialEntries {
                try await persistenceService.delete(entry)
            }
            
            // Clear emotional entries
            let emotionalEntries = try persistenceService.fetchEmotionalEntries()
            for entry in emotionalEntries {
                try await persistenceService.delete(entry)
            }
            
            // Clear diary entries
            let diaryEntries = try persistenceService.fetchDiaryEntries()
            for entry in diaryEntries {
                try await persistenceService.delete(entry)
            }
            
        } catch {
            print("Error clearing SwiftData: \(error)")
        }
    }
    
    private func clearDocumentsDirectory() async {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing documents directory: \(error)")
        }
    }
    
    private func resetAppState() {
        appState.userName = ""
        appState.userAge = ""
        appState.userProfileImageData = nil
        appState.biometricAuthEnabled = false
        appState.notificationsEnabled = true
        appState.visitRemindersEnabled = true
        appState.emotionalCheckInEnabled = true
        appState.emergencyAlertsEnabled = true
        appState.darkModeEnabled = false
        appState.hasCompletedOnboarding = false
        appState.emergencyContacts = []
        
        // Recalculate storage usage
        calculateStorageUsage()
    }
}

// MARK: - Profile Settings Sheet
struct ProfileSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var userName: String = ""
    @State private var userAge: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información Personal") {
                    HStack {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text("P")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Foto de perfil")
                                .font(.headline)
                            Text("Toca para cambiar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    HStack {
                        Text("Nombre")
                        Spacer()
                        TextField("Tu nombre", text: $userName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("Edad")
                        Spacer()
                        TextField("Tu edad", text: $userAge)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 150)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Preferencias") {
                    HStack {
                        Text("Notificaciones")
                        Spacer()
                        Toggle("", isOn: $appState.notificationsEnabled)
                    }
                    
                    HStack {
                        Text("Modo oscuro")
                        Spacer()
                        Toggle("", isOn: $appState.darkModeEnabled)
                    }
                }
                
                Section {
                    Button(action: {
                        saveProfile()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Guardando...")
                            } else {
                                Text("Guardar cambios")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(userName.isEmpty || isLoading)
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadProfile()
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func loadProfile() {
        userName = appState.userName
        userAge = appState.userAge
        
        // Load saved image if exists
        if let imageData = appState.userProfileImageData,
           let image = UIImage(data: imageData) {
            selectedImage = image
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Update AppState
        appState.userName = userName
        appState.userAge = userAge
        
        // Save image if selected
        if let image = selectedImage {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                appState.userProfileImageData = imageData
            }
        }
        
        // Save to UserDefaults
        appState.saveState()
        
        // Simulate save delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            dismiss()
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Export Data Sheet
struct ExportDataSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @State private var includePhotos = true
    @State private var includeAudio = true
    @State private var includeDiary = true
    @State private var includeFinances = true
    @State private var isExporting = false
    @State private var exportProgress: Double = 0.0
    @State private var exportStatus = "Preparando exportación..."
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Datos a Exportar") {
                    Toggle("Fotos y videos", isOn: $includePhotos)
                    Toggle("Grabaciones de audio", isOn: $includeAudio)
                    Toggle("Entradas de diario", isOn: $includeDiary)
                    Toggle("Datos financieros", isOn: $includeFinances)
                }
                
                Section("Formato de Exportación") {
                    HStack {
                        Image(systemName: "doc.zipper")
                        Text("Archivo ZIP cifrado")
                        Spacer()
                        Text("Recomendado")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Section("Información") {
                    Text("Todos los datos serán cifrados y comprimidos en un archivo ZIP. El archivo incluirá una contraseña que deberás guardar en un lugar seguro.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if isExporting {
                    Section("Progreso de Exportación") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exportStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: exportProgress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text("\(Int(exportProgress * 100))% completado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        startExport()
                    }) {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Exportando...")
                            } else {
                                Text("Comenzar Exportación")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(isExporting)
                }
            }
            .navigationTitle("Exportar Datos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ExportShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    // MARK: - Export Functions
    private func startExport() {
        isExporting = true
        exportProgress = 0.0
        exportStatus = "Preparando exportación..."
        
        Task {
            await performExport()
        }
    }
    
    private func performExport() async {
        // Step 1: Prepare data
        await updateProgress(0.1, "Recopilando datos del perfil...")
        let profileData = await collectProfileData()
        
        await updateProgress(0.2, "Recopilando datos del diario...")
        let journalData = await collectJournalData()
        
        await updateProgress(0.3, "Recopilando datos financieros...")
        let financeData = await collectFinanceData()
        
        await updateProgress(0.4, "Recopilando datos de agenda...")
        let agendaData = await collectAgendaData()
        
        await updateProgress(0.5, "Creando archivo de exportación...")
        let exportData = createExportData(
            profile: profileData,
            journal: journalData,
            finance: financeData,
            agenda: agendaData
        )
        
        await updateProgress(0.6, "Comprimiendo datos...")
        let zipURL = await createZipFile(with: exportData)
        
        await updateProgress(0.8, "Finalizando exportación...")
        await MainActor.run {
            exportURL = zipURL
            exportProgress = 1.0
            exportStatus = "Exportación completada"
            isExporting = false
            showingShareSheet = true
        }
    }
    
    private func updateProgress(_ progress: Double, _ status: String) async {
        await MainActor.run {
            exportProgress = progress
            exportStatus = status
        }
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
    }
    
    private func collectProfileData() async -> [String: Any] {
        return [
            "userName": appState.userName,
            "userAge": appState.userAge,
            "biometricAuthEnabled": appState.biometricAuthEnabled,
            "notificationsEnabled": appState.notificationsEnabled,
            "darkModeEnabled": appState.darkModeEnabled,
            "hasCompletedOnboarding": appState.hasCompletedOnboarding,
            "exportDate": Date().iso8601String
        ]
    }
    
    private func collectJournalData() async -> [String: Any] {
        // TODO: Implement real journal data collection
        return [
            "entries": [],
            "emotions": [],
            "audioNotes": []
        ]
    }
    
    private func collectFinanceData() async -> [String: Any] {
        // TODO: Implement real finance data collection
        return [
            "transactions": [],
            "goals": [],
            "budgets": []
        ]
    }
    
    private func collectAgendaData() async -> [String: Any] {
        // TODO: Implement real agenda data collection
        return [
            "visits": [],
            "reminders": [],
            "appointments": []
        ]
    }
    
    private func createExportData(profile: [String: Any], journal: [String: Any], finance: [String: Any], agenda: [String: Any]) -> [String: Any] {
        return [
            "appVersion": "1.0.0",
            "exportDate": Date().iso8601String,
            "profile": profile,
            "journal": journal,
            "finance": finance,
            "agenda": agenda
        ]
    }
    
    private func createZipFile(with data: [String: Any]) async -> URL? {
        // TODO: Implement real ZIP file creation
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "JustDad_Export_\(Date().timeIntervalSince1970).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating export file: \(error)")
            return nil
        }
    }
}

// MARK: - Export Share Sheet
struct ExportShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Date Extension
extension Date {
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
