# Configuración del Workspace para JustDad

Este workspace está configurado para el desarrollo Swift/iOS con VS Code. Aquí tienes las herramientas y comandos disponibles:

## Extensiones Instaladas

- **SweetPad**: Desarrollo Swift/iOS en VS Code
- **Swift for Visual Studio Code**: Soporte de lenguaje Swift
- **Syntax Xcode Project Data**: Resaltado de sintaxis para archivos .pbxproj
- **SwiftUI**: Soporte básico para SwiftUI

## Tareas Disponibles (Cmd+Shift+P > Tasks: Run Task)

### 🔨 Build Swift Project

Compila el proyecto usando xcodebuild para iOS Simulator (iPhone 15)

### 🧹 Clean Swift Project

Limpia el proyecto eliminando archivos de compilación anteriores

### 📱 Run iOS Simulator

Ejecuta la aplicación en el simulador de iOS

### 🚀 Open in Xcode

Abre el proyecto directamente en Xcode

## Estructura del Proyecto

```
JustDad/
├── JustDad/
│   ├── JustDadApp.swift      # Archivo principal de la app
│   ├── ContentView.swift     # Vista principal con SwiftUI
│   ├── Item.swift           # Modelo de datos con SwiftData
│   └── Assets.xcassets/     # Recursos (iconos, colores)
├── JustDadTests/            # Tests unitarios
└── JustDadUITests/          # Tests de interfaz
```

## Workflow Recomendado

1. **Editar código** en VS Code con resaltado de sintaxis y autocompletado
2. **Compilar** usando la tarea "Build Swift Project"
3. **Probar** usando "Run iOS Simulator" o abriendo en Xcode
4. **Depurar** en Xcode cuando sea necesario

## Características del Proyecto

Tu app **JustDad** es una aplicación SwiftUI que usa:

- **SwiftData** para persistencia de datos
- **NavigationSplitView** para navegación
- **Modelo Item** con timestamps
- **CRUD operations** (Create, Read, Update, Delete)

¡Listo para desarrollar! 🎉
