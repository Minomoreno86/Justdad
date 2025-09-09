//
//  SettingsView.swift
//  SoloPapá - App settings and preferences
//
//  Biometric auth, data export, app preferences
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var router = NavigationRouter.shared
    @EnvironmentObject var appState: AppState
    @State private var showingExportSheet = false
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    HStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("P")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Papá Usuario")
                                .font(.headline)
                            Text("Configuración de perfil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
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
                    
                    HStack {
                        Image(systemName: "lock.rotation")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Cambiar código de acceso")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Gestión de claves")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    }
                    
                    HStack {
                        Image(systemName: "textformat.size")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Tamaño de texto")
                        
                        Spacer()
                        
                        Text("Mediano")
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Idioma")
                        
                        Spacer()
                        
                        Text("Español")
                            .foregroundColor(.secondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    
                    HStack {
                        Image(systemName: "icloud.and.arrow.down")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Copia de seguridad local")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Uso de almacenamiento")
                        
                        Spacer()
                        
                        Text("127 MB")
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
                        
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Image(systemName: "heart.circle")
                            .foregroundColor(.pink)
                            .frame(width: 24)
                        
                        Text("Check-in emocional diario")
                        
                        Spacer()
                        
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Image(systemName: "person.3")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Nuevos posts en comunidad")
                        
                        Spacer()
                        
                        Toggle("", isOn: .constant(false))
                    }
                }
                
                // Support section
                Section("Soporte") {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Centro de ayuda")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("Contactar soporte")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                            .frame(width: 24)
                        
                        Text("Calificar la app")
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            .alert("¿Eliminar todos los datos?", isPresented: $showingDeleteConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    // TODO: Delete all app data
                }
            } message: {
                Text("Esta acción no se puede deshacer. Todos tus datos locales serán eliminados permanentemente.")
            }
        }
    }
}

// MARK: - Export Data Sheet
struct ExportDataSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var includePhotos = true
    @State private var includeAudio = true
    @State private var includeDiary = true
    @State private var includeFinances = true
    
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
                
                Section {
                    Button("Comenzar Exportación") {
                        // TODO: Start export process
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
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
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
