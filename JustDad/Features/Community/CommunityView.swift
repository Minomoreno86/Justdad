//
//  CommunityView.swift
//  SoloPapá - Community/Support screen
//
//  Dad community posts and support
//

import SwiftUI

struct CommunityView: View {
    @StateObject private var router = NavigationRouter.shared
    @State private var posts: [MockCommunityPost] = MockData.communityPosts
    @State private var selectedCategory: String? = nil
    @State private var showingNewPost = false
    
    private let categories = ["Todos", "Consejos", "Preguntas", "Experiencias", "Emergencias"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category filter
                categoryFilter
                
                // Posts list
                if filteredPosts.isEmpty {
                    emptyState
                } else {
                    postsList
                }
            }
            .navigationTitle("Comunidad")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewPost = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                NewPostView()
            }
        }
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory == category || (selectedCategory == nil && category == "Todos")
                    ) {
                        selectedCategory = category == "Todos" ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No hay posts aún")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Sé el primero en compartir algo con la comunidad")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 50)
    }
    
    // MARK: - Posts List
    private var postsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredPosts) { post in
                    CommunityPostCard(post: post)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Computed Properties
    private var filteredPosts: [MockCommunityPost] {
        guard let selectedCategory = selectedCategory else {
            return posts
        }
        return posts.filter { $0.category == selectedCategory }
    }
}

// MARK: - Community Post Card
struct CommunityPostCard: View {
    let post: MockCommunityPost
    @StateObject private var router = NavigationRouter.shared
    @State private var isLiked: Bool
    @State private var likesCount: Int
    
    init(post: MockCommunityPost) {
        self.post = post
        self._isLiked = State(initialValue: post.isLiked)
        self._likesCount = State(initialValue: post.likesCount)
    }
    
    var body: some View {
        Button(action: {
            router.push(.communityPost(postId: post.id.uuidString))
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(post.author.prefix(1)))
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.author)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(post.date.formatted(.relative(presentation: .numeric)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    CategoryBadge(category: post.category)
                }
                
                // Content
                Text(post.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Actions
                HStack {
                    Button(action: toggleLike) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .gray)
                            Text("\(likesCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "bubble.right")
                                .foregroundColor(.gray)
                            Text("\(post.commentsCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleLike() {
        isLiked.toggle()
        likesCount += isLiked ? 1 : -1
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(categoryColor.opacity(0.2))
            .foregroundColor(categoryColor)
            .cornerRadius(8)
    }
    
    private var categoryColor: Color {
        switch category {
        case "Consejos":
            return .blue
        case "Preguntas":
            return .orange
        case "Experiencias":
            return .green
        case "Emergencias":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - New Post View
struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var selectedCategory = "Consejos"
    
    private let categories = ["Consejos", "Preguntas", "Experiencias", "Emergencias"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Título") {
                    TextField("¿Cuál es tu pregunta o tema?", text: $title)
                }
                
                Section("Categoría") {
                    Picker("Categoría", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("Publicar") {
                        // TODO: Add new post logic
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .navigationTitle("Nuevo Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CommunityView()
}