import SwiftUI

struct KarmicSummaryView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @State private var showingAchievements = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .symbolEffect(.bounce)
                    
                    Text("¡Ritual Completado!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Has liberado exitosamente este vínculo kármico")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Resumen de la sesión
                if let session = karmicEngine.currentSession {
                    VStack(spacing: 24) {
                        // Información del vínculo liberado
                        KarmicSummaryCard(
                            title: "Vínculo Liberado",
                            icon: "link.circle",
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(session.bondName)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text(session.bondType.displayName)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Intensidad: \(session.intensityBefore)")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        )
                        
                        // Progreso de validación por voz
                        KarmicSummaryCard(
                            title: "Progreso de Lectura",
                            icon: "mic.circle",
                            content: {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(session.voiceValidations, id: \.id) { validation in
                                        HStack {
                                            Text(validation.block.displayName)
                                                .font(.body)
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 4) {
                                                Image(systemName: validation.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                                    .foregroundColor(validation.success ? .green : .red)
                                                
                                                Text("\(Int(validation.validationPercentage * 100))%")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                        }
                                    }
                                }
                            }
                        )
                        
                        // Voto de comportamiento
                        if let vow = session.behavioralVow {
                            KarmicSummaryCard(
                                title: "Compromiso Establecido",
                                icon: "heart.circle",
                                content: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(vow.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text(vow.title)
                                            .font(.body)
                                            .foregroundColor(.white.opacity(0.8))
                                            .lineSpacing(2)
                                        
                                        Text("Duración: \(vow.duration.displayName)")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                    }
                                }
                            )
                        }
                        
                        // Mejora emocional
                        if let improvement = session.intensityImprovement {
                            KarmicSummaryCard(
                                title: "Mejora Emocional",
                                icon: "arrow.up.circle",
                                content: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Reducción de intensidad")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("-\(improvement) niveles")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                        
                                        Text("De intensidad \(session.intensityBefore) a un estado más ligero")
                                            .font(.body)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            )
                        }
                    }
                }
                
                // Estadísticas de la sesión
                VStack(spacing: 16) {
                    Text("Estadísticas de la Sesión")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        KarmicStatCard(
                            title: "Duración",
                            value: "\(Int(karmicEngine.getSessionDuration())) min",
                            icon: "clock"
                        )
                        
                        KarmicStatCard(
                            title: "Puntos",
                            value: "\(karmicEngine.getSessionPoints())",
                            icon: "star"
                        )
                    }
                }
                
                // Logros desbloqueados
                if !karmicEngine.getNewAchievements().isEmpty {
                    VStack(spacing: 16) {
                        Text("¡Nuevos Logros!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        ForEach(karmicEngine.getNewAchievements(), id: \.self) { achievement in
                            KarmicAchievementCard(achievement: achievement)
                        }
                    }
                }
                
                // Mensaje de cierre
                VStack(spacing: 16) {
                    Text("Mensaje de Cierre")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Has completado exitosamente el ritual de liberación de vínculos kármicos. Recuerda que la liberación es un proceso continuo. Mantén tu compromiso de comportamiento y observa cómo tu vida se transforma hacia una mayor libertad y paz.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                }
                
                // Botones de acción
                VStack(spacing: 16) {
                    Button(action: {
                        karmicEngine.completeRitual()
                    }) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Volver al Inicio")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        showingAchievements = true
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Ver Todos los Logros")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showingAchievements) {
            KarmicAchievementsView(karmicEngine: karmicEngine)
        }
    }
}

struct KarmicSummaryCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct KarmicStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct KarmicAchievementCard: View {
    let achievement: KarmicAchievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(achievement.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text("+\(achievement.pointsReward)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct KarmicAchievementsView: View {
    @ObservedObject var karmicEngine: KarmicEngine
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo oscuro
                LinearGradient(
                    colors: [Color.purple.opacity(0.8), Color.indigo.opacity(0.6), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(karmicEngine.getAllAchievements(), id: \.self) { achievement in
                            KarmicAchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Logros Desbloqueados")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    KarmicSummaryView(karmicEngine: KarmicEngine())
}
