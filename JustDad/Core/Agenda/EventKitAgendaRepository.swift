//
//  EventKitAgendaRepository.swift
//  JustDad - EventKit Calendar Integration
//
//  EventKit integration aligned to AgendaVisit model, with safe permissions and fallbacks.

import Foundation
import EventKit
import UserNotifications
import Combine

@MainActor
final class EventKitAgendaRepository: ObservableObject, AgendaRepositoryProtocol {

    // MARK: - Published state
    @Published var permissionStatus: AgendaPermissionStatus = .notDetermined
    @Published var notificationPermissionGranted: Bool = false

    // MARK: - Private
    private let eventStore = EKEventStore()
    private let calendar = Calendar.current
    private var cachedRange: DateInterval?
    private let subject = CurrentValueSubject<[AgendaVisit], Never>([])
    private var cancellables = Set<AnyCancellable>()

    // Minimal in-memory fallback (no depende de otras clases)
    private var memoryStore: [AgendaVisit] = []

    // MARK: - Init
    init() {
        checkCurrentPermissions()
        requestNotificationPermission()
    }

    // MARK: - AgendaRepositoryProtocol (AgendaVisit API)

    /// Devuelve visitas para un rango. Si `dateRange == nil`, usa ±1 año.
    func getVisits(for dateRange: DateInterval?) async throws -> [AgendaVisit] {
        if !permissionStatus.isAuthorized {
            let range = dateRange ?? DateInterval(
                start: calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
                end:   calendar.date(byAdding: .year, value:  1, to: Date()) ?? Date()
            )
            return memoryStore.filter { range.contains($0.startDate) || range.contains($0.endDate) }
        }

        let range = dateRange ?? DateInterval(
            start: calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            end:   calendar.date(byAdding: .year, value:  1, to: Date()) ?? Date()
        )
        cachedRange = range

        return await withCheckedContinuation { cont in
            let pred = eventStore.predicateForEvents(withStart: range.start, end: range.end, calendars: nil)
            let events = eventStore.events(matching: pred)
            let visits = events.map(Self.mapToAgendaVisit(_:))
            subject.send(visits)
            cont.resume(returning: visits)
        }
    }

    func createVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        if !permissionStatus.isAuthorized {
            memoryStore.insert(visit, at: 0)
            return visit
        }

        let event = EKEvent(eventStore: eventStore)
        Self.fill(event: event, from: visit)
        event.calendar = eventStore.defaultCalendarForNewEvents

        // Alarma (si hay reminder)
        if let minutes = visit.reminderMinutes {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-minutes * 60))
            event.addAlarm(alarm)
        }

        // Recurrencia (opcional): usa tu struct RecurrenceRule (frequency + interval)
        if let rule = visit.recurrenceRule, visit.isRecurring, rule.frequency != .none {
            event.recurrenceRules = [createRecurrenceRule(rule)]
        }

        do {
            try eventStore.save(event, span: .thisEvent)
            var saved = visit
            saved.eventKitIdentifier = event.eventIdentifier

            // Notificación local
            if notificationPermissionGranted, let minutes = visit.reminderMinutes {
                await scheduleNotification(for: saved, minutesBefore: minutes)
            }

            // Actualiza cache si aplica
            if let range = cachedRange,
               event.startDate >= range.start && event.startDate <= range.end {
                var current = subject.value
                current.insert(Self.mapToAgendaVisit(event), at: 0)
                subject.send(current)
            }
            return saved
        } catch {
            // Fallback in-memory si falla EventKit
            memoryStore.insert(visit, at: 0)
            return visit
        }
    }

    func updateVisit(_ visit: AgendaVisit) async throws -> AgendaVisit {
        if !permissionStatus.isAuthorized {
            if let idx = memoryStore.firstIndex(where: { $0.id == visit.id }) {
                memoryStore[idx] = visit
            } else {
                memoryStore.insert(visit, at: 0)
            }
            return visit
        }

        if let ekId = visit.eventKitIdentifier,
           let event = eventStore.event(withIdentifier: ekId) {
            Self.fill(event: event, from: visit)

            // Alarms: elimina todas y re-agrega si procede (sin force unwrap)
            if let alarms = event.alarms {
                for alarm in alarms { 
                    event.removeAlarm(alarm) 
                }
            }
            if let minutes = visit.reminderMinutes {
                let alarm = EKAlarm(relativeOffset: TimeInterval(-minutes * 60))
                event.addAlarm(alarm)
            }

            // Recurrencia
            if let rule = visit.recurrenceRule, visit.isRecurring, rule.frequency != .none {
                event.recurrenceRules = [createRecurrenceRule(rule)]
            } else {
                event.recurrenceRules = nil
            }

            do {
                try eventStore.save(event, span: .thisEvent)
                reloadCachedRange()
                return visit
            } catch {
                return visit // silencioso en MVP
            }
        } else {
            // No existe en EK → crear
            return try await createVisit(visit)
        }
    }

    func deleteVisit(withId id: UUID) async throws {
        if !permissionStatus.isAuthorized {
            memoryStore.removeAll { $0.id == id }
            return
        }

        let range = cachedRange ?? DateInterval(
            start: calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date(),
            end:   calendar.date(byAdding: .year, value:  1, to: Date()) ?? Date()
        )
        let pred = eventStore.predicateForEvents(withStart: range.start, end: range.end, calendars: nil)
        let events = eventStore.events(matching: pred)

        // Heurística: buscamos por identifier mapeado desde la cache actual
        if let match = events.first(where: { Self.mapToAgendaVisit($0).id == id }),
           let ekId = match.eventIdentifier,
           let event = eventStore.event(withIdentifier: ekId) {
            do {
                try eventStore.remove(event, span: .thisEvent)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
                reloadCachedRange()
            } catch {
                // Ignorar en MVP
            }
        } else {
            // Si no se encontró, elimina de memoria por si estuviera en fallback
            memoryStore.removeAll { $0.id == id }
        }
    }

    func requestCalendarPermission() async throws {
        let granted = await withCheckedContinuation { cont in
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    cont.resume(returning: granted && (error == nil))
                }
            } else {
                eventStore.requestAccess(to: .event) { granted, error in
                    cont.resume(returning: granted && (error == nil))
                }
            }
        }
        permissionStatus = granted ? .authorized : .denied
        if !granted { throw AgendaError.permissionDenied }
    }

    // MARK: - Permissions

    private func checkCurrentPermissions() {
        permissionStatus = AgendaPermissionStatus.from(ekStatus: EKEventStore.authorizationStatus(for: .event))
    }

    private func requestNotificationPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                notificationPermissionGranted = granted
            } catch {
                notificationPermissionGranted = false
            }
        }
    }

    // MARK: - Mapping

    private static func mapToAgendaVisit(_ e: EKEvent) -> AgendaVisit {
        let visitType: AgendaVisitType = {
            let t = (e.notes ?? e.title ?? "").lowercased()
            if t.contains("weekend") || t.contains("fin de semana") { return .weekend }
            if t.contains("dinner")  || t.contains("cena")          { return .dinner  }
            if t.contains("school")  || t.contains("colegio")        { return .school  }
            if t.contains("medical") || t.contains("médico")         { return .medical }
            return .activity
        }()

        let reminderMinutes: Int? = {
            guard let offset = e.alarms?.first?.relativeOffset else { return nil }
            let mins = Int(-offset / 60.0)
            return mins >= 0 ? mins : nil
        }()

        return AgendaVisit(
            id: UUID(), // Para estabilidad real, persiste mapping UUID <-> eventIdentifier en Core Data
            title: e.title ?? "Sin título",
            startDate: e.startDate,
            endDate: e.endDate,
            location: e.location,
            notes: e.notes,
            reminderMinutes: reminderMinutes,
            isRecurring: e.hasRecurrenceRules,
            recurrenceRule: nil, // TODO: mapear e.recurrenceRules → RecurrenceRule
            visitType: visitType,
            eventKitIdentifier: e.eventIdentifier
        )
    }

    private static func fill(event: EKEvent, from v: AgendaVisit) {
        event.title = v.title
        event.startDate = v.startDate
        event.endDate = v.endDate
        event.location = v.location
        event.notes = v.notes
    }

    // MARK: - Recurrence (EK) ←→ RecurrenceRule (propia)

    private func createRecurrenceRule(_ rule: RecurrenceRule) -> EKRecurrenceRule {
        // Tu RecurrenceRule es una struct con .frequency + .interval
        let frequency: EKRecurrenceFrequency
        switch rule.frequency {
        case .none:
            // Esto no debería llamarse si frequency es .none
            frequency = .weekly
        case .daily:   
            frequency = .daily
        case .weekly:  
            frequency = .weekly
        case .monthly: 
            frequency = .monthly
        }
        let interval = max(1, rule.interval)
        return EKRecurrenceRule(recurrenceWith: frequency, interval: interval, end: nil)
    }

    // MARK: - Notifications

    private func scheduleNotification(for visit: AgendaVisit, minutesBefore: Int) async {
        guard notificationPermissionGranted else { return }
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.visit.title", comment: "Visit Reminder")
        content.body = String(
            format: NSLocalizedString("notification.visit.body", comment: "Your visit '%@' starts in %d minutes"),
            visit.title, minutesBefore
        )
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .minute, value: -minutesBefore, to: visit.startDate) ?? visit.startDate
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: visit.id.uuidString, content: content, trigger: trigger)

        do { try await UNUserNotificationCenter.current().add(req) } catch { /* ignore in MVP */ }
    }

    // MARK: - Cache reload

    private func reloadCachedRange() {
        guard let range = cachedRange else { return }
        Task { _ = try? await getVisits(for: range) }
    }
}