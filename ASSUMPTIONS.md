# Project Assumptions & Design Constraints

This document records the baseline assumptions and architectural constraints agreed upon for the Monance Mobile offline refactor and migration to `specification.md`.

---

## 1. Zero Network & Connectivity Mandate
- Monance Mobile is 100% offline. No internet permissions (`android.permission.INTERNET`, `android.permission.ACCESS_NETWORK_STATE`) in production AndroidManifest.
- No remote network clients (`dio`, `http`) or API endpoints (`/api/sync`, `/api/auth/*`, `/api/settings`, `/api/hangouts`).
- **Transitive `http` Dependency:** `http` appears in `pubspec.lock` strictly and exclusively as a transitive dependency of `timezone` (required by `specification.md` §3.1 for offline notification scheduling). No application code imports `package:http` directly, and it is never invoked or executed at runtime. Zero network access is strictly enforced; `android/app/src/main/AndroidManifest.xml` contains no `INTERNET` or `ACCESS_NETWORK_STATE` permissions.
- No runtime font fetching via `google_fonts`. All required weights of `SpaceGrotesk` (`Regular`, `Medium`, `SemiBold`, `Bold`) are statically bundled under `assets/fonts/`.

## 2. Storage & Persistence
- Single relational persistence engine: **Drift (SQLite)** via `sqlite3_flutter_libs`.
- Security credentials (PIN salt, hash, biometric enable flag) are stored exclusively in hardware-backed **`FlutterSecureStorage`**.
- No migration of legacy `SharedPreferences` keys on physical/emulator devices is needed. Data starts clean in Drift SQLite; existing web backups or prior exports are ingested via the offline JSON backup/restore service with backward-compatible field mapping (`daily -> allowance`, `wallet -> balance`).
- Monetary values are strictly stored as integers in cents/centavos (`100` cents = `1.00` currency unit) to avoid IEEE 754 floating-point inaccuracies.

## 3. Navigation & App Shell
- The application uses a Riverpod-driven `IndexedStack` navigation model with 5 bottom tabs:
  1. Home (`DashboardView`)
  2. Calendar (`CalendarView`)
  3. Analytics (`AnalyticsView`)
  4. Bills (`BillsView`)
  5. Hangouts (`HangoutsView`)
- Modals (`DailyModal`, `AddMoneyModal`, `GoalHistoryModal`, `AddHangoutExpenseModal`) are presented as modal bottom sheets or dialogs with `BorderRadius.zero`.
- Settings is accessible via a persistent hamburger icon in the top app bar opening `SettingsPanelView` (accordion-based drawer/modal).
- `go_router` is completely removed to simplify offline navigation and eliminate URL routing overhead.

## 4. Architectural Invariants
- `settings.currentBalance` is an invariant base reserve. Logging, editing, or deleting daily expenses or clearing a day **never** mutates `settings.currentBalance`.
- Active wallet balance is dynamically derived across non-deleted records via `derivedWalletBalanceProvider`.
- Goal progress calculations strictly ignore rest days (`startingMoney == 0`) and days prior to `settings.goalStartDate`.
- Hangout expense splitting absorbs remainders into the payer's share (or first participant) to guarantee $\sum \text{shares} == \text{totalAmount}$, and pairwise debt settlement uses greedy debtor/creditor matching where $\sum \text{Net} == 0$.

