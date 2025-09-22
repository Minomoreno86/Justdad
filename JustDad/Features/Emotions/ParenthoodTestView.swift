//
//  ParenthoodTestView.swift
//  JustDad - Interactive Parenthood Assessment
//
//  Professional test interface for fathers
//

import SwiftUI

struct ParenthoodTestView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var testService = ParenthoodTestService.shared
    
    let testType: ParenthoodTestService.TestType
    @State private var currentQuestionIndex = 0
    @State private var answers: [Int] = []
    @State private var showingResult = false
    @State private var testResult: TestResult?
    
    private var currentQuestion: TestQuestion? {
        guard currentQuestionIndex < testService.getQuestions(for: testType).count else { return nil }
        return testService.getQuestions(for: testType)[currentQuestionIndex]
    }
    
    private var progress: Double {
        guard !testService.getQuestions(for: testType).isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(testService.getQuestions(for: testType).count)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showingResult, let result = testResult {
                    TestResultView(result: result) {
                        dismiss()
                    }
                } else {
                    testContent
                }
            }
            .navigationTitle(testType.title)
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
    
    private var testContent: some View {
        VStack(spacing: 24) {
            // Progress Header
            VStack(spacing: 16) {
                HStack {
                    Text("Pregunta \(currentQuestionIndex + 1) de \(testService.getQuestions(for: testType).count)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(testType.estimatedTime)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(testType.color.opacity(0.1))
                        .foregroundColor(testType.color)
                        .cornerRadius(12)
                }
                
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle(tint: testType.color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Question Content
            if let question = currentQuestion {
                ScrollView {
                    VStack(spacing: 24) {
                        // Question
                        VStack(alignment: .leading, spacing: 16) {
                            if let category = question.category {
                                Text(category)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(testType.color)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(testType.color.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            Text(question.text)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(UIColor.systemBackground))
                                .shadow(color: testType.color.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        
                        // Answer Options
                        LazyVStack(spacing: 12) {
                            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                                AnswerOptionButton(
                                    text: option,
                                    isSelected: answers.count > currentQuestionIndex && answers[currentQuestionIndex] == index + 1,
                                    color: testType.color
                                ) {
                                    selectAnswer(index + 1)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // Navigation Buttons
            HStack(spacing: 16) {
                if currentQuestionIndex > 0 {
                    Button("Anterior") {
                        previousQuestion()
                    }
                    .buttonStyle(TestSecondaryButtonStyle())
                }
                
                Spacer()
                
                Button(currentQuestionIndex == testService.getQuestions(for: testType).count - 1 ? "Finalizar" : "Siguiente") {
                    if currentQuestionIndex == testService.getQuestions(for: testType).count - 1 {
                        completeTest()
                    } else {
                        nextQuestion()
                    }
                }
                    .buttonStyle(TestPrimaryButtonStyle(color: testType.color))
                .disabled(answers.count <= currentQuestionIndex)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
    
    private func selectAnswer(_ answer: Int) {
        if answers.count > currentQuestionIndex {
            answers[currentQuestionIndex] = answer
        } else {
            answers.append(answer)
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < testService.getQuestions(for: testType).count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    private func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    private func completeTest() {
        testResult = testService.calculateResult(for: testType, answers: answers)
        showingResult = true
    }
}

// MARK: - Answer Option Button
struct AnswerOptionButton: View {
    let text: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : Color(UIColor.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Test Result View
struct TestResultView: View {
    let result: TestResult
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Result Header
                VStack(spacing: 16) {
                    Image(systemName: result.testType.icon)
                        .font(.system(size: 60))
                        .foregroundColor(result.level.color)
                    
                    Text(result.level.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(result.level.color)
                    
                    Text(result.level.description)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Score
                    VStack(spacing: 8) {
                        Text("Tu puntuación")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("\(result.score)/\(result.maxScore)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(result.level.color)
                        
                        Text("\(Int(result.percentage))%")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(result.level.color.opacity(0.1))
                    )
                }
                .padding()
                
                // Recommendations
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recomendaciones para ti")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(Array(result.recommendations.enumerated()), id: \.offset) { index, recommendation in
                            RecommendationCard(
                                text: recommendation,
                                number: index + 1,
                                color: result.level.color
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button("Tomar otro test") {
                        onDismiss()
                    }
                    .buttonStyle(TestSecondaryButtonStyle())
                    
                    Button("Compartir resultado") {
                        // TODO: Implement sharing
                    }
                    .buttonStyle(TestPrimaryButtonStyle(color: result.level.color))
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
    }
}

// MARK: - Recommendation Card
struct RecommendationCard: View {
    let text: String
    let number: Int
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(color))
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Button Styles
struct TestPrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TestSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ParenthoodTestView(testType: .emotionalReadiness)
}
