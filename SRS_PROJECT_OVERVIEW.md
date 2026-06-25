# EmergiCam — SRS Project Overview
## Smart AI Camera for Medical Emergency Detection Using Gestures and Abnormal Activity Recognition

**Project:** Graduation Project — College of Computing and Information Technology, AASTMT  
**Developer:** ZYAD  
**Year:** 2025  
**Location:** Alexandria, Egypt  
**Package Name:** `com.emergicam.app`  
**Version:** 1.0.0+1  
**Platform:** Flutter (Android, iOS, Web, Windows, macOS, Linux)

---

## 1. Core Purpose

An intelligent monitoring system that uses AI-powered cameras to detect falls, immobility, emergency gestures, and abnormal activity in elderly or vulnerable individuals. The app provides real-time alerts, emergency contact notifications, secure messaging, and a centralized dashboard for caregivers.

---

## 2. System Architecture

### 2.1 Architecture Pattern
Provider-based state management (MVVM-like):

| Layer | Components |
|-------|-----------|
| **Presentation** | 15 screens + reusable widgets |
| **State Management** | 6 ChangeNotifier providers |
| **Domain/Models** | 4 data models (User, Alert, Contact, Message) |
| **Data/Service** | 3 singleton services + Firebase Auth |
| **Utilities** | Custom localization (151 keys × 2 languages) |

### 2.2 Tech Stack

| Category | Technologies |
|----------|-------------|
| **Frontend** | Flutter, Material Design 3, Google Fonts (Poppins), Lottie |
| **State Management** | Provider |
| **Backend/Database** | Firebase (Auth, Firestore, Messaging, Realtime DB) + SQLite |
| **Auth** | Firebase Auth (Email/Password + Google Sign-In) |
| **Notifications** | flutter_local_notifications + Firebase Cloud Messaging |
| **Localization** | Custom AppLocalizations (English & Arabic / RTL support) |
| **Persistence** | SharedPreferences + SQLite (offline fallback) |

### 2.3 Data Flow Strategy

```
User Action → Screen Widget → Provider (ChangeNotifier)
    ↓
Firestore (primary) → success → notify listeners
    ↓ fail
SQLite (offline fallback) → store locally → notify listeners
    ↓
Provider calls notifyListeners() → UI rebuilds
```

Real-time streams for alerts and messages use Firestore `.snapshots()`.

---

## 3. Navigation Flow

```
SplashScreen (animated, 3s delay)
 ├── First Launch → OnboardingScreen (3 pages)
 ├── Authenticated → HomeScreen (5 tabs)
 └── Unauthenticated → LoginScreen ↔ RegisterScreen

HomeScreen Tabs:
 ├── Tab 1: DashboardTab (stats, recent alerts, welcome)
 ├── Tab 2: AlertsTab (full alert list, clear-all)
 ├── Tab 3: ContactsTab (contact list, call, emergency toggle)
 ├── Tab 4: MessagesTab (contact-based chat list)
 └── Tab 5: SettingsTab (theme, language, camera setup, logout)

Detail Screens:
 ├── AlertDetailScreen (acknowledge/resolve/delete/false-alarm)
 ├── AddContactScreen (add/edit contact form)
 ├── ChatScreen (real-time messaging with read receipts)
 └── CameraIntegrationScreen (setup guide + server config)
```

---

## 4. Data Models

### 4.1 UserModel
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique identifier |
| fullName | String | Display name |
| email | String | Login email |
| password | String | Hashed password |
| phoneNumber | String | Contact number |
| profileImage | String? | Avatar URL |
| createdAt | DateTime | Account creation |

### 4.2 AlertModel
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique ID from Firestore |
| userId | String | Associated user |
| alertType | AlertType enum | fall, immobility, emergencyGesture, abnormalActivity, medicalEmergency, manual, test |
| title | String | Alert title |
| message | String | Alert description |
| location | String? | Geospatial info |
| timestamp | DateTime | Occurrence time |
| status | AlertStatus enum | pending, active, acknowledged, resolved, falseAlarm |
| acknowledgedAt | DateTime? | When acknowledged |
| resolvedAt | DateTime? | When resolved |
| confidence | double? | AI confidence score |

### 4.3 ContactModel
| Field | Type | Description |
|-------|------|-------------|
| id | String | Unique ID |
| userId | String | Owner user |
| name | String | Contact name |
| phoneNumber | String | Contact phone |
| email | String? | Contact email |
| relationship | ContactRelationship enum | family, friend, caregiver, doctor, nurse, other |
| isEmergencyContact | bool | Emergency flag |
| profileImage | String? | Avatar |
| createdAt | DateTime | Added date |

### 4.4 MessageModel
| Field | Type | Description |
|-------|------|-------------|
| id | String | UUID |
| senderId | String | Sender user ID |
| receiverId | String | Recipient user ID |
| message | String | Text content |
| timestamp | DateTime | Sent time |
| isRead | bool | Read receipt |
| attachmentUrl | String? | File attachment |

---

## 5. Feature Breakdown

### 5.1 Authentication
- Email/password registration & login with full validation
- Google Sign-In integration
- Session persistence via SharedPreferences
- Password reset functionality (configured)

### 5.2 Dashboard & Alerts
- Real-time alert stream from Firestore root `alerts` collection (written by external AI camera system)
- Smart alert type mapping: camera strings (fall, no_movement, emergency_gesture, abnormal_activity, medical_emergency) mapped to app enums
- Stats cards (today's alerts count, emergency contacts count)
- Recent alerts feed (last 5)
- Pull-to-refresh on all lists
- Clear all alerts with confirmation

### 5.3 Alert Management
- Full CRUD for alerts with real-time Firestore listener
- Status progression: pending → active → acknowledged → resolved / falseAlarm
- Local push notifications with distinct behavior for emergency vs test alerts
- New alert detection with haptic feedback (heavy impact + vibration)
- Duplicate notification prevention via notifiedAlertIds tracking

### 5.4 Contacts
- Full CRUD with offline SQLite fallback
- Emergency contact toggle (filtered via getter)
- Relationship categorization (family, friend, caregiver, doctor, nurse, other)
- Direct phone call via url_launcher

### 5.5 Real-Time Messaging
- Firestore-based conversation system (sorted composite user IDs)
- Real-time message listener with auto-scroll
- Read receipts (single/double check marks)
- Date headers ("Today", "Yesterday", formatted date)
- Sent/received message bubbles (blue right / grey left)

### 5.6 Camera Integration (UI Ready)
- 4-step setup guide: Install Server → Configure Camera → Connect API → Receive Alerts
- Server configuration form (URL + API Key)
- Status indicator (placeholder: "Disconnected")

### 5.7 Settings & Personalization
- Dark/Light/System theme toggle
- English/Arabic language switching (RTL support)
- User profile display
- Logout with confirmation

### 5.8 Push Notifications
- flutter_local_notifications with dual-channel setup:
  - Emergency channel: max priority, red LED, vibration, full-screen intent
  - Test channel: high priority, blue LED
- Cancel individual or all notifications

---

## 6. Firebase Services

| Service | Usage |
|---------|-------|
| **Firebase Auth** | Email/password + Google Sign-In |
| **Cloud Firestore** | Users, Alerts (per-user + root), Contacts, Messages |
| **Firebase Messaging** | Configured in pubspec, ready for push notifications |
| **Firebase Realtime DB** | Listed as dependency, not yet implemented |

### Firestore Collection Structure:
- `users/{userId}` — User profiles
- `users/{userId}/contacts/{contactId}` — Per-user contacts
- `alerts` (root) — Camera/AI system writes alerts here (real-time stream)
- `users/{userId}/alerts/{alertId}` — Per-user alerts (fallback)
- `conversations/{conversationId}/messages/{messageId}` — Chat messages

---

## 7. SQLite Database Schema

Database: `smart_ai_camera.db`

### users table
| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| fullName | TEXT | NOT NULL |
| email | TEXT | UNIQUE, NOT NULL |
| password | TEXT | NOT NULL |
| phoneNumber | TEXT | NOT NULL |
| profileImage | TEXT | NULLABLE |
| createdAt | TEXT | NOT NULL |

### alerts table
| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| userId | TEXT | FOREIGN KEY → users(id) |
| alertType | TEXT | NOT NULL |
| title | TEXT | NOT NULL |
| message | TEXT | NOT NULL |
| location | TEXT | NULLABLE |
| timestamp | TEXT | NOT NULL |
| status | TEXT | NOT NULL |
| acknowledgedAt | TEXT | NULLABLE |
| resolvedAt | TEXT | NULLABLE |
| confidence | REAL | NULLABLE |

### contacts table
| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| userId | TEXT | FOREIGN KEY → users(id) |
| name | TEXT | NOT NULL |
| phoneNumber | TEXT | NOT NULL |
| email | TEXT | NULLABLE |
| relationship | TEXT | NOT NULL |
| isEmergencyContact | INTEGER | DEFAULT 0 |
| profileImage | TEXT | NULLABLE |
| createdAt | TEXT | NOT NULL |

### messages table
| Column | Type | Constraints |
|--------|------|-------------|
| id | TEXT | PRIMARY KEY |
| senderId | TEXT | NOT NULL |
| receiverId | TEXT | NOT NULL |
| message | TEXT | NOT NULL |
| timestamp | TEXT | NOT NULL |
| isRead | INTEGER | DEFAULT 0 |
| attachmentUrl | TEXT | NULLABLE |

---

## 8. Provider State Management

| Provider | State | Key Methods |
|----------|-------|-------------|
| **AuthProvider** | currentUser, isLoading, isLoggedIn, errorMessage, hasSeenOnboarding | registerWithEmail(), loginWithEmail(), signInWithGoogle(), logout() |
| **ThemeProvider** | themeMode (light/dark/system) | setThemeMode(), toggleTheme() |
| **LanguageProvider** | locale (en/ar) | setLocale(), toggleLanguage() |
| **AlertProvider** | alerts, isLoading, notifiedAlertIds, recentAlerts, totalAlertsToday | loadAlerts(), createEmergencyAlert(), updateAlertStatus(), deleteAlert(), clearAllAlerts() |
| **ContactProvider** | contacts, isLoading, emergencyContacts | loadContacts(), addContact(), updateContact(), deleteContact(), toggleEmergencyContact() |
| **ChatProvider** | messages, isLoading, currentChatUserId | loadMessages(), sendMessage(), markAsRead(), getLastMessageForContact() |

---

## 9. Localization

Custom implementation with 151 translation keys across 10 categories:
- Common, Authentication, Onboarding, Home Dashboard, Alerts, Contacts, Messages, Settings, Camera Integration, Errors & Validation
- Supported locales: English (en) and Arabic (ar)
- Fallback returns the key itself if translation missing

---

## 10. Complete File Structure

```
lib/
├── main.dart                               # App entry point, MultiProvider, MaterialApp
├── models/
│   ├── user_model.dart                     # UserModel with toMap/fromMap/copyWith
│   ├── message_model.dart                  # MessageModel for chat messages
│   ├── contact_model.dart                  # ContactModel + ContactRelationship enum
│   └── alert_model.dart                    # AlertModel + AlertType/AlertStatus enums
├── providers/
│   ├── auth_provider.dart                  # Auth state, login/register/logout/session
│   ├── theme_provider.dart                 # Theme mode (light/dark/system)
│   ├── language_provider.dart              # Locale (en/ar)
│   ├── alert_provider.dart                 # Alerts CRUD, real-time Firestore listener
│   ├── contact_provider.dart               # Contacts CRUD, emergency contacts filtering
│   └── chat_provider.dart                  # Messages CRUD, real-time Firestore listener
├── screens/
│   ├── splash_screen.dart                  # Animated splash with auto-navigation
│   ├── onboarding_screen.dart              # 3-page PageView onboarding
│   ├── auth/
│   │   ├── login_screen.dart               # Email/password + Google sign-in
│   │   └── register_screen.dart            # Registration with validation
│   ├── home/
│   │   ├── home_screen.dart                # Bottom NavigationBar (5 tabs)
│   │   ├── dashboard_tab.dart              # Stats, recent alerts, welcome card
│   │   ├── alerts_tab.dart                 # Alert list with clear-all
│   │   ├── contacts_tab.dart               # Contact list with call/delete/emergency
│   │   ├── messages_tab.dart               # OLD placeholder
│   │   ├── messages_tab_new.dart           # NEW contact-based chat navigation
│   │   └── settings_tab.dart               # Profile, theme, language, camera, logout
│   ├── alert/
│   │   └── alert_detail_screen.dart        # Alert details + actions
│   ├── contact/
│   │   └── add_contact_screen.dart         # Add/edit contact form
│   ├── chat/
│   │   └── chat_screen.dart                # Real-time chat with read receipts
│   └── settings/
│       └── camera_integration_screen.dart  # Setup guide + server config
├── services/
│   ├── database_service.dart               # SQLite singleton (4 tables)
│   ├── firebase_service.dart               # Firebase initialization wrapper
│   ├── firebase_auth_service.dart          # Firebase Auth operations
│   ├── firestore_service.dart              # Firestore CRUD + streams
│   ├── firebase_options.dart               # Firebase config
│   └── notification_service.dart           # Local push notifications
└── utils/
    └── app_localization.dart               # 151 keys × 2 languages
```

---

## 11. Current Status

| Module | Status | Notes |
|--------|--------|-------|
| Authentication | ✅ Complete | Email/password + Google Sign-In |
| Dashboard & Alerts | ✅ Complete | Real-time Firestore listener |
| Contacts | ✅ Complete | Full CRUD + emergency toggle |
| Chat | ✅ Complete | Real-time messaging + read receipts |
| Camera Integration | ⚠️ UI Only | Backend integration not connected |
| Voice/Video Calls | ⏳ Placeholder | UI buttons only |
| Tests | ⚠️ Minimal | 1 smoke test only |
| Assets | ⚠️ Empty | Folders created, no files added |

---

## 12. Future AI Backend Integration

The app is designed to connect with a Python-based AI detection server:

```
Camera → AI Server → Detection → Alert Generation → Mobile App → Push Notification → Emergency Contacts
```

### AI Backend Components (To be integrated):
- **OpenCV** — Video capture & processing
- **MediaPipe Pose** — Skeleton detection (33 keypoints)
- **TensorFlow** — Gesture recognition (MLP/LSTM)
- **Scikit-learn** — Anomaly detection (Isolation Forest)
- **REST API / WebSocket** — Communication with mobile app

### Planned API Endpoints:
```
POST /api/alert/send          — Send alert from AI server to app
GET  /api/alerts              — Get alert history
PUT  /api/alert/:id/status    — Update alert status
POST /api/camera/connect      — Connect camera to system
GET  /api/camera/status       — Get camera status
POST /api/config/thresholds   — Update detection thresholds
```

---

*This document was generated from the project codebase for SRS reference purposes.*
