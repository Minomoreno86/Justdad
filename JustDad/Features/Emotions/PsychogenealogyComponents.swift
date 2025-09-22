//
//  PsychogenealogyComponents.swift
//  JustDad - Psicogenealogía UI Components
//
//  Created by Jorge Vasquez Rodriguez
//

import SwiftUI

// MARK: - Family Tree Visualization

struct FamilyTreeVisualizationView: View {
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    
    var body: some View {
        VStack {
            Text("Árbol Familiar")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if psychogenealogyService.familyMembers.isEmpty {
                EmptyTreeView()
            } else {
                FamilyTreeCanvas(psychogenealogyService: psychogenealogyService)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct EmptyTreeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tree")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            
            Text("Comienza agregando miembros de tu familia")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Text("Toca el botón + para agregar el primer miembro")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct FamilyTreeCanvas: View {
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(spacing: 20) {
                    ForEach(psychogenealogyService.familyMembers, id: \.id) { member in
                        TreeNodeView(member: member, psychogenealogyService: psychogenealogyService)
                    }
                }
                .padding()
            }
        }
        .frame(height: 300)
    }
}

struct TreeNodeView: View {
    let member: FamilyMember
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    
    var body: some View {
        VStack(spacing: 8) {
            // Member Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [member.sex == .male ? .blue : .pink, .white.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(member.displayName.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            // Member Name
            Text(member.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Member Info
            VStack(spacing: 2) {
                if let birthDate = member.birthDate {
                    Text("Nacido: \(birthDate, formatter: dateFormatter)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if !member.isAlive {
                    Text("Fallecido")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.8))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pattern Insights

// PatternInsightsView moved to PatternInsightsView.swift

struct EmptyPatternsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            
            Text("No se han detectado patrones aún")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Text("Agrega más información familiar para detectar patrones automáticamente")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(30)
    }
}

// PatternCard moved to PatternInsightsView.swift

// MARK: - Letter Cards

struct PsychogenealogyLetterCard: View {
    let letter: PsychogenealogyLetter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(letter.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if letter.isUnlocked {
                    Image(systemName: "lock.open")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                }
            }
            
            Text(letter.content)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(4)
            
            HStack {
                Text("Duración: \(letter.duration) min")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Text(letter.type.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.2))
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Member Detail

struct MemberDetailView: View {
    let member: FamilyMember
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Member Header
                    MemberHeaderView(member: member)
                    
                    // Member Info
                    MemberInfoSection(member: member)
                    
                    // Events Section
                    EventsSection(member: member, psychogenealogyService: psychogenealogyService)
                    
                    // Relationships Section
                    RelationshipsSection(member: member, psychogenealogyService: psychogenealogyService)
                }
                .padding()
            }
            .navigationTitle(member.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .background(
                LinearGradient(
                    colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct MemberHeaderView: View {
    let member: FamilyMember
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    colors: [member.sex == .male ? .blue : .pink, .white.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(member.displayName.prefix(1).uppercased())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.displayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(member.sex.displayName)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                
                if let age = member.age() {
                    Text("\(age) años")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct MemberInfoSection: View {
    let member: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Información Personal")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                if let birthDate = member.birthDate {
                    PsychogenealogyInfoRow(title: "Fecha de Nacimiento", value: birthDate, formatter: dateFormatter)
                }
                
                if let deathDate = member.deathDate {
                    PsychogenealogyInfoRow(title: "Fecha de Fallecimiento", value: deathDate, formatter: dateFormatter)
                }
                
                PsychogenealogyInfoRow(title: "Estado", value: member.isAlive ? "Vivo" : "Fallecido")
                PsychogenealogyInfoRow(title: "Presencia", value: member.isPresent ? "Presente" : "Ausente")
            }
            
            if !member.notes.isEmpty {
                Text("Notas:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(member.notes)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.05))
                    )
            }
        }
    }
}

struct EventsSection: View {
    let member: FamilyMember
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    
    var events: [FamilyEvent] {
        psychogenealogyService.getEventsForMember(member.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Eventos (\(events.count))")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if events.isEmpty {
                Text("No hay eventos registrados para este miembro")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.05))
                    )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(events, id: \.id) { event in
                        EventRow(event: event)
                    }
                }
            }
        }
    }
}

struct RelationshipsSection: View {
    let member: FamilyMember
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    
    var relationships: [Relationship] {
        psychogenealogyService.getRelationshipsForMember(member.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Relaciones (\(relationships.count))")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if relationships.isEmpty {
                Text("No hay relaciones registradas para este miembro")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.05))
                    )
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(relationships, id: \.id) { relationship in
                        RelationshipRow(relationship: relationship, psychogenealogyService: psychogenealogyService)
                    }
                }
            }
        }
    }
}

struct EventRow: View {
    let event: FamilyEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.kind.icon)
                .foregroundColor(event.kind.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.kind.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let date = event.date {
                    Text(date, formatter: dateFormatter)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text("Nivel \(event.severity)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(event.severity >= 4 ? .red.opacity(0.8) : .orange.opacity(0.8))
                )
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
        )
    }
}

struct RelationshipRow: View {
    let relationship: Relationship
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    
    var relatedMember: FamilyMember? {
        let memberID = relationship.fromMemberID == relationship.toMemberID ? 
            relationship.toMemberID : relationship.fromMemberID
        
        return psychogenealogyService.familyMembers.first { $0.id == memberID }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.2")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(relationship.type.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let relatedMember = relatedMember {
                    Text("con \(relatedMember.displayName)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                if !relationship.notes.isEmpty {
                    Text(relationship.notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if relationship.endDate != nil {
                Text("Finalizada")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.gray.opacity(0.8))
                    )
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Info Row Component

struct PsychogenealogyInfoRow: View {
    let title: String
    let value: String
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    init(title: String, value: Date, formatter: DateFormatter) {
        self.title = title
        self.value = formatter.string(from: value)
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Formatters

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

// MARK: - Preview

#Preview {
    let service = PsychogenealogyService.shared
    
    VStack(spacing: 20) {
        FamilyTreeVisualizationView(psychogenealogyService: service)
        PatternInsightsView(psychogenealogyService: service)
    }
    .padding()
    .background(Color.black)
}