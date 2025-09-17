//
//  CalendarSelectionView.swift
//  JustDad - Calendar Selection
//
//  Professional calendar selection interface for EventKit integration
//

import SwiftUI
import EventKit

struct CalendarSelectionView: View {
    @StateObject private var calendarService = CalendarManagementService.shared
    @StateObject private var permissionService = EventKitPermissionService()
    @State private var availableCalendars: [CalendarInfo] = []
    @State private var isLoading = true
    @State private var selectedCalendar: CalendarInfo?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let onCalendarSelected: (CalendarInfo?) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if isLoading {
                    loadingView
                } else if availableCalendars.isEmpty {
                    emptyStateView
                } else {
                    calendarListView
                }
            }
            .background(SuperDesign.Tokens.colors.surface)
            .navigationBarHidden(true)
        }
        .task {
            await loadCalendars()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: SuperDesign.Tokens.space.md) {
            HStack {
                Button("Cancelar") {
                    onDismiss()
                }
                .foregroundColor(SuperDesign.Tokens.colors.primary)
                
                Spacer()
                
                Text("Seleccionar Calendario")
                    .font(SuperDesign.Tokens.typography.headlineLarge)
                    .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                
                Spacer()
                
                Button("Listo") {
                    onCalendarSelected(selectedCalendar)
                    onDismiss()
                }
                .foregroundColor(SuperDesign.Tokens.colors.primary)
                .fontWeight(.semibold)
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.top, SuperDesign.Tokens.space.sm)
            
            if !availableCalendars.isEmpty {
                    Text("Elige el calendario donde se guardarán tus visitas")
                        .font(SuperDesign.Tokens.typography.bodySmall)
                        .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    .padding(.horizontal, SuperDesign.Tokens.space.lg)
            }
        }
        .padding(.bottom, SuperDesign.Tokens.space.md)
        .background(SuperDesign.Tokens.colors.surface)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: SuperDesign.Tokens.space.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: SuperDesign.Tokens.colors.primary))
                .scaleEffect(1.2)
            
            Text("Cargando calendarios...")
                .font(SuperDesign.Tokens.typography.bodyMedium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: SuperDesign.Tokens.space.lg) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
            
            Text("No hay calendarios disponibles")
                .font(SuperDesign.Tokens.typography.headlineLarge)
                .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
            
            Text("Asegúrate de tener al menos un calendario configurado en la app Calendario de iOS")
                .font(SuperDesign.Tokens.typography.bodyMedium)
                .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SuperDesign.Tokens.space.lg)
            
            Button("Crear Calendario JustDad") {
                Task {
                    await createJustDadCalendar()
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Calendar List View
    
    private var calendarListView: some View {
        ScrollView {
            LazyVStack(spacing: SuperDesign.Tokens.space.sm) {
                ForEach(availableCalendars) { calendar in
                    CalendarRowView(
                        calendar: calendar,
                        isSelected: selectedCalendar?.id == calendar.id,
                        onTap: {
                            selectedCalendar = calendar
                        }
                    )
                }
            }
            .padding(.horizontal, SuperDesign.Tokens.space.lg)
            .padding(.bottom, SuperDesign.Tokens.space.xl)
        }
    }
    
    // MARK: - Actions
    
    private func loadCalendars() async {
        isLoading = true
        
        do {
            let calendars = try await calendarService.getAvailableCalendars()
            
            await MainActor.run {
                availableCalendars = calendars
                
                // Auto-select JustDad calendar if available
                if let justDadCalendar = calendars.first(where: { $0.title.contains("JustDad") }) {
                    selectedCalendar = justDadCalendar
                } else if let firstWritable = calendars.first(where: { $0.isWritable }) {
                    selectedCalendar = firstWritable
                }
                
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error al cargar calendarios: \(error.localizedDescription)"
                showingError = true
                isLoading = false
            }
        }
    }
    
    private func createJustDadCalendar() async {
        do {
            let calendar = try await calendarService.createJustDadCalendar()
            let calendarInfo = CalendarInfo(from: calendar)
            
            await MainActor.run {
                selectedCalendar = calendarInfo
                availableCalendars.insert(calendarInfo, at: 0)
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error al crear calendario: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

// MARK: - Calendar Row View

struct CalendarRowView: View {
    let calendar: CalendarInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SuperDesign.Tokens.space.md) {
                // Calendar color indicator
                Circle()
                    .fill(calendar.color)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(calendar.title)
                        .font(SuperDesign.Tokens.typography.titleMedium)
                        .foregroundColor(SuperDesign.Tokens.colors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: SuperDesign.Tokens.space.sm) {
                        if calendar.isWritable {
                            Label("Editable", systemImage: "pencil")
                                .font(SuperDesign.Tokens.typography.bodySmall)
                                .foregroundColor(SuperDesign.Tokens.colors.success)
                        } else {
                            Label("Solo lectura", systemImage: "eye")
                                .font(SuperDesign.Tokens.typography.bodySmall)
                                .foregroundColor(SuperDesign.Tokens.colors.warning)
                        }
                        
                        Text(calendarTypeText)
                            .font(SuperDesign.Tokens.typography.bodySmall)
                            .foregroundColor(SuperDesign.Tokens.colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(SuperDesign.Tokens.colors.primary)
                        .font(.system(size: 20))
                }
            }
            .padding(.vertical, SuperDesign.Tokens.space.sm)
            .padding(.horizontal, SuperDesign.Tokens.space.md)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? SuperDesign.Tokens.colors.primary.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? SuperDesign.Tokens.colors.primary : SuperDesign.Tokens.colors.textSecondary.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var calendarTypeText: String {
        return "Calendario"
    }
}

#Preview {
    CalendarSelectionView(
        onCalendarSelected: { _ in },
        onDismiss: { }
    )
}