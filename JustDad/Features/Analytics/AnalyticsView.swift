//
//  AnalyticsView.swift
//  JustDad - Analytics and Reports Dashboard
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var visits: [SimpleVisit] = []
    @State private var isLoading = false
    @State private var selectedPeriod: TimePeriod = .month
    @State private var showingFullReport = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case quarter = "Trimestre"
        case year = "Año"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with period selector
                    headerSection
                    
                    // Quick metrics cards
                    quickMetricsSection
                    
                    // Charts section
                    chartsSection
                    
                    // Insights section
                    insightsSection
                    
                    // Actions section
                    actionsSection
                    
                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 16)
            }
            .background(
                LinearGradient(
                    colors: [Color.white, Color.gray.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Analytics")
            .refreshable {
                await loadAnalytics()
            }
        }
        .sheet(isPresented: $showingFullReport) {
            FullReportView()
        }
        .task {
            await loadAnalytics()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dashboard Analytics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Insights sobre tus visitas y tiempo de calidad")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: generateFullReport) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                        Text("Reporte")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
            }
            
            // Period selector
            Picker("Período", selection: $selectedPeriod) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .background(.regularMaterial)
            .cornerRadius(8)
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Quick Metrics Section
    private var quickMetricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Métricas Rápidas")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                MetricCard(
                    title: "Hoy",
                    value: "\(todayVisitsCount)",
                    subtitle: "visitas",
                    icon: "calendar.circle.fill",
                    color: .blue
                )
                
                MetricCard(
                    title: "Esta semana",
                    value: "\(thisWeekVisitsCount)",
                    subtitle: "visitas",
                    icon: "calendar.badge.clock",
                    color: .green
                )
                
                MetricCard(
                    title: "Este mes",
                    value: "\(thisMonthVisitsCount)",
                    subtitle: "visitas",
                    icon: "calendar.badge.plus",
                    color: .orange
                )
                
                MetricCard(
                    title: "Total",
                    value: "\(visits.count)",
                    subtitle: "visitas",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Charts Section
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Análisis Visual")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Monthly trends chart
            if !monthlyData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tendencia Mensual")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Chart(monthlyData) { data in
                        LineMark(
                            x: .value("Mes", data.month, unit: .month),
                            y: .value("Visitas", data.count)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        
                        AreaMark(
                            x: .value("Mes", data.month, unit: .month),
                            y: .value("Visitas", data.count)
                        )
                        .foregroundStyle(.blue.opacity(0.1))
                    }
                    .frame(height: 150)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month)) { _ in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                }
            }
            
            // Visit type distribution
            if !visitTypeData.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Distribución por Tipo")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Chart(visitTypeData, id: \.type) { data in
                        BarMark(
                            x: .value("Tipo", data.type.displayName),
                            y: .value("Cantidad", data.count)
                        )
                        .foregroundStyle(by: .value("Tipo", data.type.displayName))
                        .cornerRadius(4)
                    }
                    .frame(height: 120)
                    .chartForegroundStyleScale(range: [
                        .blue, .green, .orange, .purple, .red
                    ])
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights Personalizados")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ForEach(insights, id: \.title) { insight in
                InsightCard(insight: insight)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Text("Acciones Rápidas")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                Button(action: generateFullReport) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Generar Reporte Completo")
                        Spacer()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isLoading)
                
                Button(action: exportAnalytics) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text("Exportar Datos")
                        Spacer()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Button(action: configureGoals) {
                    HStack {
                        Image(systemName: "target")
                        Text("Configurar Objetivos")
                        Spacer()
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Computed Properties
    private var todayVisitsCount: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return visits.filter { visit in
            Calendar.current.isDate(visit.scheduledDate, inSameDayAs: today)
        }.count
    }
    
    private var thisWeekVisitsCount: Int {
        let calendar = Calendar.current
        let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date())
        return visits.filter { visit in
            weekInterval?.contains(visit.scheduledDate) ?? false
        }.count
    }
    
    private var thisMonthVisitsCount: Int {
        let calendar = Calendar.current
        let monthInterval = calendar.dateInterval(of: .month, for: Date())
        return visits.filter { visit in
            monthInterval?.contains(visit.scheduledDate) ?? false
        }.count
    }
    
    private var monthlyData: [MonthlyVisitData] {
        let calendar = Calendar.current
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        
        var monthlyGroups: [Date: Int] = [:]
        
        for visit in visits where visit.scheduledDate >= sixMonthsAgo {
            let monthStart = calendar.dateInterval(of: .month, for: visit.scheduledDate)?.start ?? visit.scheduledDate
            monthlyGroups[monthStart, default: 0] += 1
        }
        
        return monthlyGroups.map { MonthlyVisitData(month: $0.key, count: $0.value) }
            .sorted { $0.month < $1.month }
    }
    
    private var visitTypeData: [VisitTypeData] {
        var typeGroups: [SimpleVisitType: Int] = [:]
        
        for visit in visits {
            typeGroups[visit.type, default: 0] += 1
        }
        
        return typeGroups.map { VisitTypeData(type: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private var insights: [AnalyticsInsight] {
        var insightsList: [AnalyticsInsight] = []
        
        // Total visits insight
        insightsList.append(AnalyticsInsight(
            title: "Total de Visitas",
            description: "Has registrado \(visits.count) visitas en total",
            icon: "calendar.badge.checkmark",
            color: .blue
        ))
        
        // This month comparison
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let lastMonthInterval = Calendar.current.dateInterval(of: .month, for: lastMonth)
        let lastMonthCount = visits.filter { visit in
            lastMonthInterval?.contains(visit.scheduledDate) ?? false
        }.count
        
        let monthlyChange = thisMonthVisitsCount - lastMonthCount
        if monthlyChange > 0 {
            insightsList.append(AnalyticsInsight(
                title: "Tendencia Positiva",
                description: "+\(monthlyChange) visitas este mes vs el anterior",
                icon: "arrow.up.circle.fill",
                color: .green
            ))
        } else if monthlyChange < 0 {
            insightsList.append(AnalyticsInsight(
                title: "Menos Visitas",
                description: "\(abs(monthlyChange)) visitas menos este mes",
                icon: "arrow.down.circle.fill",
                color: .orange
            ))
        }
        
        // Favorite visit type
        if let favoriteType = visitTypeData.first {
            insightsList.append(AnalyticsInsight(
                title: "Tipo Favorito",
                description: "\(favoriteType.type.displayName) es tu actividad más frecuente (\(favoriteType.count) veces)",
                icon: "heart.fill",
                color: .pink
            ))
        }
        
        return insightsList
    }
    
    // MARK: - Helper Methods
    private func loadAnalytics() async {
        // Simular carga de datos con algunos datos de ejemplo
        let sampleVisits = [
            SimpleVisit(scheduledDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                       type: .parque, title: "Visita al parque"),
            SimpleVisit(scheduledDate: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                       type: .cine, title: "Película familiar"),
            SimpleVisit(scheduledDate: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date(),
                       type: .casa, title: "Tiempo en casa"),
            SimpleVisit(scheduledDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date(),
                       type: .restaurante, title: "Almuerzo especial"),
            SimpleVisit(scheduledDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
                       type: .escuela, title: "Evento escolar")
        ]
        
        await MainActor.run {
            visits = sampleVisits
            isLoading = false
        }
    }
    
    private func generateFullReport() {
        showingFullReport = true
    }
    
    private func exportAnalytics() {
        print("Exporting analytics...")
    }
    
    private func configureGoals() {
        print("Configuring goals...")
    }
}

// MARK: - Supporting Data Structures
struct SimpleVisit {
    let id = UUID()
    let scheduledDate: Date
    let type: SimpleVisitType
    let title: String
    
    init(scheduledDate: Date, type: SimpleVisitType, title: String) {
        self.scheduledDate = scheduledDate
        self.type = type
        self.title = title
    }
}

enum SimpleVisitType: String, CaseIterable {
    case parque = "Parque"
    case cine = "Cine"
    case casa = "Casa"
    case restaurante = "Restaurante"
    case escuela = "Escuela"
    
    var displayName: String {
        return self.rawValue
    }
}

struct MonthlyVisitData: Identifiable {
    let id = UUID()
    let month: Date
    let count: Int
}

struct VisitTypeData {
    let type: SimpleVisitType
    let count: Int
}

struct AnalyticsInsight {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Supporting Views
struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

struct InsightCard: View {
    let insight: AnalyticsInsight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .foregroundColor(insight.color)
                .font(.title2)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(insight.color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FullReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Reporte Completo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Aquí aparecerá el reporte detallado con todas las métricas y análisis de tus visitas.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .padding()
            }
            .navigationTitle("Reporte")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Compartir") {
                        // TODO: Implement share
                    }
                }
            }
        }
    }
}

#Preview {
    AnalyticsView()
}
