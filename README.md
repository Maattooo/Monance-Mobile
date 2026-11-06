# Monance Mobile

Monance Mobile is an offline-first, high-contrast personal finance companion application built with Flutter and Riverpod. It provides deterministic daily allowance tracking, recurring bill management, savings goal pacing, group expense splitting, and local data persistence.

---

## Overview

Monance Mobile operates entirely on-device without external server dependencies, cloud accounts, or tracking SDKs. All data is stored in a local relational SQLite database using Drift. Network permissions are explicitly omitted from the application manifest, ensuring complete data privacy and isolation.

The user interface follows a strict neobrutalist design system: zero border radiuses, high-contrast monochrome backgrounds with emerald green accents, and bundled Space Grotesk typography.

---

## Features

### 1. Dashboard and Savings Goal Engine
- Semi-circular progress gauge showing goal completion percentage.
- Real-time pacing metrics: Total Saved, Average Daily Savings, and Burn Rate percentage.
- Allowance day filtering: historical days prior to the active goal start date are strictly excluded to prevent double-counting.
- Direct wallet balance management with Add and Set balance modes.
- Goal completion and archiving with atomic balance transfer and one-tap undo restoration.
- Smart Budget Tip generator providing contextual spending recommendations.

### 2. Calendar and Daily Allowance Ledger
- Forty-two cell calendar grid displaying monthly activity dots.
- Daily modal supporting work/school allowance tracking and rest days.
- Interactive badge toggling between remaining daily allowance and total daily spend across all expense sources.
- Expense ledger with category tagging, deletion, and deduction source selection (Allowance or Wallet).
- Protection against overspending: wallet deductions are isolated from allowance calculations.

### 3. Spending Analytics
- Category breakdown with proportional visual progress bars.
- Custom-painted donut chart visualizing expense distribution.
- Period filtering: All Time, Thirty Days, Seven Days, and Custom Month.
- Month-over-Month spending comparisons.
- Fallback color mapping for custom or deleted categories.

### 4. Recurring Bills Management
- Monthly recurring bills tracking with due day indicators (Paid, Overdue, Due Today, Due in X days).
- Automatic monthly rollover handling.
- Short-month clamping algorithm for months with fewer than 31 days (for example, February 28 or 29).
- Square toggle checkboxes for marking bills as paid or unpaid.
- Master bills reset action for new billing cycles.

### 5. Hangouts and Group Expense Splitting
- Session-based group expense tracker.
- Automatic remainder absorption: penny discrepancies during equal splits are absorbed by the payer.
- Pairwise zero-net debt settlement algorithm ("Who Owes Whom").
- Idempotent calendar logging: merges user share into daily calendar records without creating duplicate entries.

### 6. Security and Offline Privacy
- Zero internet permissions in the Android application manifest.
- Optional 4-digit PIN lock screen with salted HMAC-SHA256 hashing stored in Android Keystore / EncryptedSharedPreferences.
- Automatic verification on fourth digit entry with input clearance on failure.
- Screen-off lifecycle listener: keeps session active while switching applications, re-locking when the device screen turns off or locks.
- Global privacy masking toggle: replaces sensitive currency figures with asterisks across all views.
- Atomic offline JSON backup and restore covering all relational tables.

---

## Technical Stack

- Framework: Flutter (Dart 3)
- State Management: Riverpod (StateNotifier and Providers)
- Database: Drift with native SQLite bindings (sqlite3_flutter_libs)
- Secure Storage: flutter_secure_storage
- Cryptography: crypto (HMAC-SHA256)
- Local Notifications: flutter_local_notifications
- Backup and File Sharing: file_picker, share_plus
- Typography: Space Grotesk (bundled locally in TTF format)

---

## Project Structure

```
lib/
|-- core/
|   |-- constants/         # Category definitions and design constants
|   |-- database/          # Drift database schema, tables, and DAOs
|   |-- theme/             # Neobrutalist design system and color palette
|   `-- utils/             # Currency, date, and math utilities
|-- models/                # Immutable domain data models
|-- providers/             # Riverpod state notifiers and computation engines
|-- services/              # Backup, security, and notification services
`-- views/
    |-- analytics/         # Analytics view, donut chart, category bars
    |-- bills/             # Bills view, rollover handler, bill modals
    |-- calendar/          # Calendar grid view and daily allowance modal
    |-- dashboard/         # Dashboard view, goal gauge, add money modal
    |-- hangouts/          # Hangouts list, split view, settlement cards
    |-- security/          # PIN lock screen and authentication gates
    |-- settings/          # Settings panel view and accordion sections
    `-- main_shell_view.dart # Root navigation shell with persistent bottom bar
```

---

## Getting Started

### Prerequisites

- Flutter SDK version 3.24.0 or higher
- Android SDK version 34 or higher (Android API level 36 compile SDK recommended)
- Java Development Kit (JDK) 17 or higher

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/MonanceMobile.git
   cd MonanceMobile
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate Drift database bindings:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Verify code quality:
   ```bash
   flutter analyze
   flutter test
   ```

5. Run the application on a connected device or emulator:
   ```bash
   flutter run
   ```

### Building the Release APK

To compile an optimized, standalone release APK for distribution:

```bash
flutter build apk --release
```

The resulting package will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Testing

The project maintains test suites covering financial calculations, database migrations, state immutability, and widget interactions:

```bash
# Run all unit and widget tests
flutter test

# Run a specific test suite
flutter test test/goal_calculations_test.dart
flutter test test/calendar_daily_modal_test.dart
flutter test test/hangouts_view_test.dart
flutter test test/backup_restore_test.dart
```

---

## Made by Maattooo
