//
//  SoloPapaConfiguration.swift
//  SoloPapá - Configuration and setup instructions
//
//  Instructions for opening this project in Xcode
//

/*
 
 🎯 INSTRUCCIONES PARA ABRIR EN XCODE:
 
 1. Abrir JustDad.xcodeproj en Xcode
 
 2. AÑADIR ARCHIVOS AL PROYECTO:
    - Click derecho en grupo "JustDad" 
    - "Add Files to JustDad"
    - Seleccionar carpetas: Features/, Core/, Assets/
    - Asegurar "Create groups" está seleccionado
 
 3. CONFIGURAR PROJECT SETTINGS:
    - Target: JustDad
    - Bundle Identifier: com.gynevia.solopapa  
    - Display Name: SoloPapá
    - iOS Deployment Target: 17.0
 
 4. HABILITAR CAPABILITIES:
    - Face ID usage
    - Keychain Sharing
    - Background Modes (si necesario)
 
 5. DESCOMENTAR MODELOS:
    - En JustDadApp.swift, descomentar las líneas de modelos
    - Compilar para verificar que no hay errores
 
 6. EJECUTAR:
    - Cmd+R para compilar y ejecutar
    - Probar navegación entre tabs
    - Verificar que todas las pantallas cargan
 
 📱 PANTALLAS IMPLEMENTADAS:
 ✅ Onboarding (3 pasos)
 ✅ Home/Dashboard  
 ✅ Agenda (calendario placeholder)
 ✅ Finanzas (lista de gastos)
 ✅ Emociones (mood tracking)
 ✅ Diario (entradas privadas)
 ✅ Comunidad (foro)
 ✅ SOS (ayuda de emergencia) 
 ✅ Settings (configuración)
 ✅ Navegación completa con TabView
 
 🔒 FUNCIONALIDADES DE SEGURIDAD PREPARADAS:
 - SecurityService para Face ID/Touch ID
 - Keychain integration 
 - Placeholder para SQLCipher
 - DataExportService para PDF/CSV
 
 📋 PRÓXIMOS PASOS:
 1. Implementar CoreData models completamente
 2. Integrar SQLCipher para cifrado de BD
 3. Añadir funcionalidad de Face ID real
 4. Implementar generación de PDFs
 5. Crear API para comunidad (solo anónima)
 
 */

import Foundation

// Placeholder configuration class
struct SoloPapaConfig {
    static let appName = "SoloPapá"
    static let bundleId = "com.gynevia.solopapa"
    static let version = "1.0.0"
    static let minimumIOSVersion = "17.0"
    
    // Database configuration
    static let databaseName = "SoloPapa.sqlite"
    static let enableEncryption = true
    
    // Security settings
    static let requireBiometricAuth = true
    static let keyChainServiceName = "com.gynevia.solopapa.keychain"
    
    // Export settings
    static let maxExportSizeMB = 100
    static let supportedExportFormats = ["PDF", "CSV", "ZIP"]
}
