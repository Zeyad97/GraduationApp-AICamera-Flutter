# EmergiCam — Smart AI Camera Mobile App

A Flutter mobile application for the **Smart AI Camera Medical Emergency Detection System**. This app serves as the mobile companion to receive real-time alerts from an AI-powered camera system that detects falls, emergencies, and abnormal activities in elderly or vulnerable individuals. Includes real-time messaging between users and emergency contacts.

**Developed by ZYAD** | Graduation Project 2025 | AASTMT, Alexandria

---

## Features

### Authentication & Onboarding
- Animated splash screen with auto-navigation
- 3-page onboarding flow for first-time users
- Email/password registration & login with validation
- Google Sign-In integration
- Session persistence across app restarts

### Dashboard
- Welcome card with user avatar and name
- Today's alerts counter
- Emergency contacts counter
- Recent alerts feed (last 5)
- Pull-to-refresh and View All navigation

### Emergency Alerts
- Real-time alert stream from AI camera system via Firestore
- 7 alert types: Fall, Immobility, Emergency Gesture, Abnormal Activity, Medical Emergency, Manual, Test
- 5 status stages: Pending, Active, Acknowledged, Resolved, False Alarm
- Status management with timestamps
- Local push notifications with haptic feedback
- Emergency vs test notification differentiation
- Duplicate notification prevention

### Contacts Management
- Full CRUD operations with offline SQLite fallback
- Relationship categorization: Family, Friend, Caregiver, Doctor, Nurse, Other
- Emergency contact toggle
- Direct phone call integration
- Avatar with initials fallback

### Real-Time Messaging
- Firestore-based conversation system
- Real-time message listener with auto-scroll
- Read receipts (single/double check marks)
- Date headers (Today, Yesterday, formatted date)
- Sent/received message bubbles
- Contact-based chat navigation

### Settings & Personalization
- Dark/Light/System theme toggle (Material Design 3)
- Bilingual support: English & Arabic (full RTL)
- Profile display section
- Camera integration setup guide
- App version and about info
- Logout with confirmation dialog

### Camera Integration Guide
- 4-step setup instructions
- Server URL + API Key configuration form
- Connection status display
- Technical documentation reference

### Push Notifications
- Dual notification channels:
  - Emergency: max priority, red LED, vibration, full-screen intent
  - Test: high priority, blue LED
- Cancel individual or all notifications

---

## Architecture

### State Management — Provider (MVVM-like)

| Layer | Components |
|-------|-----------|
| **Presentation** | 15 screens + reusable widgets |
| **State Management** | 6 ChangeNotifier providers |
| **Domain/Models** | 4 data models with toMap/fromMap/copyWith |
| **Data/Service** | 6 services (Firebase Auth, Firestore, SQLite, Notifications) |
| **Utilities** | Custom localization (151 keys × 2 languages) |

### Data Flow
```
User Action → Widget → Provider (ChangeNotifier)
    ↓
Firestore (primary success) → notify listeners → UI rebuild
    ↓ fail
SQLite (offline fallback) → notify listeners → UI rebuild
```

Real-time streams via Firestore `.snapshots()` for alerts and messages.

### Providers
- **AuthProvider** — Authentication state, login/register/logout/session persistence
- **ThemeProvider** — Light/dark/system theme mode
- **LanguageProvider** — English/Arabic locale switching
- **AlertProvider** — Alert CRUD + real-time Firestore listener + notifications
- **ContactProvider** — Contact CRUD + emergency contact filtering
- **ChatProvider** — Message CRUD + real-time Firestore listener + read receipts

---

## Tech Stack

| Category | Technologies |
|----------|-------------|
| **Frontend** | Flutter, Material Design 3, Google Fonts (Poppins), Lottie |
| **State Management** | Provider |
| **Backend/Database** | Firebase (Auth, Firestore, Messaging, Realtime DB) + SQLite |
| **Auth** | Firebase Auth (Email/Password + Google Sign-In) |
| **Notifications** | flutter_local_notifications + Firebase Cloud Messaging |
| **Localization** | Custom AppLocalizations (English & Arabic) |
| **Persistence** | SharedPreferences + SQLite |

### Key Dependencies
```yaml
provider: ^6.1.1               # State management
firebase_core: ^3.1.0          # Firebase initialization
firebase_auth: ^5.1.0          # Authentication
cloud_firestore: ^5.1.0        # Real-time database
sqflite: ^2.3.0                # Local SQLite storage
flutter_local_notifications: ^17.2.3  # Push notifications
google_fonts: ^6.1.0           # Custom typography
lottie: ^3.0.0                 # Animations
intl: ^0.20.2                  # Date formatting
url_launcher: ^6.2.2           # Phone calls
uuid: ^4.2.2                   # Unique IDs
timeago: ^3.6.0                # Relative timestamps
```

---

## Firebase Services

| Service | Usage |
|---------|-------|
| **Firebase Auth** | Email/password + Google Sign-In |
| **Cloud Firestore** | Users, Alerts (per-user + root), Contacts, Messages |
| **Firebase Messaging** | Configured for push notifications |
| **Firebase Realtime DB** | Listed as dependency |

### Firestore Collections
- `users/{userId}` — User profiles
- `users/{userId}/contacts/{contactId}` — Per-user contacts
- `alerts` (root) — Camera/AI system writes alerts here
- `users/{userId}/alerts/{alertId}` — Per-user alerts (fallback)
- `conversations/{conversationId}/messages/{messageId}` — Chat messages

---

## Project Structure

```
lib/
├── main.dart                               # Entry point, MultiProvider, MaterialApp
├── models/                                 # Data models
│   ├── user_model.dart
│   ├── alert_model.dart
│   ├── contact_model.dart
│   └── message_model.dart
├── providers/                              # State management
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   ├── language_provider.dart
│   ├── alert_provider.dart
│   ├── contact_provider.dart
│   └── chat_provider.dart
├── screens/                                # UI screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── dashboard_tab.dart
│   │   ├── alerts_tab.dart
│   │   ├── contacts_tab.dart
│   │   ├── messages_tab.dart
│   │   ├── messages_tab_new.dart
│   │   └── settings_tab.dart
│   ├── alert/
│   │   └── alert_detail_screen.dart
│   ├── contact/
│   │   └── add_contact_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart
│   └── settings/
│       └── camera_integration_screen.dart
├── services/                               # Business logic & data access
│   ├── database_service.dart               # SQLite singleton
│   ├── firebase_service.dart               # Firebase init
│   ├── firebase_auth_service.dart          # Firebase Auth
│   ├── firestore_service.dart              # Firestore CRUD + streams
│   ├── firebase_options.dart               # Firebase config
│   └── notification_service.dart           # Local notifications
└── utils/
    └── app_localization.dart               # 151 keys × 2 languages
```

---

## Getting Started

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation
```bash
git clone <repository-url>
cd grad_app
flutter pub get
flutter run
```

### First-Time Setup
1. Launch the app
2. Complete the 3-page onboarding
3. Register a new account or sign in with Google
4. Add emergency contacts
5. Test the alert system using "Test Alert" on the Dashboard
6. Explore settings to customize theme and language

---

## AI Backend Integration (Future)

The mobile app is designed to connect with a Python-based AI detection server:

```
Camera → AI Server → Detection → Alert Generation → Mobile App → Emergency Contacts
```

### Components (To be integrated)
- **OpenCV** — Video capture & processing
- **MediaPipe Pose** — Skeleton detection (33 keypoints)
- **TensorFlow** — Gesture recognition (MLP/LSTM)
- **Scikit-learn** — Anomaly detection (Isolation Forest)
- **REST API / WebSocket** — Communication with mobile app

### Planned API Endpoints
```
POST /api/alert/send          — Send alert from AI server to app
GET  /api/alerts              — Get alert history
PUT  /api/alert/:id/status    — Update alert status
POST /api/camera/connect      — Connect camera to system
GET  /api/camera/status       — Get camera status
POST /api/config/thresholds   — Update detection thresholds
```

---

## Navigation Map

```
SplashScreen (animated)
 ├── First Launch → OnboardingScreen (3 pages) → LoginScreen
 ├── Authenticated → HomeScreen
 └── Unauthenticated → LoginScreen ↔ RegisterScreen

HomeScreen (5-tab Bottom Navigation)
 ├── Tab 1 — Dashboard: stats, recent alerts, welcome
 ├── Tab 2 — Alerts: full list, clear-all, tap for details
 ├── Tab 3 — Contacts: list, call, emergency toggle
 ├── Tab 4 — Messages: contact list → chat screen
 └── Tab 5 — Settings: theme, language, camera, logout

Detail Screens:
 ├── AlertDetailScreen — Acknowledge/Resolve/Delete/False Alarm
 ├── AddContactScreen — Add or edit contact
 ├── ChatScreen — Real-time messaging with read receipts
 └── CameraIntegrationScreen — Setup guide + server config
```

---

## Current Status

| Module | Status | Notes |
|--------|--------|-------|
| Authentication | Complete | Email/password + Google Sign-In |
| Dashboard & Alerts | Complete | Real-time Firestore listener |
| Contacts | Complete | Full CRUD + emergency toggle |
| Real-Time Chat | Complete | Read receipts, date headers |
| Camera Integration | UI Ready | Backend not yet connected |
| Voice/Video Calls | Placeholder | UI buttons only |
| Tests | Minimal | 1 smoke test |
| Assets | Empty | Folders created |

---

## Roadmap

**Phase 1: Mobile App** (Completed)
- Authentication, alerts, contacts, chat, theming, localization, notifications

**Phase 2: AI Backend** (In Progress)
- OpenCV video capture, MediaPipe Pose, gesture recognition, fall detection, REST API

**Phase 3: Integration** (Planned)
- WebSocket real-time connection, API auth, camera management UI, multi-camera support

**Phase 4: Deployment** (Future)
- Production server, cloud deployment, performance optimization, security audit, user testing

---

## Academic Context

**Institution:** College of Computing and Information Technology, AASTMT  
**Project:** Smart AI Camera for Medical Emergency Detection Using Gestures and Abnormal Activity Recognition  
**Year:** 2025  
**Location:** Alexandria, Egypt  

### Project Objectives
- Develop a vision-based monitoring system for elderly care
- Implement pose estimation for emergency detection
- Recognize emergency gestures and falls
- Detect abnormal activities in real time
- Provide real-time alerts to caregivers
- Operate on standard consumer hardware

---

## Developer

**ZYAD** — Graduation Project 2025  
College of Computing and Information Technology, AASTMT  
Alexandria, Egypt

---

## License

This project is developed for academic purposes as part of a graduation project.
