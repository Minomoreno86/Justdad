//
//  OnboardingStepGoalsView.swift
//  JustDad - Goals step in onboarding
//
//  Goal setting and personalization
//

import SwiftUI

struct OnboardingStepGoalsView: View {
    @State private var selectedGoals: Set<FatheringGoal> = []
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Goals Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "target")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 20) {
                Text("What's Important to You?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Select the areas where you'd like to grow as a father. You can change these anytime in settings.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(FatheringGoal.allCases, id: \.self) { goal in
                    GoalCard(
                        goal: goal,
                        isSelected: selectedGoals.contains(goal)
                    ) {
                        if selectedGoals.contains(goal) {
                            selectedGoals.remove(goal)
                        } else {
                            selectedGoals.insert(goal)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if !selectedGoals.isEmpty {
                Text("\(selectedGoals.count) goals selected")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

enum FatheringGoal: String, CaseIterable {
    case emotionalWellness = "Emotional Wellness"
    case qualityTime = "Quality Time"
    case financialPlanning = "Financial Planning"
    case healthyHabits = "Healthy Habits"
    case workLifeBalance = "Work-Life Balance"
    case communication = "Communication"
    
    var icon: String {
        switch self {
        case .emotionalWellness: return "heart.circle.fill"
        case .qualityTime: return "clock.fill"
        case .financialPlanning: return "dollarsign.circle.fill"
        case .healthyHabits: return "leaf.circle.fill"
        case .workLifeBalance: return "scale.3d"
        case .communication: return "bubble.left.and.bubble.right.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .emotionalWellness: return .red
        case .qualityTime: return .blue
        case .financialPlanning: return .green
        case .healthyHabits: return .mint
        case .workLifeBalance: return .purple
        case .communication: return .orange
        }
    }
}

struct GoalCard: View {
    let goal: FatheringGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: goal.icon)
                    .font(.title)
                    .foregroundColor(isSelected ? .white : goal.color)
                
                Text(goal.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? goal.color : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? goal.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingStepGoalsView()
}
