# JustDad

> 👨‍👧‍👦 **A comprehensive iOS companion app for modern fathers**

JustDad is an offline-first iOS application built with SwiftUI that helps fathers track, organize, and navigate their parenting journey with privacy and security at its core. The app features professional-grade data persistence, emotional wellness tools, and financial tracking.

## 🏗 Architecture

### Tech Stack

- **Framework**: SwiftUI + MVVM
- **Storage**: SwiftData + SQLCipher (offline-first)
- **Security**: Keychain + Biometric Authentication + Data Encryption
- **Platform**: iOS 18.5+
- **Data Services**: Professional persistence layer with caching, sync, and migration

### Navigation Structure

- **Main Flow**: TabView with 5 core tabs
- **Modal Presentations**:
  - Onboarding (fullScreenCover)
  - Profile Settings (sheet)
  - Data Export (sheet)
- **Router**: Centralized NavigationRouter for deep linking

### Project Structure

```
JustDad/
├── App/                     # App entry point
├── Router/                  # Navigation system
├── Features/                # Feature modules
│   ├── Onboarding/         # Welcome flow
│   ├── Home/               # Dashboard with real-time data
│   ├── Agenda/             # Visits & appointments
│   ├── Finance/            # Expense tracking with receipt scanning
│   ├── Emotions/           # Mood tracking & wellness tools
│   ├── Journal/            # Personal entries with audio
│   └── Settings/           # App configuration & profile
├── UI/
│   ├── Components/         # Reusable UI components
│   ├── Theme/              # Design tokens
│   └── Widgets/            # Complex UI widgets
├── Core/
│   ├── Models/             # SwiftData models
│   ├── Security/           # Security services
│   ├── Services/           # Business logic
│   │   ├── ReceiptStorageService.swift    # Receipt processing
│   │   ├── DataSyncService.swift          # Data synchronization
│   │   ├── CacheService.swift             # Intelligent caching
│   │   └── DataMigrationService.swift     # Data migration
│   └── Persistence/        # Data management
└── Resources/
    └── Localizations/      # i18n strings
```

## 🎨 Theme Tokens

### Palette

- **Primary Colors**: `primary`, `secondary`, `accent`
- **Text Colors**: `textPrimary`, `textSecondary`
- **Brand Colors**: `blue`, `green`, `orange`, `red`, `yellow`, `gray`
- **Semantic**: `success`, `warning`, `error`, `info`

### Typography

- **Base**: `display`, `title`, `subtitle`, `headline`, `body`, `callout`, `caption`, `footnote`, `button`
- **Custom**: `cardTitle`, `buttonText`, `navigationTitle`

## 📊 Data Models

### SwiftData Models

- **Visit**: Medical appointments and checkups with attachments
- **FinancialEntry**: Expense tracking with receipt attachments
- **EmotionalEntry**: Mood tracking with wellness metrics
- **DiaryEntry**: Personal journal entries with audio/photo attachments
- **EmergencyContact**: Contact data model (reserved for potential future use)
- **UserPreferences**: App settings and preferences

### Professional Data Services

- **ReceiptStorageService**: Receipt processing with Vision framework
- **DataSyncService**: Automatic data synchronization with conflict resolution
- **CacheService**: Intelligent caching with memory management
- **DataMigrationService**: Version-controlled data migration

## 🧭 Navigation

### Routes

- Main features: `home`, `agenda`, `finance`, `emotions`, `settings`
- Sub-features: `newVisit`, `newExpense`, `quickTest`, `profileSettings`, `exportData`, etc.

### NavigationRouter API

```swift
NavigationRouter.shared.push(.newVisit)
NavigationRouter.shared.pop()
```

## 🔒 Privacy & Security

- **Offline-first**: All data stored locally with SwiftData
- **Encryption**: SQLCipher for database encryption + file encryption
- **Biometrics**: Face ID/Touch ID authentication
- **Data Protection**: Receipt images encrypted and stored securely
- **No tracking**: Zero analytics or data collection
- **Local backup**: Secure local backup with encryption
- **No cloud sync**: Optional in future versions

## 🚀 Development

### Phase 1 (Completed): Foundation ✅

- ✅ Navigation system with 5 tabs
- ✅ Theme tokens and design system
- ✅ SwiftData models and persistence
- ✅ Onboarding flow
- ✅ Professional data services
- ✅ Security and encryption
- ✅ Real-time data synchronization

### Phase 2 (Completed): Core Features ✅

- ✅ SwiftData implementation with encryption
- ✅ Receipt processing with Vision framework
- ✅ Intelligent caching system
- ✅ Data migration and versioning
- ✅ Biometric authentication
- ✅ Profile management
- ✅ Data export functionality

### Phase 3 (Current): Advanced Features 🔄

- 🔄 Widget extensions
- 🔄 Shortcuts integration
- 🔄 Advanced analytics
- 🔄 Enhanced emotional wellness tools
- 🔄 Receipt OCR improvements
- 🔄 Performance optimizations

### Phase 4 (Future): Platform Expansion

- Optional cloud sync
- Apple Watch companion
- macOS version
- Advanced AI features

## 🌍 Localization

Currently supports:

- **Spanish (es)**: Primary language
- **English (en)**: Secondary language

## 📱 Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 5.5+
- Vision framework (for receipt processing)
- AVFoundation (for audio recording)

## 🎯 Key Features

### 🏠 Home Dashboard

- Real-time data synchronization
- Recent activities tracking
- Quick access to all features
- Personalized insights

### 📅 Agenda Management

- Visit scheduling and tracking
- Reminder notifications
- Calendar integration
- Visit history and analytics

### 💰 Financial Tracking

- Expense categorization
- Receipt scanning with OCR
- Financial goals and budgets
- Professional analytics

### 😊 Emotional Wellness

- Mood tracking and journaling
- Audio note recording
- Wellness exercises
- Emotional archive

### ⚙️ Settings & Profile

- User profile management
- Data export and backup
- Security settings
- App preferences

---

**Built with ❤️ for fathers who want to be present and organized in their parenting journey.**
