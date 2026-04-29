# Smart AI Camera - UML & Diagram Reference Guide
**Quick Reference for Creating Project Diagrams**

---

## 📊 ALL CLASSES IN THE APP

### 1. DATA MODELS (4 Classes)

#### UserModel
```
Class: UserModel
Attributes:
  - id: String
  - fullName: String
  - email: String
  - password: String
  - phoneNumber: String
  - profileImage: String (nullable)
  - createdAt: DateTime

Methods:
  + toMap(): Map<String, dynamic>
  + fromMap(Map<String, dynamic>): UserModel
  + copyWith(...): UserModel
```

#### AlertModel
```
Class: AlertModel
Attributes:
  - id: String
  - userId: String
  - alertType: AlertType (enum)
  - title: String
  - message: String
  - location: String (nullable)
  - timestamp: DateTime
  - status: AlertStatus (enum)
  - acknowledgedAt: DateTime (nullable)
  - resolvedAt: DateTime (nullable)
  - confidence: double (nullable)

Methods:
  + toMap(): Map<String, dynamic>
  + fromMap(Map<String, dynamic>): AlertModel
  + copyWith(...): AlertModel
  + typeString: String (getter)
  + statusString: String (getter)

Enums:
  AlertType { test, fall, immobility, emergencyGesture, abnormalActivity, medicalEmergency }
  AlertStatus { pending, active, acknowledged, resolved, falseAlarm }
```

#### ContactModel
```
Class: ContactModel
Attributes:
  - id: String
  - userId: String
  - name: String
  - phoneNumber: String
  - email: String (nullable)
  - relationship: Relationship (enum)
  - isEmergencyContact: bool
  - profileImage: String (nullable)
  - createdAt: DateTime

Methods:
  + toMap(): Map<String, dynamic>
  + fromMap(Map<String, dynamic>): ContactModel
  + copyWith(...): ContactModel
  + relationshipString: String (getter)

Enums:
  Relationship { family, friend, caregiver, doctor, nurse, other }
```

#### MessageModel
```
Class: MessageModel
Attributes:
  - id: String
  - senderId: String
  - receiverId: String
  - message: String
  - timestamp: DateTime
  - isRead: bool
  - attachmentUrl: String (nullable)

Methods:
  + toMap(): Map<String, dynamic>
  + fromMap(Map<String, dynamic>): MessageModel
  + copyWith(...): MessageModel
```

---

### 2. PROVIDERS (6 Classes - State Management)

#### AuthProvider
```
Class: AuthProvider extends ChangeNotifier
Attributes:
  - currentUser: UserModel (nullable)
  - isLoading: bool
  - prefs: SharedPreferences

Methods:
  + login(email: String, password: String): Future<bool>
  + register(user: UserModel): Future<bool>
  + logout(): Future<void>
  + loadUser(): Future<void>
  + isAuthenticated: bool (getter)

Dependencies:
  - DatabaseService
  - SharedPreferences
```

#### ThemeProvider
```
Class: ThemeProvider extends ChangeNotifier
Attributes:
  - themeMode: ThemeMode
  - lightTheme: ThemeData
  - darkTheme: ThemeData
  - prefs: SharedPreferences

Methods:
  + toggleTheme(): void
  + setThemeMode(mode: ThemeMode): Future<void>

Dependencies:
  - SharedPreferences
```

#### LanguageProvider
```
Class: LanguageProvider extends ChangeNotifier
Attributes:
  - locale: Locale
  - isRTL: bool
  - prefs: SharedPreferences

Methods:
  + toggleLanguage(): void
  + setLanguage(languageCode: String): Future<void>

Dependencies:
  - SharedPreferences
```

#### AlertProvider
```
Class: AlertProvider extends ChangeNotifier
Attributes:
  - alerts: List<AlertModel>
  - isLoading: bool
  - filterStatus: AlertStatus (nullable)

Methods:
  + loadAlerts(): Future<void>
  + createAlert(alert: AlertModel): Future<void>
  + updateAlertStatus(id: String, status: AlertStatus): Future<void>
  + deleteAlert(id: String): Future<void>
  + setFilter(status: AlertStatus): void
  + filteredAlerts: List<AlertModel> (getter)
  + activeAlertsCount: int (getter)
  + resolvedAlertsCount: int (getter)

Dependencies:
  - DatabaseService
  - NotificationService
```

#### ContactProvider
```
Class: ContactProvider extends ChangeNotifier
Attributes:
  - contacts: List<ContactModel>
  - isLoading: bool

Methods:
  + loadContacts(userId: String): Future<void>
  + addContact(contact: ContactModel): Future<void>
  + updateContact(contact: ContactModel): Future<void>
  + deleteContact(id: String): Future<void>
  + emergencyContacts: List<ContactModel> (getter)

Dependencies:
  - DatabaseService
```

#### ChatProvider
```
Class: ChatProvider extends ChangeNotifier
Attributes:
  - messages: List<MessageModel>
  - isLoading: bool
  - currentChatUserId: String (nullable)

Methods:
  + loadMessages(userId: String, otherUserId: String): Future<void>
  + sendMessage(senderId: String, receiverId: String, message: String, attachmentUrl: String): Future<void>
  + markAsRead(messageId: String): Future<void>
  + getLastMessageForContact(userId: String, contactId: String): Future<Map<String, dynamic>>
  + clearCurrentChat(): void

Dependencies:
  - DatabaseService
```

---

### 3. SERVICES (2 Classes - Singleton Pattern)

#### DatabaseService
```
Class: DatabaseService (Singleton)
Attributes:
  - instance: DatabaseService (static)
  - database: Database (private)

Methods:
  // User Operations
  + insertUser(user: UserModel): Future<void>
  + getUserById(id: String): Future<UserModel>
  + getUserByEmail(email: String): Future<UserModel>
  + updateUser(user: UserModel): Future<void>
  
  // Alert Operations
  + insertAlert(alert: AlertModel): Future<void>
  + getAlertsByUserId(userId: String): Future<List<AlertModel>>
  + getAlertsByType(userId: String, type: AlertType): Future<List<AlertModel>>
  + getAlertsByStatus(userId: String, status: AlertStatus): Future<List<AlertModel>>
  + updateAlert(alert: AlertModel): Future<void>
  + deleteAlert(id: String): Future<void>
  
  // Contact Operations
  + insertContact(contact: ContactModel): Future<void>
  + getContactsByUserId(userId: String): Future<List<ContactModel>>
  + updateContact(contact: ContactModel): Future<void>
  + deleteContact(id: String): Future<void>
  
  // Message Operations
  + insertMessage(message: MessageModel): Future<void>
  + getMessagesBetweenUsers(userId1: String, userId2: String): Future<List<MessageModel>>
  + updateMessage(message: MessageModel): Future<void>
  
  + close(): Future<void>

Dependencies:
  - sqflite (SQLite database)
```

#### NotificationService
```
Class: NotificationService (Singleton)
Attributes:
  - instance: NotificationService (static)
  - flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin (private)

Methods:
  + initialize(): Future<void>
  + showAlertNotification(alert: AlertModel): Future<void>
  + showMessageNotification(title: String, body: String): Future<void>

Dependencies:
  - flutter_local_notifications
```

---

### 4. SCREENS (15 Classes)

#### SplashScreen
```
Class: SplashScreen extends StatefulWidget
Purpose: App initialization and routing
Duration: 2 seconds
Navigation Logic:
  - First launch → OnboardingScreen
  - Not authenticated → LoginScreen
  - Authenticated → HomeScreen
```

#### OnboardingScreen
```
Class: OnboardingScreen extends StatefulWidget
Purpose: First-time user introduction
Pages: 3 slides
Components:
  - PageView
  - Page indicators
  - Skip button
  - Get Started button
```

#### LoginScreen
```
Class: LoginScreen extends StatefulWidget
Purpose: User authentication
Fields:
  - Email (TextFormField)
  - Password (TextFormField)
Actions:
  - Login button → HomeScreen
  - Register link → RegisterScreen
Validation:
  - Email format
  - Password required
Dependencies:
  - AuthProvider
```

#### RegisterScreen
```
Class: RegisterScreen extends StatefulWidget
Purpose: New user registration
Fields:
  - Full Name
  - Email
  - Phone Number
  - Password
  - Confirm Password
Actions:
  - Register button → HomeScreen
  - Login link → LoginScreen
Validation:
  - All fields required
  - Email format
  - Phone format
  - Password match
Dependencies:
  - AuthProvider
```

#### HomeScreen
```
Class: HomeScreen extends StatefulWidget
Purpose: Main navigation hub
Components:
  - BottomNavigationBar (5 tabs)
  - Tab content (5 screens)
Tabs:
  1. DashboardTab
  2. AlertsTab
  3. ContactsTab
  4. MessagesTab
  5. SettingsTab
```

#### DashboardTab
```
Class: DashboardTab extends StatelessWidget
Purpose: Overview and statistics
Components:
  - Statistics cards (4 cards)
  - Recent alerts list
  - Test alert button
Dependencies:
  - AlertProvider
  - ContactProvider
```

#### AlertsTab
```
Class: AlertsTab extends StatefulWidget
Purpose: Alert management
Components:
  - Filter chips (6 filters)
  - Alert list (ListView)
  - Floating Action Button
Actions:
  - Tap alert → AlertDetailScreen
  - Swipe → Delete alert
  - FAB → Create test alert
Dependencies:
  - AlertProvider
```

#### AlertDetailScreen
```
Class: AlertDetailScreen extends StatefulWidget
Purpose: Single alert details and actions
Components:
  - Alert info display
  - Status timeline
  - Action buttons
Actions:
  - Acknowledge
  - Resolve
  - Mark as False Alarm
  - Delete
Dependencies:
  - AlertProvider
```

#### ContactsTab
```
Class: ContactsTab extends StatefulWidget
Purpose: Contact management
Components:
  - Emergency contacts section
  - All contacts list
  - Floating Action Button
Actions:
  - Tap contact → AddContactScreen (edit mode)
  - Call button → Phone dialer
  - Message button → ChatScreen
  - FAB → AddContactScreen
Dependencies:
  - ContactProvider
```

#### AddContactScreen
```
Class: AddContactScreen extends StatefulWidget
Purpose: Add or edit contact
Fields:
  - Name
  - Phone Number
  - Email (optional)
  - Relationship (dropdown)
  - Emergency Contact (switch)
Actions:
  - Save → ContactsTab
  - Cancel → ContactsTab
Validation:
  - Name required
  - Phone required & format
Dependencies:
  - ContactProvider
```

#### MessagesTab
```
Class: MessagesTab extends StatefulWidget
Purpose: Conversation list
Components:
  - Contact list with last message
  - Unread badge
  - Empty state
Actions:
  - Tap contact → ChatScreen
Dependencies:
  - ContactProvider
  - ChatProvider
```

#### ChatScreen
```
Class: ChatScreen extends StatefulWidget
Purpose: One-on-one messaging
Components:
  - App bar (name, call, video buttons)
  - Message list (ListView)
  - Input field with send button
Actions:
  - Send message
  - Call button → Phone dialer
  - Video button → Coming soon
Dependencies:
  - ChatProvider
  - url_launcher (for calls)
```

#### SettingsTab
```
Class: SettingsTab extends StatelessWidget
Purpose: App settings and preferences
Sections:
  - Profile info
  - Theme toggle
  - Language selector
  - Camera integration
  - About & logout
Actions:
  - Toggle dark mode
  - Change language
  - Logout
Dependencies:
  - AuthProvider
  - ThemeProvider
  - LanguageProvider
```

#### CameraIntegrationScreen
```
Class: CameraIntegrationScreen extends StatelessWidget
Purpose: AI backend integration guide
Components:
  - Connection status
  - Integration steps
  - API documentation
```

---

## 🔗 RELATIONSHIPS FOR CLASS DIAGRAM

### Inheritance
```
ChangeNotifier
  ↑
  ├── AuthProvider
  ├── ThemeProvider
  ├── LanguageProvider
  ├── AlertProvider
  ├── ContactProvider
  └── ChatProvider

StatelessWidget
  ↑
  ├── DashboardTab
  ├── SettingsTab
  └── CameraIntegrationScreen

StatefulWidget
  ↑
  ├── SplashScreen
  ├── OnboardingScreen
  ├── LoginScreen
  ├── RegisterScreen
  ├── HomeScreen
  ├── AlertsTab
  ├── AlertDetailScreen
  ├── ContactsTab
  ├── AddContactScreen
  ├── MessagesTab
  └── ChatScreen
```

### Composition (Has-A)
```
AuthProvider has UserModel
AlertProvider has List<AlertModel>
ContactProvider has List<ContactModel>
ChatProvider has List<MessageModel>

HomeScreen has:
  - DashboardTab
  - AlertsTab
  - ContactsTab
  - MessagesTab
  - SettingsTab
```

### Dependencies (Uses)
```
AuthProvider → DatabaseService
AlertProvider → DatabaseService, NotificationService
ContactProvider → DatabaseService
ChatProvider → DatabaseService

LoginScreen → AuthProvider
RegisterScreen → AuthProvider
DashboardTab → AlertProvider, ContactProvider
AlertsTab → AlertProvider
ContactsTab → ContactProvider
MessagesTab → ContactProvider, ChatProvider
ChatScreen → ChatProvider
SettingsTab → AuthProvider, ThemeProvider, LanguageProvider
```

### Association (1:N Relationships)
```
UserModel (1) ←→ (N) AlertModel
UserModel (1) ←→ (N) ContactModel
ContactModel (2) ←→ (N) MessageModel (sender/receiver)
```

---

## 📊 DATABASE ER DIAGRAM

### Tables & Relationships
```
┌──────────────────┐         ┌──────────────────┐
│      Users       │         │     Alerts       │
├──────────────────┤         ├──────────────────┤
│ id (PK)          │◄───────┤│ id (PK)          │
│ fullName         │    1:N  │ userId (FK)      │
│ email (UNIQUE)   │         │ alertType        │
│ password         │         │ title            │
│ phoneNumber      │         │ message          │
│ profileImage     │         │ location         │
│ createdAt        │         │ timestamp        │
└──────────────────┘         │ status           │
         │                   │ acknowledgedAt   │
         │                   │ resolvedAt       │
         │ 1:N               │ confidence       │
         │                   └──────────────────┘
         ▼
┌──────────────────┐         ┌──────────────────┐
│    Contacts      │         │    Messages      │
├──────────────────┤         ├──────────────────┤
│ id (PK)          │         │ id (PK)          │
│ userId (FK)      │         │ senderId         │
│ name             │         │ receiverId       │
│ phoneNumber      │         │ message          │
│ email            │         │ timestamp        │
│ relationship     │         │ isRead           │
│ isEmergencyContact│        │ attachmentUrl    │
│ profileImage     │         └──────────────────┘
│ createdAt        │
└──────────────────┘
```

---

## 🔄 SEQUENCE DIAGRAMS (9 Flows)

### 1. User Registration
```
User → RegisterScreen → AuthProvider → DatabaseService → SQLite
                           ↓
                     SharedPreferences
                           ↓
                      HomeScreen
```

**Detailed Steps:**
1. User enters registration data
2. RegisterScreen validates form
3. AuthProvider.register() called
4. DatabaseService checks email uniqueness
5. DatabaseService.insertUser() saves to SQLite
6. AuthProvider saves user ID to SharedPreferences
7. Navigate to HomeScreen

---

### 2. User Login
```
User → LoginScreen → AuthProvider → DatabaseService → SQLite
                        ↓
                  SharedPreferences
                        ↓
                   HomeScreen
```

**Detailed Steps:**
1. User enters email & password
2. LoginScreen validates form
3. AuthProvider.login() called
4. DatabaseService.getUserByEmail() queries SQLite
5. Password verified
6. AuthProvider saves user ID to SharedPreferences
7. Navigate to HomeScreen

---

### 3. Create Test Alert
```
User → DashboardTab/AlertsTab → AlertProvider → DatabaseService → SQLite
                                       ↓
                               NotificationService
                                       ↓
                                 System Notification
```

**Detailed Steps:**
1. User taps "Test Alert" button
2. AlertProvider.createAlert() called
3. AlertModel created (type: test, status: pending)
4. DatabaseService.insertAlert() saves to SQLite
5. NotificationService.showAlertNotification() triggered
6. System shows notification
7. AlertProvider.notifyListeners() updates UI

---

### 4. Update Alert Status
```
User → AlertsTab → AlertDetailScreen → AlertProvider → DatabaseService → SQLite
                                            ↓
                                    notifyListeners()
                                            ↓
                                      UI Updates
```

**Detailed Steps:**
1. User taps alert card
2. Navigate to AlertDetailScreen
3. User taps "Acknowledge" or "Resolve"
4. AlertProvider.updateAlertStatus() called
5. AlertModel updated with new status
6. DatabaseService.updateAlert() saves to SQLite
7. AlertProvider.notifyListeners() refreshes UI

---

### 5. Add Contact
```
User → ContactsTab → AddContactScreen → ContactProvider → DatabaseService → SQLite
                                             ↓
                                     notifyListeners()
                                             ↓
                                       ContactsTab
```

**Detailed Steps:**
1. User taps FAB (+)
2. Navigate to AddContactScreen
3. User enters contact details
4. ContactProvider.addContact() called
5. ContactModel created and validated
6. DatabaseService.insertContact() saves to SQLite
7. ContactProvider.notifyListeners() updates list
8. Navigate back to ContactsTab

---

### 6. Send Message
```
User → MessagesTab → ChatScreen → ChatProvider → DatabaseService → SQLite
                                       ↓
                               notifyListeners()
                                       ↓
                                 Message Appears
```

**Detailed Steps:**
1. User taps contact in MessagesTab
2. Navigate to ChatScreen
3. ChatProvider.loadMessages() loads conversation
4. User types message and taps send
5. ChatProvider.sendMessage() called
6. MessageModel created
7. DatabaseService.insertMessage() saves to SQLite
8. ChatProvider.loadMessages() refreshes
9. UI scrolls to bottom

---

### 7. Make Phone Call
```
User → ChatScreen/ContactsTab → url_launcher → Device Phone Dialer → Phone Call
```

**Detailed Steps:**
1. User taps call button (📞)
2. Extract phoneNumber from ContactModel
3. Create tel: URI scheme
4. url_launcher.launchUrl() called
5. Device phone dialer opens
6. User makes call

---

### 8. Toggle Theme
```
User → SettingsTab → ThemeProvider → SharedPreferences
                          ↓
                  notifyListeners()
                          ↓
                    MaterialApp
                          ↓
                   Entire App Rebuilds
```

**Detailed Steps:**
1. User taps Dark Mode switch
2. ThemeProvider.toggleTheme() called
3. ThemeMode switches (light ↔ dark)
4. SharedPreferences saves preference
5. ThemeProvider.notifyListeners() called
6. MaterialApp rebuilds with new theme
7. All screens update appearance

---

### 9. Change Language
```
User → SettingsTab → LanguageProvider → SharedPreferences
                          ↓
                  notifyListeners()
                          ↓
                    MaterialApp
                          ↓
                   Entire App Rebuilds
```

**Detailed Steps:**
1. User selects language (English/Arabic)
2. LanguageProvider.setLanguage() called
3. Locale updated
4. isRTL flag set for Arabic
5. SharedPreferences saves preference
6. LanguageProvider.notifyListeners() called
7. MaterialApp rebuilds with new locale
8. All text updates, layout mirrors for RTL

---

## 🎯 USE CASE DIAGRAM

### Actors
```
1. User (primary)
2. System (secondary)
3. AI Backend (external - not implemented)
```

### Use Cases

**User:**
- Register Account
- Login
- Logout
- View Dashboard
- View Alerts
- Create Test Alert
- Acknowledge Alert
- Resolve Alert
- Delete Alert
- View Contacts
- Add Contact
- Edit Contact
- Delete Contact
- Call Contact
- Send Message
- View Messages
- Change Theme
- Change Language
- View Camera Integration Guide

**System:**
- Validate Input
- Store Data (SQLite)
- Retrieve Data
- Show Notification
- Launch Phone Dialer

**AI Backend (Future):**
- Detect Fall
- Detect Emergency
- Send Real-time Alert

---

## 📈 STATE DIAGRAM

### Alert Status Lifecycle
```
[Created] 
    ↓
[Pending] ──────→ [False Alarm]
    ↓
[Active] ────────→ [False Alarm]
    ↓
[Acknowledged] ──→ [False Alarm]
    ↓
[Resolved]
```

**States:**
- **Pending**: Just created, awaiting review
- **Active**: Currently happening
- **Acknowledged**: User saw and acknowledged
- **Resolved**: Issue resolved
- **False Alarm**: Not a real emergency

**Transitions:**
- Pending → Active (system)
- Active → Acknowledged (user action)
- Acknowledged → Resolved (user action)
- Any → False Alarm (user action)

---

### User Authentication State
```
[Not Authenticated]
    ↓
[Registering] ─→ [Registration Failed] ─→ [Not Authenticated]
    ↓
[Authenticated] ←─ [Logging In] ←─ [Not Authenticated]
    ↓
[Active Session]
    ↓
[Logged Out] ─→ [Not Authenticated]
```

---

## 🏗️ ARCHITECTURE DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Splash  │  │Onboarding│  │  Login   │  │ Register │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Home Screen                          │  │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  │  │
│  │  │Dash  │  │Alerts│  │Contacts│ │Messages│ │Settings│  │
│  │  └──────┘  └──────┘  └──────┘  └──────┘  └──────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │AlertDetail AddContact│  │   Chat   │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
└───────────────────────┬──────────────────────────────────────┘
                        │ (uses)
┌───────────────────────▼──────────────────────────────────────┐
│                   STATE MANAGEMENT (Provider)                 │
│                                                              │
│  ┌────────┐ ┌──────┐ ┌─────────┐ ┌─────┐ ┌───────┐ ┌────┐│
│  │  Auth  │ │Theme │ │Language │ │Alert│ │Contact│ │Chat││
│  │Provider│ │Provider│Provider │ │Provider│Provider│Provider││
│  └────────┘ └──────┘ └─────────┘ └─────┘ └───────┘ └────┘│
└───────────────────────┬──────────────────────────────────────┘
                        │ (manages)
┌───────────────────────▼──────────────────────────────────────┐
│                      BUSINESS LOGIC                           │
│                                                              │
│  ┌──────┐  ┌─────┐  ┌───────┐  ┌───────┐                  │
│  │ User │  │Alert│  │Contact│  │Message│                  │
│  │Model │  │Model│  │ Model │  │ Model │                  │
│  └──────┘  └─────┘  └───────┘  └───────┘                  │
└───────────────────────┬──────────────────────────────────────┘
                        │ (persists)
┌───────────────────────▼──────────────────────────────────────┐
│                       DATA LAYER                              │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                  │
│  │  Database    │         │ Notification │                  │
│  │  Service     │◄───────►│   Service    │                  │
│  └──────┬───────┘         └──────────────┘                  │
│         │                                                     │
│  ┌──────▼───────┐         ┌──────────────┐                  │
│  │    SQLite    │         │SharedPrefs   │                  │
│  │   Database   │         │              │                  │
│  └──────────────┘         └──────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 COMPONENT DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                       │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │               UI Components (Screens)                 │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│  ┌────────────────────▼─────────────────────────────────┐  │
│  │         State Management (Provider Pattern)          │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│  ┌────────────────────▼─────────────────────────────────┐  │
│  │              Business Logic (Models)                  │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│  ┌────────────────────▼─────────────────────────────────┐  │
│  │               Services Layer                          │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
└───────────────────────┼──────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
┌───────▼──────┐  ┌─────▼─────┐  ┌─────▼─────┐
│   SQLite     │  │  Shared   │  │Local      │
│   Database   │  │Preferences│  │Notifications│
└──────────────┘  └───────────┘  └───────────┘
```

---

## 🔄 ACTIVITY DIAGRAM - User Registration Flow

```
[Start]
   ↓
[Open App]
   ↓
[See Splash Screen]
   ↓
{First Time?} ─No─→ {Logged In?} ─Yes─→ [Home Screen] → [End]
   │                      │
   Yes                   No
   ↓                      ↓
[Onboarding]          [Login Screen]
   ↓                      ↓
[Tap Get Started]    [Enter Credentials] → {Valid?} ─No─→ [Show Error] ─┐
   ↓                                           │                         │
[Register Screen]                             Yes                        │
   ↓                                           ↓                         │
[Fill Form]                                [Success] → [Home Screen]     │
   ↓                                                                     │
{Valid Input?} ─No─→ [Show Validation Errors] ────────────────────────┘
   │
   Yes
   ↓
[Create Account]
   ↓
{Email Exists?} ─Yes─→ [Show Error] ──┐
   │                                   │
   No                                  │
   ↓                                   │
[Save to Database]                     │
   ↓                                   │
[Save Session]                         │
   ↓                                   │
[Show Success]                         │
   ↓                                   │
[Navigate to Home] ←───────────────────┘
   ↓
[End]
```

---

## 📊 DEPLOYMENT DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                      User's Device                           │
│                    (Android/iOS)                             │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Flutter Application (.apk/.ipa)            │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────┐    │  │
│  │  │           Application Layer                  │    │  │
│  │  │    (Screens, Providers, Models)              │    │  │
│  │  └─────────────────┬────────────────────────────┘    │  │
│  │                    │                                  │  │
│  │  ┌─────────────────▼────────────────────────────┐    │  │
│  │  │           Local Storage Layer                │    │  │
│  │  │                                              │    │  │
│  │  │  ┌─────────────┐     ┌──────────────┐      │    │  │
│  │  │  │   SQLite    │     │  Shared      │      │    │  │
│  │  │  │  Database   │     │ Preferences  │      │    │  │
│  │  │  └─────────────┘     └──────────────┘      │    │  │
│  │  └──────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Device Services                              │  │
│  │  - Phone Dialer                                       │  │
│  │  - Notification System                                │  │
│  │  - File System                                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ (Future Connection)
                            │ HTTP/WebSocket
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Backend Server (Future)                    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Python Flask/FastAPI Server                │  │
│  │                                                       │  │
│  │  - REST API Endpoints                                │  │
│  │  - WebSocket for Real-time                           │  │
│  │  - AI Processing (OpenCV + MediaPipe)                │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            Camera System (IP Camera)                  │  │
│  │  - Video Feed                                         │  │
│  │  - Fall Detection                                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 PACKAGE DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                      grad_app                                │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │   models   │  │ providers  │  │  services  │           │
│  │            │  │            │  │            │           │
│  │ UserModel  │  │AuthProvider│  │Database    │           │
│  │AlertModel  │  │ThemeProvider│ │Service     │           │
│  │ContactModel│  │LanguageProvider│Notification│           │
│  │MessageModel│  │AlertProvider│ │Service     │           │
│  └────────────┘  │ContactProvider│└────────────┘           │
│                  │ChatProvider│                             │
│                  └────────────┘                             │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │  screens   │  │   utils    │  │   assets   │           │
│  │            │  │            │  │            │           │
│  │ auth/      │  │AppLocal    │  │ images/    │           │
│  │ home/      │  │ization     │  │ icons/     │           │
│  │ chat/      │  │            │  │ animations/│           │
│  └────────────┘  └────────────┘  └────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 QUICK SUMMARY FOR DIAGRAMS

### For Class Diagram:
- **4 Models**: UserModel, AlertModel, ContactModel, MessageModel
- **6 Providers**: Auth, Theme, Language, Alert, Contact, Chat
- **2 Services**: DatabaseService, NotificationService
- **15 Screens**: Listed above
- **Relationships**: Inheritance (ChangeNotifier), Composition (has-a), Dependencies (uses)

### For ER Diagram:
- **4 Tables**: users, alerts, contacts, messages
- **Relationships**: 
  - users (1) → (N) alerts
  - users (1) → (N) contacts
  - contacts (2) → (N) messages

### For Sequence Diagrams:
- **9 Complete Flows** detailed above

### For Use Case Diagram:
- **3 Actors**: User, System, AI Backend (future)
- **19 Use Cases** listed above

### For State Diagram:
- **Alert Lifecycle**: 5 states (Pending, Active, Acknowledged, Resolved, False Alarm)
- **Auth Lifecycle**: 4 states (Not Authenticated, Logging In, Authenticated, Logged Out)

### For Activity Diagram:
- Registration flow detailed above
- Similar flows for login, alerts, messaging

### For Architecture Diagram:
- **4 Layers**: Presentation, State Management, Business Logic, Data Layer
- Clean architecture pattern

### For Deployment Diagram:
- Mobile device with app + local storage
- Future backend server with AI
- Device services integration

---

**End of UML Reference Guide**  
Use this document to create all project diagrams.
