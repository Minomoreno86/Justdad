//
//  EmotionArchiveNavigationView.swift
//  JustDad - Emotion Archive Navigation Container
//
//  Navigation container que maneja todas las rutas del archivo de emociones.
//

import SwiftUI

struct EmotionArchiveNavigationView: View {
    @EnvironmentObject private var router: NavigationRouter
    
    var body: some View {
        NavigationStack(path: $router.paths) {
            EmotionArchiveView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .emotionArchiveDetail(let entryId):
            // TODO: Implement detail view for emotion archive entries
            Text("Detalle de entrada: \(entryId)")
        default:
            Text("Ruta no encontrada para archivo de emociones")
        }
    }
}

#Preview {
    EmotionArchiveNavigationView()
        .environmentObject(NavigationRouter())
}
