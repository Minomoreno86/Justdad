# JustDad

> 👨‍👧‍👦 **A comprehensive iOS companion app for modern fathers**

JustDad is an offline-first iOS application built with SwiftUI that helps fathers track, organize, and navigate their parenting journey with privacy and security at its core.

## 🏗 Architecture

### Tech Stack

- **Framework**: SwiftUI + MVVM
- **Storage**: CoreData + SQLCipher (offline-first)
- **Security**: Keychain + Biometric Authentication
- **Platform**: iOS 18.5+

### Navigation Structure

- **Main Flow**: TabView with 5 core tabs
- **Modal Presentations**:
  - Onboarding (fullScreenCover)
  - SOS Emergency (sheet)
- **Router**: Centralized NavigationRouter for deep linking

### Project Structure

```
JustDad/
├── App/                     # App entry point
├── Router/                  # Navigation system
├── Features/                # Feature modules
│   ├── Onboarding/         # Welcome flow
│   ├── Home/               # Dashboard
│   ├── Agenda/             # Visits & appointments
│   ├── Finance/            # Expense tracking
│   ├── Emotions/           # Mood tracking
│   ├── Journal/            # Personal entries
│   ├── Community/          # Dad community
│   ├── SOS/                # Emergency features
│   └── Settings/           # App configuration
├── UI/
│   ├── Components/         # Reusable UI components
│   ├── Theme/              # Design tokens
│   └── Widgets/            # Complex UI widgets
├── Core/
│   ├── Models/             # Data models & mock data
│   ├── Security/           # Security services
│   └── Services/           # Business logic
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

## 📊 Mock Models

For development and testing:

- **MockVisit**: Medical appointments and checkups
- **MockExpense**: Financial tracking entries
- **MockJournalEntry**: Personal diary entries (text/audio/photo)
- **MockCommunityPost**: Community discussions

## 🧭 Navigation

### Routes

- Main features: `home`, `agenda`, `finance`, `emotions`, `community`, `journal`, `settings`
- Sub-features: `newVisit`, `newExpense`, `quickTest`, `newPost`, etc.

### NavigationRouter API

```swift
NavigationRouter.shared.push(.newVisit)
NavigationRouter.shared.pop()
NavigationRouter.shared.presentSheet(.sos)
```

## 🔒 Privacy & Security

- **Offline-first**: All data stored locally
- **Encryption**: SQLCipher for database encryption
- **Biometrics**: Face ID/Touch ID authentication
- **No tracking**: Zero analytics or data collection
- **No cloud sync**: Optional in future versions

## 🚀 Development

### Phase 1 (Current): Foundation

- ✅ Navigation system
- ✅ Theme tokens
- ✅ Mock data
- ✅ Onboarding flow
- 🔄 Feature wireframes

### Phase 2 (Next): Core Data & Security

- CoreData implementation
- SQLCipher integration
- Keychain services
- Biometric authentication

### Phase 3 (Future): Advanced Features

- Widget extensions
- Shortcuts integration
- Export functionality
- Optional cloud sync

## 🌍 Localization

Currently supports:

- **Spanish (es)**: Primary language
- **English (en)**: Secondary language

## 📱 Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 5.5+

---

**Built with ❤️ for fathers who want to be present and organized in their parenting journey.**
