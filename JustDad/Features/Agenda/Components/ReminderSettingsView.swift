//
//  ReminderSettingsView.swift
//  JustDad - Reminder Settings Component
//
//  Allows users to configure reminder settings for visits
//

import SwiftUI

struct ReminderSettingsView: View {
    @Binding var reminderMinutes: Int?
    @State private var selectedOption: ReminderOption = .fifteenMinutes
    @State private var customMinutes: Int = 30
    
    enum ReminderOption: String, CaseIterable {
        case none = "none"
        case fiveMinutes = "5min"
        case fifteenMinutes = "15min"
        case thirtyMinutes = "30min"
        case oneHour = "1hour"
        case twoHours = "2hours"
        case custom = "custom"
        
        var displayName: String {
            switch self {
            case .none: return "Sin recordatorio"
            case .fiveMinutes: return "5 minutos antes"
            case .fifteenMinutes: return "15 minutos antes"
            case .thirtyMinutes: return "30 minutos antes"
            case .oneHour: return "1 hora antes"
            case .twoHours: return "2 horas antes"
            case .custom: return "Personalizado"
            }
        }
        
        var minutes: Int? {
            switch self {
            case .none: return nil
            case .fiveMinutes: return 5
            case .fifteenMinutes: return 15
            case .thirtyMinutes: return 30
            case .oneHour: return 60
            case .twoHours: return 120
            case .custom: return nil // Will use customMinutes
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.md) {
            // Header
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(SuperDesign.Tokens.colors.primary)
                
                Text("Recordatorio")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Spacer()
            }
            
            // Options
            VStack(spacing: SuperDesign.Tokens.space.sm) {
                ForEach(ReminderOption.allCases, id: \.self) { option in
                    ReminderOptionRow(
                        option: option,
                        isSelected: selectedOption == option,
                        customMinutes: $customMinutes,
                        onSelect: { selectedOption = option }
                    )
                }
            }
            
            // Custom minutes picker
            if selectedOption == .custom {
                VStack(alignment: .leading, spacing: SuperDesign.Tokens.space.xs) {
                    Text("Minutos antes:")
                        .font(.caption)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    
                    HStack {
                        Stepper(
                            value: $customMinutes,
                            in: 1...1440, // 1 minute to 24 hours
                            step: 5
                        ) {
                            Text("\(customMinutes) minutos")
                                .font(SuperDesign.Tokens.typography.bodyMedium)
                                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.top, SuperDesign.Tokens.space.sm)
            }
        }
                .padding(SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.surface)
        .cornerRadius(12)
        .onAppear {
            updateSelectedOption()
        }
        .onChange(of: selectedOption) { _, _ in
            updateReminderMinutes()
        }
        .onChange(of: customMinutes) { _, _ in
            if selectedOption == .custom {
                updateReminderMinutes()
            }
        }
    }
    
    private func updateSelectedOption() {
        guard let reminderMinutes = reminderMinutes else {
            selectedOption = .none
            return
        }
        
        if let option = ReminderOption.allCases.first(where: { $0.minutes == reminderMinutes }) {
            selectedOption = option
        } else {
            selectedOption = .custom
            customMinutes = reminderMinutes
        }
    }
    
    private func updateReminderMinutes() {
        if selectedOption == .custom {
            reminderMinutes = customMinutes
        } else {
            reminderMinutes = selectedOption.minutes
        }
    }
}

struct ReminderOptionRow: View {
    let option: ReminderSettingsView.ReminderOption
    let isSelected: Bool
    @Binding var customMinutes: Int
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Radio button
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? SuperDesign.Tokens.colors.primary : SuperDesign.Tokens.colors.textSecondary)
                    .font(.title3)
                
                // Option text
                Text(option.displayName)
                    .font(SuperDesign.Tokens.typography.bodyMedium)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Spacer()
                
                // Custom minutes display
                if option == .custom && isSelected {
                    Text("\(customMinutes) min")
                        .font(.caption)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                        .padding(.horizontal, SuperDesign.Tokens.space.xs)
                        .padding(.vertical, SuperDesign.Tokens.space.xxs)
                        .background(SuperDesign.Tokens.colors.surfaceSecondary)
                        .cornerRadius(6)
                }
            }
            .padding(.vertical, SuperDesign.Tokens.space.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        ReminderSettingsView(reminderMinutes: .constant(15))
        ReminderSettingsView(reminderMinutes: .constant(nil))
        ReminderSettingsView(reminderMinutes: .constant(45))
    }
    .padding()
    .background(SuperDesign.Tokens.colors.background)
}
