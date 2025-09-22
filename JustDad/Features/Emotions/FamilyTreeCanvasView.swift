import SwiftUI

// MARK: - Family Tree Canvas View
struct FamilyTreeCanvasView: View {
    @ObservedObject var psychogenealogyService: PsychogenealogyService
    @State private var selectedMember: FamilyMember?
    @State private var zoomLevel: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var showingAddMember = false
    @State private var showingEditMember = false
    @State private var showingDeleteConfirmation = false
    @State private var memberToDelete: FamilyMember?
    @State private var treeLayout: TreeLayoutType = .circular
    @State private var showPatterns = false
    @State private var highlightedMembers: Set<UUID> = []
    
    enum TreeLayoutType: CaseIterable {
        case circular, hierarchical, radial
        
        var displayName: String {
            switch self {
            case .circular: return "Circular"
            case .hierarchical: return "Jerárquico"
            case .radial: return "Radial"
            }
        }
        
        var icon: String {
            switch self {
            case .circular: return "circle.grid.2x2"
            case .hierarchical: return "list.bullet.indent"
            case .radial: return "rays"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Canvas for family tree
                Canvas { context, size in
                    drawFamilyTree(in: context, size: size)
                }
                .scaleEffect(zoomLevel)
                .offset(panOffset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                zoomLevel = value
                            },
                        DragGesture()
                            .onChanged { value in
                                panOffset = value.translation
                            }
                    )
                )
                .onTapGesture { location in
                    handleCanvasTap(at: location, in: geometry.size)
                }
                
                // Controls overlay
                VStack {
                    HStack {
                        // Layout selector
                        layoutSelectorView
                        
                        Spacer()
                        
                        // Pattern toggle
                        Button(action: { showPatterns.toggle() }) {
                            Image(systemName: showPatterns ? "brain.head.profile.fill" : "brain.head.profile")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(showPatterns ? Color.orange.opacity(0.8) : Color.purple.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        treeControlsView
                    }
                    .padding()
                    
                    Spacer()
                    
                    if let selectedMember = selectedMember {
                        memberDetailOverlay(member: selectedMember)
                            .transition(.move(edge: .bottom))
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 100)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddMember) {
            AddFamilyMemberView()
        }
        .sheet(isPresented: $showingEditMember) {
            if let member = selectedMember {
                MemberEditView(member: member, psychogenealogyService: psychogenealogyService)
            }
        }
        .alert("Eliminar Miembro", isPresented: $showingDeleteConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let member = memberToDelete {
                    psychogenealogyService.deleteMember(member.id)
                    selectedMember = nil
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar a \(memberToDelete?.givenName ?? "")? Esta acción no se puede deshacer.")
        }
        .onAppear {
            detectPatternsAndHighlight()
        }
    }
    
    // MARK: - Tree Drawing
    private func drawFamilyTree(in context: GraphicsContext, size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        // Draw connections first (so they appear behind nodes)
        drawConnections(in: context, centerX: centerX, centerY: centerY)
        
        // Draw nodes on top
        drawNodes(in: context, centerX: centerX, centerY: centerY)
    }
    
    private func drawConnections(in context: GraphicsContext, centerX: CGFloat, centerY: CGFloat) {
        let relationships = psychogenealogyService.relationships
        
        for relationship in relationships {
            // Find members by ID - simplified approach
            guard let parentMember = findMember(by: relationship.fromMemberID),
                  let childMember = findMember(by: relationship.toMemberID) else { continue }
            
            let parentPos = calculateMemberPosition(
                member: parentMember,
                centerX: centerX,
                centerY: centerY
            )
            let childPos = calculateMemberPosition(
                member: childMember,
                centerX: centerX,
                centerY: centerY
            )
            
            // Draw connection line
            var path = Path()
            path.move(to: parentPos)
            path.addLine(to: childPos)
            
            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.4)]),
                    startPoint: parentPos,
                    endPoint: childPos
                ),
                lineWidth: 2
            )
        }
    }
    
    private func drawNodes(in context: GraphicsContext, centerX: CGFloat, centerY: CGFloat) {
        let members = Array(psychogenealogyService.familyMembers)
        
        for member in members {
            let position = calculateMemberPosition(
                member: member,
                centerX: centerX,
                centerY: centerY
            )
            
            // Draw member node
            let nodeSize: CGFloat = 60
            let nodeRect = CGRect(
                x: position.x - nodeSize/2,
                y: position.y - nodeSize/2,
                width: nodeSize,
                height: nodeSize
            )
            
            // Background circle with pattern highlighting
            let baseColor = member.sex == .male ? Color.blue : Color.pink
            let isHighlighted = highlightedMembers.contains(member.id)
            let isSelected = selectedMember?.id == member.id
            
            context.fill(
                Circle().path(in: nodeRect),
                with: .radialGradient(
                    Gradient(colors: [
                        isHighlighted ? Color.orange.opacity(0.9) : baseColor.opacity(0.8),
                        isHighlighted ? Color.orange.opacity(0.5) : baseColor.opacity(0.4)
                    ]),
                    center: CGPoint(x: nodeRect.midX, y: nodeRect.midY),
                    startRadius: 0,
                    endRadius: nodeSize/2
                )
            )
            
            // Pattern highlight ring
            if isHighlighted {
                let ringRect = nodeRect.insetBy(dx: -4, dy: -4)
                context.stroke(
                    Circle().path(in: ringRect),
                    with: .color(.orange),
                    lineWidth: 3
                )
            }
            
            // Selection ring
            if isSelected {
                let selectionRect = nodeRect.insetBy(dx: -6, dy: -6)
                context.stroke(
                    Circle().path(in: selectionRect),
                    with: .color(.purple),
                    lineWidth: 4
                )
            }
            
            // Border
            context.stroke(
                Circle().path(in: nodeRect),
                with: .color(.white),
                lineWidth: 2
            )
            
            // Member icon
            let iconSize: CGFloat = 24
            let iconRect = CGRect(
                x: position.x - iconSize/2,
                y: position.y - iconSize/2,
                width: iconSize,
                height: iconSize
            )
            
            context.draw(
                Image(systemName: member.sex == .male ? "person.fill" : "person"),
                in: iconRect
            )
            
            // Member name
            let nameRect = CGRect(
                x: position.x - 40,
                y: position.y + 35,
                width: 80,
                height: 20
            )
            
            context.draw(
                Text(member.givenName)
                    .font(.caption)
                    .foregroundColor(.primary),
                in: nameRect
            )
        }
    }
    
    private func calculateMemberPosition(member: FamilyMember, centerX: CGFloat, centerY: CGFloat) -> CGPoint {
        switch treeLayout {
        case .circular:
            return calculateCircularPosition(member: member, centerX: centerX, centerY: centerY)
        case .hierarchical:
            return calculateHierarchicalPosition(member: member, centerX: centerX, centerY: centerY)
        case .radial:
            return calculateRadialPosition(member: member, centerX: centerX, centerY: centerY)
        }
    }
    
    private func calculateCircularPosition(member: FamilyMember, centerX: CGFloat, centerY: CGFloat) -> CGPoint {
        let memberIndex = Array(psychogenealogyService.familyMembers).firstIndex(of: member) ?? 0
        let totalMembers = psychogenealogyService.familyMembers.count
        
        if totalMembers == 1 {
            return CGPoint(x: centerX, y: centerY)
        }
        
        let angle = (2 * Double.pi * Double(memberIndex)) / Double(totalMembers)
        let radius: CGFloat = min(centerX, centerY) * 0.6
        
        return CGPoint(
            x: centerX + radius * CGFloat(cos(angle)),
            y: centerY + radius * CGFloat(sin(angle))
        )
    }
    
    private func calculateHierarchicalPosition(member: FamilyMember, centerX: CGFloat, centerY: CGFloat) -> CGPoint {
        // Find generation level
        let generation = calculateGeneration(member: member)
        let membersInGeneration = getMembersInGeneration(generation)
        let memberIndex = membersInGeneration.firstIndex(of: member.id) ?? 0
        
        let yOffset = CGFloat(generation) * 120 - CGFloat(psychogenealogyService.familyMembers.count / 2) * 60
        let xSpacing = min(centerX * 2, 300) / CGFloat(max(membersInGeneration.count, 1))
        let xOffset = CGFloat(memberIndex) * xSpacing - xSpacing * CGFloat(membersInGeneration.count - 1) / 2
        
        return CGPoint(x: centerX + xOffset, y: centerY + yOffset)
    }
    
    private func calculateRadialPosition(member: FamilyMember, centerX: CGFloat, centerY: CGFloat) -> CGPoint {
        let generation = calculateGeneration(member: member)
        let membersInGeneration = getMembersInGeneration(generation)
        let memberIndex = membersInGeneration.firstIndex(of: member.id) ?? 0
        
        let radius = CGFloat(generation + 1) * 80
        let angle = (2 * Double.pi * Double(memberIndex)) / Double(max(membersInGeneration.count, 1))
        
        return CGPoint(
            x: centerX + radius * CGFloat(cos(angle)),
            y: centerY + radius * CGFloat(sin(angle))
        )
    }
    
    private func calculateGeneration(member: FamilyMember) -> Int {
        // Simple generation calculation based on relationships
        let relationships = psychogenealogyService.relationships
        var generation = 0
        var currentMemberId = member.id
        var visited: Set<UUID> = []
        
        // Traverse up the family tree to find root generation
        while let parentRelationship = relationships.first(where: { $0.toMemberID == currentMemberId && !visited.contains($0.fromMemberID) }) {
            visited.insert(currentMemberId)
            currentMemberId = parentRelationship.fromMemberID
            generation += 1
        }
        
        return generation
    }
    
    private func getMembersInGeneration(_ generation: Int) -> [UUID] {
        return psychogenealogyService.familyMembers.compactMap { member in
            calculateGeneration(member: member) == generation ? member.id : nil
        }
    }
    
    // MARK: - Helper Methods
    private func findMember(by id: UUID) -> FamilyMember? {
        return psychogenealogyService.familyMembers.first { $0.id == id }
    }
    
    private func handleCanvasTap(at location: CGPoint, in size: CGSize) {
        // Convert tap location to canvas coordinates
        let canvasLocation = CGPoint(
            x: (location.x - panOffset.width) / zoomLevel,
            y: (location.y - panOffset.height) / zoomLevel
        )
        
        // Find member at tap location
        for member in psychogenealogyService.familyMembers {
            let position = calculateMemberPosition(member: member, centerX: size.width/2, centerY: size.height/2)
            let nodeSize: CGFloat = 60
            let nodeRect = CGRect(
                x: position.x - nodeSize/2,
                y: position.y - nodeSize/2,
                width: nodeSize,
                height: nodeSize
            )
            
            if nodeRect.contains(canvasLocation) {
                withAnimation(.easeInOut) {
                    selectedMember = member
                }
                return
            }
        }
        
        // Tap outside any member - deselect
        withAnimation(.easeInOut) {
            selectedMember = nil
        }
    }
    
    private func detectPatternsAndHighlight() {
        // Detect patterns and highlight affected members
        let patterns = psychogenealogyService.detectedPatterns
        var highlighted: Set<UUID> = []
        
        for pattern in patterns {
            for evidence in pattern.evidence {
                highlighted.insert(evidence.memberID)
            }
        }
        
        highlightedMembers = highlighted
    }
    
    // MARK: - Controls
    private var layoutSelectorView: some View {
        Menu {
            ForEach(TreeLayoutType.allCases, id: \.self) { layout in
                Button(action: { treeLayout = layout }) {
                    HStack {
                        Image(systemName: layout.icon)
                        Text(layout.displayName)
                        if treeLayout == layout {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: treeLayout.icon)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.purple.opacity(0.7))
                .clipShape(Circle())
        }
    }
    
    private var treeControlsView: some View {
        HStack(spacing: 12) {
            Button(action: { zoomLevel = 1.0; panOffset = .zero }) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.purple.opacity(0.7))
                    .clipShape(Circle())
            }
            
            Button(action: { zoomLevel = max(0.5, zoomLevel - 0.2) }) {
                Image(systemName: "minus")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.purple.opacity(0.7))
                    .clipShape(Circle())
            }
            
            Button(action: { zoomLevel = min(2.0, zoomLevel + 0.2) }) {
                Image(systemName: "plus.magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.purple.opacity(0.7))
                    .clipShape(Circle())
            }
        }
    }
    
    private var floatingActionButton: some View {
        Button(action: { showingAddMember = true }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.purple, Color.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Member Detail Overlay
    private func memberDetailOverlay(member: FamilyMember) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(member.givenName + " " + member.familyName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if highlightedMembers.contains(member.id) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    
                    Text(member.sex == .male ? "Hombre" : "Mujer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let birthDate = member.birthDate {
                        Text("Nacimiento: \(birthDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let deathDate = member.deathDate {
                        Text("Fallecimiento: \(deathDate, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button("Editar") {
                        showingEditMember = true
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.7))
                    .clipShape(Capsule())
                    
                    Button("Eliminar") {
                        memberToDelete = member
                        showingDeleteConfirmation = true
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.7))
                    .clipShape(Capsule())
                    
                    Button("Cerrar") {
                        withAnimation(.easeInOut) {
                            selectedMember = nil
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.7))
                    .clipShape(Capsule())
                }
            }
            
            // Member relationships
            if !getMemberRelationships(member.id).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Relaciones")
                        .font(.headline)
                    
                    ForEach(Array(getMemberRelationships(member.id)), id: \.id) { relationship in
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.blue)
                            Text("Relación")
                            Text("→")
                            Text(findMember(by: relationship.toMemberID)?.givenName ?? "Desconocido")
                                .foregroundColor(.secondary)
                        }
                        .font(.caption)
                    }
                }
            }
            
            // Member events - simplified for now
            VStack(alignment: .leading, spacing: 8) {
                Text("Información")
                    .font(.headline)
                
                Text("Miembro del árbol familiar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Pattern indicators
            if highlightedMembers.contains(member.id) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Patrones Detectados")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    let memberPatterns = getPatternsForMember(member.id)
                    ForEach(memberPatterns.prefix(2)) { pattern in
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(.orange)
                            Text(pattern.name)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(radius: 10)
        )
        .padding()
    }
    
    private func getMemberRelationships(_ memberId: UUID) -> [Relationship] {
        return psychogenealogyService.relationships.filter { 
            $0.fromMemberID == memberId || $0.toMemberID == memberId 
        }
    }
    
    private func getPatternsForMember(_ memberId: UUID) -> [Pattern] {
        let patterns = psychogenealogyService.detectedPatterns
        return patterns.filter { pattern in
            pattern.evidence.contains { evidence in
                evidence.memberID == memberId
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FamilyTreeCanvasView(psychogenealogyService: PsychogenealogyService.shared)
}