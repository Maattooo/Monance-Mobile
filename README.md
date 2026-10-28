# Monance Mobile (Flutter & Android Studio)

A mobile companion application for **Monance**, built with Flutter, Riverpod, Dio, and GoRouter. Connects seamlessly to the existing Next.js & MongoDB backend.

---

## Quick Start: Opening & Running in Android Studio

### 1. Open in Android Studio
1. Launch **Android Studio**.
2. Select **File -> Open...** (or **Open** from the welcome splash).
3. Navigate to this repository and select the **`mobile/`** directory:
   ```
   c:\Users\mrtnm\Desktop\Programs\MonanceMobile
   ```
4. Click **OK**. Android Studio will recognize the Flutter/Dart project and load Gradle sync.

### 2. Fetch Flutter Dependencies
Inside Android Studio:
- Click **'Pub get'** in the action bar at the top of `pubspec.yaml`, or run in Android Studio's Terminal:
  ```bash
  flutter pub get
  ```

### 3. Start the Next.js Backend
In another terminal (or your root project window):
```bash
npm run dev
```
The Next.js server starts at `http://localhost:3000`.

### 4. Run the Mobile App
1. In Android Studio's device selector toolbar, choose an **Android Virtual Device (AVD Emulator)**.
2. Press the green **Run (▶)** button or press `Shift + F10`.
3. The app will launch, and automatically point to `http://10.0.2.2:3000` (which routes to your computer's `localhost:3000`).

---

## Connecting Devices

### A. Android Emulator (Default)
- The app defaults to `http://10.0.2.2:3000`, which is the special alias loopback address Android emulator uses to reach host machine's `localhost:3000`.
- Cleartext HTTP traffic is pre-configured in `android/app/src/main/AndroidManifest.xml` (`android:usesCleartextTraffic="true"`).

### B. Physical Android Device (Wi-Fi / USB)
1. Ensure your phone and your PC are connected to the same Wi-Fi network.
2. Find your PC's local IP address (`ipconfig` on Windows, e.g. `192.168.1.15`).
3. Open the app on your phone.
4. Tap the **Server URL** on the Login screen or in **Settings -> Backend Server URL**, and change it to:
   ```
   http://192.168.1.15:3000
   ```

---

## Project Structure

```
mobile/
├── android/                   # Android native configuration & Gradle scripts
│   └── app/src/main/
│       └── AndroidManifest.xml # Configured with cleartext HTTP & Internet permission
├── lib/
│   ├── core/
│   │   ├── constants/         # API endpoints & storage keys
│   │   ├── network/           # Dio HTTP client with JWT & 401 interceptors
│   │   ├── router/            # GoRouter + Riverpod RouterNotifier auth guard
│   │   ├── theme/             # Sleek high-contrast monochrome light & dark theme
│   │   └── utils/             # PHP (₱) currency formatting & conversions
│   ├── models/                # Strongly typed User, Settings, Expense, DailyRecord
│   ├── providers/             # Riverpod state notifiers (Auth, Records, Settings, Theme)
│   ├── services/              # StorageService, AuthService, SyncService
│   ├── views/
│   │   ├── auth/              # LoginView & RegisterView
│   │   ├── dashboard/         # DashboardView & AddExpenseSheet
│   │   ├── calendar/          # CalendarView with TableCalendar
│   │   ├── goal/              # GoalView (Savings Goal Progress)
│   │   ├── settings/          # SettingsView (Theme, IP config, categories, logout)
│   │   └── main_shell_view.dart # Shell navigation bar
│   └── main.dart              # Entry point bootstrapping storage and ProviderScope
└── pubspec.yaml               # Project dependencies (Riverpod, Dio, GoRouter, etc.)
```

---

## Key Design Patterns

- **JWT Authentication**: On sign in, JWT token is securely stored via `flutter_secure_storage`. The Dio interceptor attaches `Authorization: Bearer <token>` to all requests.
- **CSRF & Cookie Independence**: The Next.js backend supports both web cookie sessions and mobile Bearer tokens.
- **Offline Caching & Sync**: Edits are immediately written to local `shared_preferences`, queued, and synced with MongoDB with conflict-resolution timestamps.
- **Production Release Note**: When building a production release targeting HTTPS (e.g. Vercel), remove `android:usesCleartextTraffic="true"` from `AndroidManifest.xml`.
