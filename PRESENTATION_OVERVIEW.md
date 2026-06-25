# EmergiCam Mobile App — Implementation Overview
## For SRS Presentation

**Developer:** ZYAD | **Graduation Project 2025** | **AASTMT,** Alexandria

---

## 1. What Was Built

A cross-platform mobile application (Android & iOS) that serves as the user-facing interface for an elderly monitoring system. The app handles:
- User authentication and profile management
- Real-time emergency alerts from an AI camera system
- Contact management with emergency contact prioritization
- Direct messaging between users
- Full bilingual support (English/Arabic)
- Dark/Light theme customization

---

## 2. Technology Choices & Why

| Technology | Why We Used It |
|-----------|----------------|
| **Flutter** | Single codebase for Android & iOS; fast development; Material Design 3 out of the box |
| **Provider** | Lightweight state management; built into Flutter ecosystem; easy to learn and maintain |
| **Firebase Auth** | Secure, free authentication with email/password and Google Sign-In |
| **Cloud Firestore** | Real-time database — the app updates instantly when new alerts arrive without manual refresh |
| **SQLite** | Local storage that works offline; acts as backup when there's no internet |
| **flutter_local_notifications** | Native push notifications for emergency alerts on both Android and iOS |
| **SharedPreferences** | Simple key-value storage for user preferences (theme choice, language, session) |

---

## 3. App Architecture

We followed a **Provider-based architecture** (similar to MVVM) with four clear layers:

```
┌─────────────────────────────────────────┐
│  Screens (UI) — 15 screens              │
├─────────────────────────────────────────┤
│  Providers (State) — 6 providers        │
├─────────────────────────────────────────┤
│  Services (Data) — 6 service classes    │
├─────────────────────────────────────────┤
│  Firebase / SQLite / SharedPreferences  │
└─────────────────────────────────────────┘
```

**How data flows when the app runs:**
1. User taps a button on screen
2. The screen calls a Provider
3. The Provider calls a Service to get/save data
4. Data comes from Firebase first; if offline, falls back to SQLite
5. The Provider updates its state → the screen rebuilds automatically

**Real-time updates work like this:**
- The app opens a "listener" to Firestore
- When the AI camera writes a new alert, Firestore pushes it to the app instantly
- The app shows a notification and updates the alert list without the user doing anything

---

## 4. App Structure — Every File Explained

```
lib/
├── main.dart                                  # App entry point
│   └── Initializes Firebase, SQLite, notifications
│   └── Sets up all 6 providers in the app
│   └── Configures MaterialApp with themes & localization
│
├── models/                                    # Data shapes
│   ├── user_model.dart                        # User (id, name, email, phone, avatar)
│   ├── alert_model.dart                       # Alert (type, status, time, location, confidence)
│   ├── contact_model.dart                     # Contact (name, phone, relationship, emergency flag)
│   └── message_model.dart                     # Message (sender, receiver, text, read status)
│   └── Each has: toMap(), fromMap(), copyWith()
│
├── providers/                                 # Brain of the app — state management
│   ├── auth_provider.dart                     # Handles login, register, logout, session
│   ├── theme_provider.dart                    # Controls light/dark mode
│   ├── language_provider.dart                 # Switches between English and Arabic
│   ├── alert_provider.dart                    # Manages alerts + real-time listener + notifications
│   ├── contact_provider.dart                  # Manages contacts + emergency filtering
│   └── chat_provider.dart                     # Manages messages + real-time listener
│
├── screens/                                   # Every page the user sees
│   ├── splash_screen.dart                     # Logo animation → auto-routes after 3 seconds
│   ├── onboarding_screen.dart                 # 3-page intro (first launch only)
│   │
│   ├── auth/
│   │   ├── login_screen.dart                  # Email/password + Google Sign-In buttons
│   │   └── register_screen.dart               # Registration form with validation
│   │
│   ├── home/
│   │   ├── home_screen.dart                   # Bottom navigation with 5 tabs
│   │   ├── dashboard_tab.dart                 # Welcome card, stats, recent alerts
│   │   ├── alerts_tab.dart                    # Full alert list with pull-to-refresh
│   │   ├── contacts_tab.dart                  # Contact list with call & emergency toggle
│   │   ├── messages_tab_new.dart              # Contact list → tap to open chat
│   │   └── settings_tab.dart                  # Theme, language, camera setup, logout
│   │
│   ├── alert/
│   │   └── alert_detail_screen.dart           # Full alert info + Acknowledge/Resolve/Delete
│   │
│   ├── contact/
│   │   └── add_contact_screen.dart            # Add/edit contact form
│   │
│   ├── chat/
│   │   └── chat_screen.dart                   # Real-time messaging with read receipts
│   │
│   └── settings/
│       └── camera_integration_screen.dart     # Server config form + setup guide
│
├── services/                                  # Talks to databases
│   ├── database_service.dart                  # SQLite: creates 4 tables, full CRUD operations
│   ├── firebase_service.dart                  # Just calls Firebase.initializeApp()
│   ├── firebase_auth_service.dart             # Sign-up, login, Google auth, logout
│   ├── firestore_service.dart                 # Saves/reads/streams data from Firestore
│   ├── firebase_options.dart                  # Firebase project config (emergicam12)
│   └── notification_service.dart              # Shows local push notifications
│
└── utils/
    └── app_localization.dart                  # 151 English + 151 Arabic translations
```

---

## 5. How Each Feature Works Under the Hood

### 5.1 Authentication
- On launch, the app checks SharedPreferences for a saved user ID
- If found → skip login, go straight to Home
- If not found → show Login screen
- Login sends email/password to Firebase Auth; on success, saves user ID locally
- Registration creates a Firebase Auth account + saves full profile to Firestore + SQLite
- Google Sign-In uses the google_sign_in package → gets credentials → authenticates with Firebase

### 5.2 Real-Time Alerts
- AlertProvider opens a **stream listener** on Firestore collection `alerts` (root level)
- The AI camera system writes documents to this collection
- When a new document appears, Firestore pushes it to the app in real time
- The provider checks if this alert ID was already notified (to avoid duplicates)
- If new: triggers a local push notification + haptic vibration + updates the UI
- If the phone is offline, alerts are saved to SQLite and synced when connection returns

### 5.3 Contacts
- Each user's contacts are stored in Firestore under `users/{userId}/contacts/`
- On app start, ContactProvider loads all contacts from Firestore
- If offline, loads from SQLite instead
- "Emergency contacts" are filtered by the `isEmergencyContact` boolean field
- Phone calls use `url_launcher` to open the system dialer

### 5.4 Real-Time Messaging
- Messages are stored in Firestore under `conversations/{conversationId}/messages/`
- `conversationId` is created by sorting both user IDs alphabetically and concatenating them
- ChatProvider opens a stream listener for the specific conversation
- New messages appear instantly without refreshing
- Read receipts: when a user opens a chat, all unread messages are marked `isRead = true`
- The UI shows single check (delivered) vs double check (read)

### 5.5 Notifications
- Two channels are created on app startup:
  - **Emergency Alerts** — highest priority, red LED, vibration pattern, full-screen intent
  - **Test Alerts** — high priority, blue LED
- Each notification has a unique ID (alert ID hash) so they can be individually cancelled
- Tapping a notification is configured to open the app (handled by the OS)

### 5.6 Localization (English/Arabic)
- Custom `AppLocalizations` class with 151 keys
- When the user switches language, `LanguageProvider` updates the locale
- The app rebuilds with the new language; Arabic enables RTL layout automatically
- `timeago` package auto-translates relative timestamps based on locale

### 5.7 Theme (Light/Dark)
- Three modes: Light, Dark, System (follows phone setting)
- Both themes use Material Design 3 with `ColorScheme.fromSeed()`
- Google Fonts (Poppins) applied globally
- Custom card/button/input decoration defined per theme

---

## 6. The SQLite Database

A local file called `smart_ai_camera.db` stores four tables:

| Table | What It Stores | Why We Need It Locally |
|-------|---------------|----------------------|
| **users** | User profile (name, email, phone) | Quick profile access offline |
| **alerts** | All alerts with full details | View alert history without internet |
| **contacts** | Contact information & emergency flag | Call contacts offline |
| **messages** | Chat messages & read status | Read sent messages offline |

Every operation saves to **both** Firestore and SQLite to keep them in sync.

---

## 7. Navigation — How Users Move Through the App

```
App Starts
    │
    ▼
Splash Screen (3-second animation)
    │
    ├── First time? → Onboarding (3 pages) → Login
    │
    ├── Already logged in? → Home Screen
    │
    └── Not logged in? → Login Screen
                            │
                      ┌─────┴─────┐
                      ▼           ▼
                  Login      Register
                      │           │
                      └─────┬─────┘
                            ▼
                       Home Screen
                            │
              ┌─────────────┼─────────────┬────────────┬─────────────┐
              ▼             ▼             ▼            ▼             ▼
         Dashboard      Alerts       Contacts    Messages      Settings
         (Tab 1)       (Tab 2)       (Tab 3)     (Tab 4)       (Tab 5)
              │             │             │            │             │
              ▼             ▼             ▼            ▼             ▼
        Stats +      Tap alert →   Tap contact →  Tap contact →  Theme/
        Recent       Alert Detail  Call/Edit     Chat Screen    Language/
        Alerts       Screen        Options                       Logout
```

---

## 8. Firebase Firestore Collections

```
emergicam12
└── Firestore Database
    │
    ├── users/{userId}
    │   ├── fullName, email, phoneNumber, profileImage, createdAt
    │   └── contacts/{contactId}
    │       ├── name, phoneNumber, email, relationship, isEmergencyContact
    │
    ├── alerts/{alertId}           ← AI camera writes here
    │   ├── userId, alertType, title, message, location
    │   ├── timestamp, status, confidence
    │   └── acknowledgedAt, resolvedAt
    │
    └── conversations/{conversationId}
        └── messages/{messageId}
            ├── senderId, receiverId, message, timestamp, isRead
```

---

## 9. What Each Provider Manages (In Detail)

| Provider | What It Tracks | What It Can Do |
|----------|---------------|----------------|
| **AuthProvider** | Current user, login state, error messages, onboarding status | register, login with Google/email, logout, clear errors |
| **ThemeProvider** | Light / Dark / System mode | toggle theme, save preference |
| **LanguageProvider** | English / Arabic locale | switch language, save preference |
| **AlertProvider** | List of alerts, loading state, notified alert IDs | load alerts, create test/emergency alerts, update status, delete, clear all |
| **ContactProvider** | List of contacts, loading state, emergency contacts | load, add, update, delete, toggle emergency |
| **ChatProvider** | Messages, loading state, current chat user | load messages, send, mark as read, clear |

---

## 10. Testing

Currently includes one basic widget test (smoke test) that verifies the app renders correctly with mocked SharedPreferences. This is the starting point for a more comprehensive test suite.

---

## 11. Current Implementation Status

| Feature | Lines of Code | Status | Notes |
|---------|--------------|--------|-------|
| main.dart | 93 | Complete | Entry point with all providers |
| User Model | 61 | Complete | toMap, fromMap, copyWith |
| Alert Model | 135 | Complete | Enums for type + status |
| Contact Model | 98 | Complete | Relationship enum |
| Message Model | 57 | Complete | Read receipt field |
| Auth Provider | 221 | Complete | Email, Google, session |
| Theme Provider | 129 | Complete | 3 modes, full themes |
| Language Provider | 37 | Complete | en/ar toggle |
| Alert Provider | 253 | Complete | Real-time listener + notifications |
| Contact Provider | 101 | Complete | CRUD + emergency filter |
| Chat Provider | 189 | Complete | Real-time messages + read receipts |
| Splash Screen | 133 | Complete | Animated auto-route |
| Onboarding | 226 | Complete | 3-page PageView |
| Login Screen | 238 | Complete | Email + Google |
| Register Screen | 287 | Complete | Form with validation |
| Home Screen | 105 | Complete | 5-tab navigation |
| Dashboard Tab | 298 | Complete | Stats, alerts, welcome |
| Alerts Tab | 252 | Complete | Full list + clear all |
| Contacts Tab | 218 | Complete | Call + emergency toggle |
| Messages Tab | 134 | Complete | Contact-based chat list |
| Settings Tab | 238 | Complete | Theme, lang, camera, logout |
| Alert Detail | 333 | Complete | Acknowledge/Resolve/Delete |
| Add Contact | 266 | Complete | Form + relationship picker |
| Chat Screen | 393 | Complete | Real-time bubbles + receipts |
| Camera Integration | 327 | UI Complete | Config form + guide |
| SQLite Service | 257 | Complete | 4 tables, full CRUD |
| Firebase Auth Service | 158 | Complete | Email + Google |
| Firestore Service | 624 | Complete | All collections + streams |
| Notification Service | 130 | Complete | 2 channels, vibration, LED |
| Localization | 310 | Complete | 151 keys × 2 languages |
| **Total** | **~5,800** | | |

---

*This document covers only the implemented mobile application for the SRS Implementation section.*
