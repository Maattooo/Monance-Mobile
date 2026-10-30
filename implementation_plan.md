# Monance Mobile — Full Implementation Plan

This implementation plan decomposes the migration of `MonanceMobile` from its legacy online prototype into the 100% offline, brutalist, type-safe SQLite personal finance mobile app specified in `specification.md`.

---

## Phase 1: Foundation, Purge & Drift SQLite Database Layer
**Routing: PRO**

### Scope
- Clean out legacy online networking files, services, models, and dependencies.
- Remove internet permissions from `android/app/src/main/AndroidManifest.xml`.
- Update `pubspec.yaml` with required offline dependencies (`drift`, `sqlite3_flutter_libs`, `flutter_secure_storage`, `local_auth`, `flutter_local_notifications`, `timezone`, `file_picker`, `share_plus`, `drift_dev`, `build_runner`) and remove `dio`, `go_router`, `shared_preferences`, `table_calendar`.
- Bundle `SpaceGrotesk` TTF fonts (`Regular`, `Medium`, `SemiBold`, `Bold`) inside `assets/fonts/` and register them in `pubspec.yaml`.
- Define Drift SQLite tables (`SettingsTable`, `DailyRecordsTable`, `ExpensesTable`, `MonthlyBillsTable`, `CategoriesTable`, `GoalHistoryTable`, `HangoutSessionsTable`, `HangoutExpensesTable`) in `lib/core/database/tables.dart`.
- Implement `AppDatabase` in `lib/core/database/app_database.dart` and execute `build_runner` to generate `app_database.g.dart`.
- Verify database compilation and basic schema tests.

---

## Phase 2: Core Calculation Engines & Automated Test Suite (TDD)
**Routing: PRO**

### Scope
- Implement exact business logic engines matching `specification.md` Section 6:
  1. **Derived Wallet Balance Engine (`derivedWalletBalanceProvider`):** Invariant base balance, allowance day deductions vs non-allowance day deductions.
  2. **Goal Progress, Pacing, & Archive Engine (`goal_calculation_provider.dart`):** Filter for allowance days `>= goalStartDate`, `burnRatePercent`, pacing status (`On Track`, `High Burn`, `Overspending`), smart budget tip formulas, archive and undo logic.
  3. **Monthly Bills Engine:** Automatic month rollover comparison, short-month due day clamping (`min(dueDay, daysInMonth)`).
  4. **Hangouts Settlement Engine:** Zero-sum remainder-safe split, payer remainder absorption, greedy debtor-creditor pairwise debt settlement algorithm (`calculateWhoOwesWhom`).
- Implement the 5 automated test suites in `test/`:
  - `test/wallet_balance_test.dart` (AUDIT-001 & AUDIT-002 verification)
  - `test/goal_calculations_test.dart` (AUDIT-008 & archive protection)
  - `test/hangout_settlement_test.dart` (Remainder & pairwise zero-sum debt settlement)
  - `test/bills_rollover_test.dart` (Rollover & short-month clamping)
  - `test/backup_restore_test.dart` (Offline JSON serialization round-trip)
- Verify `flutter test` passes 100%.

---

## Phase 3: Relational Riverpod State Layer & Offline Services
**Routing: PRO**

### Scope
- Implement Drift repository providers in `lib/providers/`:
  - `database_provider.dart`
  - `settings_provider.dart`
  - `records_provider.dart`
  - `bills_provider.dart`
  - `hangouts_provider.dart`
  - `analytics_provider.dart`
  - `security_provider.dart`
  - `theme_provider.dart`
- Implement offline subsystem services:
  - `lib/services/backup_restore_service.dart`: Atomic JSON export/import within a single Drift transaction, schema validation, backward-compatible field mapping (`daily -> allowance`, `wallet -> balance`).
  - `lib/services/security_service.dart`: 4–6 digit PIN hashing (SHA-256 HMAC / PBKDF2 with random salt), biometric auth via `local_auth`, credentials stored in `FlutterSecureStorage`.
  - `lib/services/local_notification_service.dart`: Offline recurring bill notifications at 09:00 on `effectiveDueDay` using `flutter_local_notifications` + `timezone`.
- Update models to match Drift entities and JSON backward compatibility.

---

## Phase 4: Brutalist Design System & Core UI Components
**Routing: FLASH**

### Scope
- Update `lib/core/theme/app_theme.dart`:
  - Enforce `0px` border radius on all theme components (`Card`, `Dialog`, `BottomSheet`, `TextField`, `ElevatedButton`, `OutlinedButton`, `Checkbox`).
  - Configure WCAG AAA monochrome color tokens (`bgPrimary`, `bgSecondary`, `bgCard`, `borderColor`, `borderFocus`, `borderStrong`, `textPrimary`, `textSecondary`, `colorSuccess`, `colorDanger`, `colorWarning`, `colorInfo`).
  - Apply `SpaceGrotesk` font family globally across dark and light themes.
- Implement reusable brutalist UI components:
  - `lib/core/widgets/brutalist_confirm_dialog.dart` (sharp monochrome confirmation dialogs).
  - `lib/core/widgets/brutalist_toast.dart` (monochrome status feedback).
  - `lib/core/utils/currency_formatter.dart` (with privacy masking support: `₱ ***.**`).
  - `lib/core/utils/date_utils_ext.dart` (ISO string helpers, month names, days in month).

---

## Phase 5: 5-Tab Shell & Screen Implementations
**Routing: FLASH**

### Scope
- Implement `MainShellView` in `lib/views/main_shell_view.dart`:
  - Persistent Top App Bar: Title, subtitle, theme toggle icon, privacy mode eye toggle, hamburger menu opening `SettingsPanelView`.
  - Floating Action Button (FAB): Sharp square `+` button opening `DailyModal` for Today.
  - Bottom Navigation Bar with 5 tabs (`IndexedStack`):
    1. **Home (`DashboardView`):** `GoalWidget`, custom $180^\circ$ progress arc gauge, wallet balance banner with `+ Add` button (`AddMoneyModal`), 3-column stats grid, smart budget tip card, `GoalHistoryModal`.
    2. **Calendar (`CalendarView` & `DailyModal`):** 6-row 42-cell grid with Sun–Sat layout, day cell dot indicators, `DailyModal` (School/Work card vs Rest Day card, Ledger tab, Add Expense tab).
    3. **Analytics (`AnalyticsView`):** Month filter selector, total expenses summary card with Month-over-Month badge, custom painted Donut Chart, sorted category breakdown list with progress bars.
    4. **Bills (`BillsView`):** Summary cards, sorted recurring bills list with square checkboxes, due date badges (`Paid`, `Overdue`, `Due Today!`, `Due in X days`), reset bills action.
    5. **Hangouts (`HangoutsView` & `WhoOwesWhomCard`):** Session cards list, create hangout view, session detail view, itemized expenses list, "Who Owes Whom" pairwise settlement card, idempotent merge to calendar modal.
- Implement `lib/views/settings/settings_panel_view.dart` (4-accordion slide-over drawer/modal for Goal/Wallet, Recurring Bills, Expense Categories, Security & Backup).
- Implement `lib/views/security/pin_lock_screen.dart` (cold start gating when PIN is enabled).

---

## Phase 6: Full Integration, End-to-End Verification & Audit Sign-Off
**Routing: PRO**

### Scope
- Execute full test suite (`flutter test`) and static analysis (`flutter analyze` with 0 issues).
- Verify all audit items from `specification.md` Section 2.2:
  - AUDIT-001: Balance state immutability on expense addition/deletion.
  - AUDIT-002: Strict standardization on `'allowance'` and `'balance'`.
  - AUDIT-003: `isDeleted` flag respected across selectors and queries.
  - AUDIT-008: Goal savings strictly filter allowance days `>= goalStartDate`.
- Verify Trap Fixes 1–9 from `specification.md`:
  - No internet permissions in AndroidManifest.
  - Offline font bundling (no SocketException).
  - Remainder absorption in hangout expense splitting.
  - "Who owes whom" zero-net settlement.
  - Calendar cell and modal calculation unification.
  - Goal archiving start date advancement and undo restoration.
  - Monthly bills automatic rollover and short-month clamping.
- Validate JSON backup export and restore across a fresh database instance.

