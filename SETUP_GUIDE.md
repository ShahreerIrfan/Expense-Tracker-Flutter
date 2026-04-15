# Expense Tracker App - Setup & Build Guide

## Developer: Muhammad Shahreer Irfan

---

## Prerequisites

- **Flutter SDK** >= 3.11.4 (install from https://flutter.dev)
- **Android Studio** or **VS Code** with Flutter extension
- **Java JDK 17** (for Android builds)
- **Android SDK** (API 21+)

## Setup

### 1. Install Dependencies

```bash
cd "c:\Users\USERAS\Desktop\Expense"
flutter pub get
```

### 2. Generate Drift Database Code

Drift uses code generation. Run build_runner to generate the `.g.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `lib/database/app_database.g.dart`
- `lib/database/daos/*.g.dart`

### 3. Create Assets Directories

```bash
mkdir assets
mkdir assets\icons
```

### 4. Run the App (Debug)

```bash
flutter run
```

Or in VS Code: Press `F5` or use Run > Start Debugging.

## Building Release APK

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

The APK will be at:
```
build\app\outputs\flutter-apk\app-release.apk
```

### Split APKs (smaller size per architecture)
```bash
flutter build apk --split-per-abi --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
├── main.dart                  # Entry point
├── app.dart                   # MaterialApp with theme/locale/routes
├── core/
│   ├── constants/             # App constants, colors
│   ├── l10n/                  # Localizations (EN, BN)
│   ├── security/              # PIN auth, biometrics
│   └── theme/                 # Material 3 light/dark themes
├── data/
│   └── repositories/          # Repository implementations
├── database/
│   ├── app_database.dart      # Drift database definition
│   ├── daos/                  # Data Access Objects
│   └── tables/                # Table definitions
├── domain/
│   ├── entities/              # Business entities
│   └── repositories/          # Repository interfaces
├── presentation/
│   ├── navigation/            # App router, home shell
│   └── screens/               # All screen widgets
│       ├── about/
│       ├── accounts/
│       ├── auth/
│       ├── backup/
│       ├── budgets/
│       ├── categories/
│       ├── dashboard/
│       ├── expenses/
│       ├── income/
│       ├── reports/
│       ├── search/
│       ├── settings/
│       └── splash/
├── providers/                 # Riverpod state management
├── services/                  # Business services
└── utils/                     # Helpers, formatters, validators
```

## Key Features

1. **Multi-User Profiles** with PIN security
2. **Smart Dashboard** with balance overview and spending charts
3. **Expense & Income Tracking** with categories, accounts, tags
4. **Budget Management** with alerts at 50%/80%/100%
5. **Multiple Accounts** (Cash, Bank, Mobile Wallets) with transfers
6. **Custom Categories** with icons and colors
7. **Interactive Reports** (Pie charts, Bar charts) with PDF export
8. **Full-Text Search** with amount range filters
9. **CSV & JSON Backup/Restore**
10. **Dark/Light Theme** (Material 3)
11. **Multi-Language** (English & Bangla)
12. **Recurring Transactions**
13. **Voice Input** support
14. **AI-Powered Insights**
15. **Biometric Authentication**

## Tech Stack

- **Flutter** (Dart only - no HTML/CSS/JS)
- **Drift** ORM for SQLite
- **Riverpod** for state management
- **fl_chart** for charts
- **pdf** package for PDF export
- **Material 3** design system
- **Clean Architecture** (Data/Domain/Presentation layers)

## Troubleshooting

### "Cannot find .g.dart files"
Run: `dart run build_runner build --delete-conflicting-outputs`

### "Gradle build failed"
Ensure Java 17 is installed and JAVA_HOME is set.

### "SDK version mismatch"
Run: `flutter upgrade`

---

© 2025 Muhammad Shahreer Irfan
