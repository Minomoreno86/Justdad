import SwiftUI

// MARK: - Route Definition
enum Route: Hashable, CaseIterable {
    // MARK: - Main Routes
    case home
    case agenda
    case agendaDetail(visitId: String)
    case agendaAddVisit
    case finance
    case financeDetail(expenseId: String)
    case financeAdd
    case financeAllTransactions
    case journal
    case journalDetail(entryId: String)
    case journalNew
    // Unified Journal Routes
    case unifiedJournal
    case unifiedJournalDetail(entryId: String)
    case unifiedJournalNew
    case unifiedJournalFilter
    case emotions
    case emotionsDetail(date: Date)
    // Emotion Archive Routes
    case emotionArchive
    case emotionArchiveDetail(entryId: String)
    case emotionArchiveEdit(entryId: String)
    case community
    case communityPost(postId: String)
    case sos
    case settings
    
    // MARK: - Onboarding Routes
    case onboarding
    case onboardingWelcome
    case onboardingPrivacy
    case onboardingGoals
    
    // MARK: - Settings Routes
    case settingsProfile
    case settingsPrivacy
    case settingsTheme
    case settingsEmergencyContacts
    case settingsDataExport
    
    // MARK: - Emergency Routes
    case emergencyCall
    case emergencyContacts
}

// MARK: - Route Extension
extension Route {
    var title: String {
        switch self {
        case .home:
            return NSLocalizedString("home.title", comment: "")
        case .agenda:
            return NSLocalizedString("agenda.title", comment: "")
        case .agendaDetail:
            return NSLocalizedString("agenda.detail.title", comment: "")
        case .agendaAddVisit:
            return NSLocalizedString("agenda.add_visit.title", comment: "")
        case .finance:
            return NSLocalizedString("finance.title", comment: "")
        case .financeDetail:
            return NSLocalizedString("finance.detail.title", comment: "")
        case .financeAdd:
            return NSLocalizedString("finance.add.title", comment: "")
        case .financeAllTransactions:
            return NSLocalizedString("finance.all_transactions.title", comment: "")
        case .journal:
            return NSLocalizedString("journal.title", comment: "")
        case .journalDetail:
            return NSLocalizedString("journal.detail.title", comment: "")
        case .journalNew:
            return NSLocalizedString("journal.new.title", comment: "")
        case .unifiedJournal:
            return "Journal Unificado"
        case .unifiedJournalDetail:
            return "Detalle de Entrada"
        case .unifiedJournalNew:
            return "Nueva Entrada"
        case .unifiedJournalFilter:
            return "Filtros"
        case .emotions:
            return NSLocalizedString("emotions.title", comment: "")
        case .emotionsDetail:
            return NSLocalizedString("emotions.detail.title", comment: "")
        case .emotionArchive:
            return "Archivo de Emociones"
        case .emotionArchiveDetail:
            return "Detalle de Entrada"
        case .emotionArchiveEdit:
            return "Editar Entrada"
        case .community:
            return NSLocalizedString("community.title", comment: "")
        case .communityPost:
            return NSLocalizedString("community.post.title", comment: "")
        case .sos:
            return NSLocalizedString("sos.title", comment: "")
        case .settings:
            return NSLocalizedString("settings.title", comment: "")
        case .onboarding:
            return NSLocalizedString("onboarding.title", comment: "")
        case .onboardingWelcome:
            return NSLocalizedString("onboarding.welcome.title", comment: "")
        case .onboardingPrivacy:
            return NSLocalizedString("onboarding.privacy.title", comment: "")
        case .onboardingGoals:
            return NSLocalizedString("onboarding.goals.title", comment: "")
        case .settingsProfile:
            return NSLocalizedString("settings.profile.title", comment: "")
        case .settingsPrivacy:
            return NSLocalizedString("settings.privacy.title", comment: "")
        case .settingsTheme:
            return NSLocalizedString("settings.theme.title", comment: "")
        case .settingsEmergencyContacts:
            return NSLocalizedString("settings.emergency_contacts.title", comment: "")
        case .settingsDataExport:
            return NSLocalizedString("settings.data_export.title", comment: "")
        case .emergencyCall:
            return NSLocalizedString("emergency.call.title", comment: "")
        case .emergencyContacts:
            return NSLocalizedString("emergency.contacts.title", comment: "")
        }
    }
}

// MARK: - Route CaseIterable Conformance
extension Route {
    static var allCases: [Route] {
        return [
            .home,
            .agenda,
            .finance,
            .journal,
            .emotions,
            .community,
            .sos,
            .settings,
            .onboarding
        ]
    }
}