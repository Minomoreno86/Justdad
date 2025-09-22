import SwiftUI

struct PsychogenealogyLetterDetailView: View {
    let letter: PsychogenealogyLetter
    @EnvironmentObject var psychogenealogyService: PsychogenealogyService
    @State private var selectedPattern: PatternType?
    @State private var selectedFamilyMembers: Set<UUID> = []
    @State private var isReadingLetter = false
    @State private var showingSessionComplete = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                letterContentView
                patternSection
                familyMembersSection
                sessionControls
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.8), .indigo.opacity(0.6), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSessionComplete) {
            sessionCompleteView
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(letter.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                Text("\(letter.duration) minutos")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(letter.targetPattern.rawValue.capitalized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.2))
                    )
            }
        }
    }
    
    private var letterContentView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Contenido de la Carta")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            Text(letter.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var patternSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Patrón Trabajado")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "target")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(letter.targetPattern.rawValue.capitalized)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Patrón objetivo de esta carta")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.2))
            )
        }
    }
    
    private var familyMembersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Miembros de la Familia Afectados")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            if psychogenealogyService.familyMembers.isEmpty {
                emptyFamilyMembersView
            } else {
                familyMembersListView
            }
        }
    }
    
    private var emptyFamilyMembersView: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.3")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.gray)
            
            Text("No hay miembros de la familia registrados")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Agrega miembros de la familia para trabajar con esta carta")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var familyMembersListView: some View {
        ForEach(Array(psychogenealogyService.familyMembers), id: \.id) { member in
            familyMemberRow(for: member)
        }
    }
    
    private func familyMemberRow(for member: FamilyMember) -> some View {
        HStack {
            Image(systemName: member.sex == .male ? "person.fill" : "person")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(member.sex == .male ? .blue : .pink)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(member.sex == .male ? "Hombre" : "Mujer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button {
                if selectedFamilyMembers.contains(member.id) {
                    selectedFamilyMembers.remove(member.id)
                } else {
                    selectedFamilyMembers.insert(member.id)
                }
            } label: {
                Image(systemName: selectedFamilyMembers.contains(member.id) ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(selectedFamilyMembers.contains(member.id) ? .green : .white.opacity(0.6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(selectedFamilyMembers.contains(member.id) ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
        )
    }
    
    private var sessionControls: some View {
        VStack(spacing: 15) {
            Button {
                isReadingLetter.toggle()
            } label: {
                HStack {
                    Image(systemName: isReadingLetter ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                    
                    Text(isReadingLetter ? "Detener Lectura" : "Leer en Voz Alta")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isReadingLetter ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                )
            }
            
            Button {
                completeSession()
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                    
                    Text("Completar Sesión")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.8))
                )
            }
        }
    }
    
    private var sessionCompleteView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(.green)
            
            Text("¡Sesión Completada!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Has trabajado exitosamente con la carta psicogenealógica")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Continuar") {
                showingSessionComplete = false
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
        }
        .padding()
    }
    
    private func completeSession() {
        let sessionId = UUID()
        psychogenealogyService.completeSession(sessionId)
        showingSessionComplete = true
    }
}

#Preview {
    NavigationStack {
        PsychogenealogyLetterDetailView(
            letter: PsychogenealogyLetter(
                type: .paternalLineage,
                title: "Carta de Ejemplo",
                content: "Esta es una carta de ejemplo para psicogenealogía.",
                voiceAnchors: ["te reconozco", "te libero"],
                affirmations: ["Soy libre", "Me sostengo"],
                duration: 15,
                targetPattern: .absence
            )
        )
        .environmentObject(PsychogenealogyService.shared)
    }
}