# SoloPapá - App para Padres Divorciados

> **Transformación de JustDad a SoloPapá**  
> Una aplicación móvil diseñada específicamente para padres divorciados, enfocada en la privacidad, el bienestar emocional y la organización de la vida familiar.

## 📱 Descripción del Proyecto

**SoloPapá** es una aplicación iOS que ayuda a padres divorciados a:

- Organizar visitas y tiempo con los hijos
- Gestionar gastos y manutención
- Cuidar su bienestar emocional
- Mantener un diario privado
- Conectar con una comunidad de apoyo

### 🔒 Enfoque en Privacidad

- **Offline-first**: Todos los datos se almacenan localmente
- **Cifrado local**: SQLCipher para base de datos + archivos encriptados
- **Sin sincronización en la nube** por defecto
- **Autenticación biométrica** (Face ID/Touch ID)

## 🏗️ Arquitectura

### Patrón de Diseño

- **SwiftUI + MVVM** para la interfaz
- **SwiftData + CoreData** para persistencia
- **SQLCipher** para cifrado de base de datos
- **Keychain** para almacenamiento seguro de claves

### Estructura de Carpetas

```
SoloPapá/
├── Features/                    # Módulos principales de la app
│   ├── Home/                   # Dashboard principal
│   ├── Agenda/                 # Calendario y visitas
│   ├── Finanzas/              # Gestión financiera
│   ├── Emociones/             # Bienestar emocional
│   ├── Diario/                # Diario privado
│   ├── Comunidad/             # Foro comunitario
│   ├── SOS/                   # Ayuda de emergencia
│   ├── Settings/              # Configuración
│   └── Onboarding/            # Flujo inicial
├── Core/                       # Componentes centrales
│   ├── Models/                # Modelos de datos
│   ├── Persistence/           # CoreData + SQLCipher
│   ├── Security/              # Seguridad y cifrado
│   ├── Services/              # Servicios de la app
│   └── Navigation/            # Estado global y navegación
└── Resources/                  # Recursos y assets
```

## 🎯 Funcionalidades MVP (10 Pantallas)

### 1. **Onboarding** (3 pasos)

- Bienvenida y explicación
- Configuración de seguridad (Face ID)
- Personalización básica

### 2. **Home/Dashboard**

- Resumen del día/semana
- Tarjetas de acceso rápido
- Botón SOS flotante

### 3. **Agenda**

- Calendario de visitas
- Crear/editar citas
- Recordatorios automáticos

### 4. **Finanzas**

- Registro de gastos
- Categorización automática
- Reportes PDF/CSV locales

### 5. **Emociones**

- Estado emocional diario
- Test rápido de bienestar
- Ejercicios de respiración guiados

### 6. **Diario Privado**

- Entradas de texto
- Grabaciones de audio
- Fotos (todo encriptado)

### 7. **Comunidad**

- Foros anónimos
- Categorías temáticas
- Publicación de experiencias

### 8. **SOS (Modal)**

- Contactos de emergencia
- Técnicas de calma inmediata
- Recursos de ayuda profesional

### 9. **Settings/Perfil**

- Configuración de seguridad
- Preferencias de la app
- Exportación de datos

### 10. **Navegación Completa**

- TabView con 5 tabs principales
- Router para navegación entre pantallas
- Modales globales (SOS, Onboarding)

## 🚀 Cómo Abrir el Proyecto

### 1. Requisitos

- **Xcode 15.0+**
- **iOS 17.0+**
- **macOS Sonoma** o superior

### 2. Pasos para abrir en Xcode

```bash
# 1. Navegar al directorio del proyecto
cd /Users/jorgevasquez/Desktop/MisProyectos/JustDad

# 2. Abrir el proyecto en Xcode
open JustDad.xcodeproj
```

### 3. Configuración inicial en Xcode

1. **Cambiar Bundle Identifier**:

   - Seleccionar el target "JustDad"
   - Cambiar Bundle Identifier a: `com.gynevia.solopapa`
   - Cambiar Display Name a: "SoloPapá"

2. **Configurar Capabilities**:

   - Habilitar "Face ID" en Capabilities
   - Agregar "Keychain Sharing"
   - Configurar "App Groups" si es necesario

3. **Añadir archivos al proyecto**:
   - En Xcode, hacer clic derecho en el grupo "JustDad"
   - "Add Files to JustDad"
   - Seleccionar todas las carpetas de Features/ y Core/
   - Asegurar que "Create groups" esté seleccionado

### 4. Compilar y ejecutar

```bash
# Desde terminal (opcional)
xcodebuild -project JustDad.xcodeproj -scheme JustDad -destination 'platform=iOS Simulator,name=iPhone 15' build

# O usar Cmd+R en Xcode
```

## 📋 Tareas Pendientes

### ✅ Completado

- [x] Estructura de carpetas y navegación
- [x] Pantallas principales con placeholders
- [x] AppState para manejo de estado global
- [x] Modelos de datos básicos
- [x] Servicios de seguridad (placeholder)
- [x] Configuración de VS Code para desarrollo

### 🔄 En Progreso

- [ ] Implementación completa de CoreData
- [ ] Integración de SQLCipher
- [ ] Funcionalidad de Face ID/Touch ID
- [ ] Generación de PDFs

### 📝 Por Hacer

- [ ] Calendario funcional en Agenda
- [ ] Gráficos en módulo de Emociones
- [ ] Cifrado de archivos de diario
- [ ] API para comunidad (solo posts anónimos)
- [ ] Notificaciones locales
- [ ] Exportación segura de datos
- [ ] Tests unitarios

## 🛠️ Desarrollo en VS Code

### Tareas configuradas

- **Build Swift Project**: Compila el proyecto
- **Clean Swift Project**: Limpia archivos de compilación
- **Run iOS Simulator**: Ejecuta en simulador
- **Open in Xcode**: Abre directamente en Xcode

### Extensiones instaladas

- SweetPad (desarrollo iOS en VS Code)
- Swift Language Support
- SwiftUI support
- Xcode project syntax

### Workflow recomendado

1. **Editar código** en VS Code (mejor ergonomía)
2. **Compilar y probar** en Xcode
3. **Depurar** en Xcode cuando sea necesario

## 🔐 Consideraciones de Seguridad

### Datos Sensibles

- Todas las entradas del diario se cifran localmente
- Datos financieros protegidos con SQLCipher
- Fotos y audios encriptados antes de almacenar
- Claves de cifrado en Keychain

### Privacidad

- **Cero telemetría** por defecto
- **Sin tracking** de uso
- **Comunidad anónima** sin vinculación a datos locales
- **Exportación segura** con contraseñas

## 📞 Soporte

### Desarrollo

- **Desarrollador**: Jorge Vasquez Rodriguez
- **Fecha de inicio**: 8 de septiembre de 2025
- **Plataforma**: iOS 17.0+

### Recursos

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SQLCipher for iOS](https://www.zetetic.net/sqlcipher/ios-tutorial/)
- [Core Data + SQLCipher Integration](https://github.com/sqlcipher/sqlcipher)

---

**¡Listo para el desarrollo!** 🎉

> **Nota**: Este es el esqueleto inicial. Las funcionalidades avanzadas como SQLCipher, generación de PDFs y API de comunidad se implementarán en iteraciones posteriores.
