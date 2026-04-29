# Smart AI Camera - Quick Reference for Diagrams & UML
**For Team Member: Diagram & UML Creation**

## 🎯 Purpose
This document contains all classes, relationships, flows, and structures needed to create UML diagrams for the graduation project.

**App Type:** Medical Emergency Detection Mobile App  
**Framework:** Flutter  
**State Management:** Provider  
**Database:** SQLite  

---

## 🎯 Project Scope

### What the App DOES:
✅ User authentication and registration  
✅ Real-time alert management and notifications  
✅ Emergency contact management  
✅ Text messaging between contacts  
✅ Phone call integration  
✅ Dashboard with statistics  
✅ Dark/Light theme switching  
✅ Bilingual interface (English/Arabic)  
✅ Local data persistence  
✅ Test alert functionality  

### What the App DOES NOT:
❌ AI Detection (handled by backend Python server)  
❌ Pose estimation (OpenCV + MediaPipe backend)  
❌ Video processing (camera server handles this)  
❌ Real-time video streaming (backend feature)  

### Integration Point:
The app is designed to connect to a Python backend server (Flask/FastAPI) that performs:
- Fall detection using OpenCV + MediaPipe
- Pose estimation and tracking
- Medical emergency pattern recognition
- Real-time video processing

---

## 🏗️ System Architecture

### Architecture Pattern: Clean Architecture + MVVM

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Screens   │  │   Widgets   │  │   Dialogs   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    STATE MANAGEMENT                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Providers  │  │ChangeNotifier│  │  Consumer    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                     BUSINESS LOGIC                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Models    │  │ Validators  │  │   Utils     │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Services   │  │   Database   │  │  Local Prefs │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Database Schema (SQLite)

### Entity-Relationship Diagram

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
         │                   │ confidence       │
         │                   └──────────────────┘
         │
         │ 1:N
         │
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

### Table Specifications

#### **Users Table**
```sql
CREATE TABLE users(
  id TEXT PRIMARY KEY,                -- UUID
  fullName TEXT NOT NULL,             -- User's full name
  email TEXT NOT NULL UNIQUE,         -- Login credential
  password TEXT NOT NULL,             -- Hashed (in production)
  phoneNumber TEXT NOT NULL,          -- Contact number
  profileImage TEXT,                  -- Optional avatar URL
  createdAt TEXT NOT NULL            -- ISO 8601 timestamp
)
```

#### **Alerts Table**
```sql
CREATE TABLE alerts(
  id TEXT PRIMARY KEY,                -- UUID
  userId TEXT NOT NULL,               -- Owner of alert
  alertType INTEGER NOT NULL,         -- Enum: 0-6 (see AlertType)
  title TEXT NOT NULL,                -- Alert headline
  message TEXT NOT NULL,              -- Alert description
  location TEXT,                      -- Optional location data
  timestamp TEXT NOT NULL,            -- ISO 8601
  status INTEGER NOT NULL,            -- Enum: 0-4 (see AlertStatus)
  acknowledgedAt TEXT,                -- When user acknowledged
  resolvedAt TEXT,                    -- When alert resolved
  confidence REAL,                    -- AI confidence (0.0-1.0)
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
)
```

#### **Contacts Table**
```sql
CREATE TABLE contacts(
  id TEXT PRIMARY KEY,                -- UUID
  userId TEXT NOT NULL,               -- Owner of contact
  name TEXT NOT NULL,                 -- Contact name
  phoneNumber TEXT NOT NULL,          -- Phone for calls
  email TEXT,                         -- Optional email
  relationship INTEGER NOT NULL,      -- Enum: 0-5 (see Relationship)
  isEmergencyContact INTEGER NOT NULL,-- Boolean (0/1)
  profileImage TEXT,                  -- Optional avatar
  createdAt TEXT NOT NULL,            -- ISO 8601
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
)
```

#### **Messages Table**
```sql
CREATE TABLE messages(
  id TEXT PRIMARY KEY,                -- UUID
  senderId TEXT NOT NULL,             -- Message sender
  receiverId TEXT NOT NULL,           -- Message recipient
  message TEXT NOT NULL,              -- Message content
  timestamp TEXT NOT NULL,            -- ISO 8601
  isRead INTEGER NOT NULL,            -- Boolean (0/1)
  attachmentUrl TEXT                  -- Optional file/image
)
```

---

## 🎨 Data Models

### 1. UserModel
**Purpose:** Represents authenticated user  
**File:** `lib/models/user_model.dart`

```dart
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String phoneNumber;
  final String? profileImage;
  final DateTime createdAt;
}
```

**Methods:**
- `toMap()` - Convert to SQLite map
- `fromMap(Map)` - Create from database
- `copyWith()` - Immutable updates

---

### 2. AlertModel
**Purpose:** Emergency alert data structure  
**File:** `lib/models/alert_model.dart`

```dart
enum AlertType {
  test,              // 0 - Manual test alert
  fall,              // 1 - Fall detected by AI
  immobility,        // 2 - No movement detected
  emergencyGesture,  // 3 - Help gesture recognized
  abnormalActivity,  // 4 - Unusual behavior
  medicalEmergency   // 5 - Critical medical event
}

enum AlertStatus {
  pending,       // 0 - Just created
  active,        // 1 - Currently active
  acknowledged,  // 2 - User saw it
  resolved,      // 3 - Issue resolved
  falseAlarm     // 4 - Not a real emergency
}

class AlertModel {
  final String id;
  final String userId;
  final AlertType alertType;
  final String title;
  final String message;
  final String? location;
  final DateTime timestamp;
  final AlertStatus status;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final double? confidence;  // AI confidence score
}
```

**Computed Properties:**
- `typeString` - Human-readable alert type
- `statusString` - Human-readable status

---

### 3. ContactModel
**Purpose:** Emergency contact information  
**File:** `lib/models/contact_model.dart`

```dart
enum Relationship {
  family,     // 0
  friend,     // 1
  caregiver,  // 2
  doctor,     // 3
  nurse,      // 4
  other       // 5
}

class ContactModel {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String? email;
  final Relationship relationship;
  final bool isEmergencyContact;
  final String? profileImage;
  final DateTime createdAt;
}
```

**Computed Properties:**
- `relationshipString` - Human-readable relationship

---

### 4. MessageModel
**Purpose:** Chat message between users  
**File:** `lib/models/message_model.dart`

```dart
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
}
```

---

## 🔄 State Management (Providers)

### 1. AuthProvider
**File:** `lib/providers/auth_provider.dart`  
**Purpose:** User authentication and session management

**Properties:**
- `UserModel? currentUser` - Currently logged-in user
- `bool isLoading` - Loading state indicator

**Methods:**
```dart
Future<bool> login(String email, String password)
Future<bool> register(UserModel user)
Future<void> logout()
Future<void> loadUser()
bool get isAuthenticated
```

**Persistence:** Uses SharedPreferences to store user ID

---

### 2. ThemeProvider
**File:** `lib/providers/theme_provider.dart`  
**Purpose:** Dark/Light mode management

**Properties:**
- `ThemeMode themeMode` - Current theme (light/dark/system)
- `ThemeData lightTheme` - Light theme configuration
- `ThemeData darkTheme` - Dark theme configuration

**Methods:**
```dart
void toggleTheme()
Future<void> setThemeMode(ThemeMode mode)
```

**Theme Configuration:**
- Material Design 3
- Google Fonts (Poppins)
- Custom color schemes
- Dynamic ColorScheme.fromSeed

---

### 3. LanguageProvider
**File:** `lib/providers/language_provider.dart`  
**Purpose:** Bilingual support (English/Arabic)

**Properties:**
- `Locale locale` - Current language locale
- `bool isRTL` - Right-to-left layout flag

**Methods:**
```dart
void toggleLanguage()
Future<void> setLanguage(String languageCode)
```

**Supported Languages:**
- English (en) - LTR
- Arabic (ar) - RTL with full mirroring

---

### 4. AlertProvider
**File:** `lib/providers/alert_provider.dart`  
**Purpose:** Alert management and filtering

**Properties:**
- `List<AlertModel> alerts` - All alerts
- `bool isLoading` - Loading indicator
- `AlertStatus? filterStatus` - Current filter

**Methods:**
```dart
Future<void> loadAlerts()
Future<void> createAlert(AlertModel alert)
Future<void> updateAlertStatus(String id, AlertStatus status)
Future<void> deleteAlert(String id)
void setFilter(AlertStatus? status)
List<AlertModel> get filteredAlerts
int get activeAlertsCount
int get resolvedAlertsCount
```

**Notifications:** Triggers local notifications on new alerts

---

### 5. ContactProvider
**File:** `lib/providers/contact_provider.dart`  
**Purpose:** Contact management

**Properties:**
- `List<ContactModel> contacts` - All contacts
- `bool isLoading` - Loading indicator

**Methods:**
```dart
Future<void> loadContacts(String userId)
Future<void> addContact(ContactModel contact)
Future<void> updateContact(ContactModel contact)
Future<void> deleteContact(String id)
List<ContactModel> get emergencyContacts
```

---

### 6. ChatProvider
**File:** `lib/providers/chat_provider.dart`  
**Purpose:** Messaging and chat management

**Properties:**
- `List<MessageModel> messages` - Current conversation
- `bool isLoading` - Loading indicator
- `String? currentChatUserId` - Active chat contact

**Methods:**
```dart
Future<void> loadMessages(String userId, String otherUserId)
Future<void> sendMessage({
  required String senderId,
  required String receiverId,
  required String message,
  String? attachmentUrl,
})
Future<void> markAsRead(String messageId)
Future<Map<String, dynamic>> getLastMessageForContact(
  String userId,
  String contactId,
)
void clearCurrentChat()
```

---

## 🛠️ Services

### 1. DatabaseService
**File:** `lib/services/database_service.dart`  
**Pattern:** Singleton  
**Purpose:** SQLite database operations

**Initialization:**
```dart
static final DatabaseService instance = DatabaseService._init();
Future<Database> get database
```

**Methods:**

**Users:**
- `insertUser(UserModel user)`
- `getUserById(String id)`
- `getUserByEmail(String email)`
- `updateUser(UserModel user)`

**Alerts:**
- `insertAlert(AlertModel alert)`
- `getAlertsByUserId(String userId)`
- `getAlertsByType(String userId, AlertType type)`
- `getAlertsByStatus(String userId, AlertStatus status)`
- `updateAlert(AlertModel alert)`
- `deleteAlert(String id)`

**Contacts:**
- `insertContact(ContactModel contact)`
- `getContactsByUserId(String userId)`
- `updateContact(ContactModel contact)`
- `deleteContact(String id)`

**Messages:**
- `insertMessage(MessageModel message)`
- `getMessagesBetweenUsers(String userId1, String userId2)`
- `updateMessage(MessageModel message)`

---

### 2. NotificationService
**File:** `lib/services/notification_service.dart`  
**Pattern:** Singleton  
**Purpose:** Local push notifications

**Package:** `flutter_local_notifications: ^17.2.4`

**Methods:**
```dart
Future<void> initialize()
Future<void> showAlertNotification(AlertModel alert)
Future<void> showMessageNotification(String title, String body)
```

**Configuration:**
- Android channel: "alerts"
- Importance: High priority
- Sound: Default notification sound
- Vibration: Enabled

---

## 📱 Screen Structure

### Application Flow

```
Splash Screen (2s)
    │
    ├─► Onboarding (first launch)
    │       │
    │       └─► Login/Register
    │
    └─► Login (returning user)
            │
            └─► Home Screen (Bottom Navigation)
                    ├─► Dashboard Tab
                    ├─► Alerts Tab
                    ├─► Contacts Tab
                    ├─► Messages Tab
                    └─► Settings Tab
```

---

### Screen Details

#### 1. **Splash Screen**
**File:** `lib/screens/splash_screen.dart`  
**Duration:** 2 seconds  
**Purpose:** Branding and initialization check  
**Navigation Logic:**
- First launch → Onboarding
- Not authenticated → Login
- Authenticated → Home

---

#### 2. **Onboarding Screen**
**File:** `lib/screens/onboarding_screen.dart`  
**Pages:** 3 slides  
**Content:**
1. **Real-Time Monitoring:** AI-powered fall detection
2. **Instant Alerts:** Immediate emergency notifications
3. **Emergency Contacts:** Quick access to help

**Features:**
- Page indicators (dots)
- Skip button
- Get Started button
- Smooth page transitions

---

#### 3. **Login Screen**
**File:** `lib/screens/auth/login_screen.dart`  
**Fields:**
- Email (validated)
- Password (obscured)

**Features:**
- Form validation
- Remember me checkbox
- Forgot password link (placeholder)
- Register navigation
- "Developed by ZYAD" credit

**Validation:**
- Email format check
- Password minimum length
- Required field validation

---

#### 4. **Register Screen**
**File:** `lib/screens/auth/register_screen.dart`  
**Fields:**
- Full Name
- Email
- Phone Number
- Password
- Confirm Password

**Validation:**
- Email uniqueness
- Phone format
- Password strength
- Password match
- All fields required

---

#### 5. **Home Screen** (Bottom Navigation)
**File:** `lib/screens/home/home_screen.dart`  
**Tabs:** 5 main sections

##### 5.1 Dashboard Tab
**File:** `lib/screens/home/dashboard_tab.dart`

**Components:**
- **Statistics Cards:**
  - Total Alerts
  - Active Alerts
  - Resolved Alerts
  - Emergency Contacts

- **Recent Alerts List:**
  - Last 5 alerts
  - Color-coded by type
  - Status badges
  - Tap to view details

- **Quick Actions:**
  - Test Alert button
  - View All Alerts

**Layout:** Grid + List view

---

##### 5.2 Alerts Tab
**File:** `lib/screens/home/alerts_tab.dart`

**Features:**
- **Filter Chips:**
  - All
  - Pending
  - Active
  - Acknowledged
  - Resolved
  - False Alarm

- **Alert List:**
  - Chronological order
  - Alert type icons
  - Status color coding
  - Timestamp
  - Confidence score (if AI)
  - Swipe to delete

- **Empty State:** "No alerts yet"

**Actions:**
- Tap alert → Alert Detail Screen
- Swipe → Delete confirmation
- Floating Action Button → Test Alert

---

##### 5.3 Contacts Tab
**File:** `lib/screens/home/contacts_tab.dart`

**Features:**
- **Contact List:**
  - Name with avatar
  - Phone number
  - Relationship badge
  - Emergency contact star
  - Call & Message buttons

- **Emergency Contacts Section:**
  - Separated at top
  - Quick access

- **Actions:**
  - Tap → Edit contact
  - Call button → Phone dialer
  - Message button → Chat screen
  - FAB → Add new contact

---

##### 5.4 Messages Tab
**File:** `lib/screens/home/messages_tab_new.dart`

**Features:**
- **Conversation List:**
  - Contact avatar
  - Last message preview
  - Timestamp (timeago format)
  - Unread count badge
  - Emergency contact indicator

- **Empty State:** "No contacts to message"

**Actions:**
- Tap conversation → Chat Screen

---

##### 5.5 Settings Tab
**File:** `lib/screens/home/settings_tab.dart`

**Sections:**

**Profile:**
- User name
- Email
- Phone number
- Edit profile (placeholder)

**Appearance:**
- Dark Mode toggle
- Theme selector (Light/Dark/System)

**Language:**
- Language selector (English/Arabic)

**Camera Integration:**
- Connection status
- Integration guide
- Connect button

**About:**
- App version (1.0.0)
- "Developed by ZYAD" credit
- GitHub link (placeholder)

**Actions:**
- Logout button

---

#### 6. **Alert Detail Screen**
**File:** `lib/screens/home/alert_detail_screen.dart`

**Display:**
- Alert type with icon
- Title and message
- Location (if available)
- Timestamp
- Confidence score (AI alerts)
- Current status

**Actions:**
- Acknowledge (if pending)
- Resolve (if active/acknowledged)
- Mark as False Alarm
- Delete alert

**Status Timeline:**
- Created → Acknowledged → Resolved
- Visual progress indicator

---

#### 7. **Add/Edit Contact Screen**
**File:** `lib/screens/home/add_contact_screen.dart`

**Fields:**
- Name (required)
- Phone Number (required, validated)
- Email (optional)
- Relationship (dropdown)
- Emergency Contact (toggle)

**Validation:**
- Phone format check
- Unique phone number
- Required fields

**Actions:**
- Save
- Cancel

---

#### 8. **Chat Screen**
**File:** `lib/screens/chat/chat_screen.dart`

**Layout:**
- **Header:**
  - Contact avatar
  - Contact name
  - Relationship
  - Call button
  - Video call button (placeholder)

- **Message List:**
  - Sender bubbles (blue, right-aligned)
  - Receiver bubbles (grey, left-aligned)
  - Timestamps
  - Read receipts (✓/✓✓)
  - Date headers (Today, Yesterday, etc.)

- **Input:**
  - Text field
  - Send button
  - Auto-focus

**Features:**
- Auto-scroll to bottom
- Mark as read on view
- Send on Enter key
- Empty state

---

#### 9. **Camera Integration Screen**
**File:** `lib/screens/camera_integration_screen.dart`

**Content:**
- Connection status indicator
- Integration guide steps
- API endpoint documentation
- Backend requirements
- Setup instructions

**Information:**
- How to connect AI backend
- Required Python packages
- API endpoints structure
- WebSocket connection details

---

## 🌐 Localization

### Implementation
**File:** `lib/utils/app_localization.dart`  
**Pattern:** Map-based translations  
**Languages:** 2 (English, Arabic)

### Translation Count: 100+ keys

**Categories:**
- Common (login, register, save, cancel, etc.)
- Dashboard (statistics, recent alerts)
- Alerts (types, statuses, actions)
- Contacts (relationships, actions)
- Messages (chat, typing, read)
- Settings (profile, theme, language)
- Errors (validation, network)

### RTL Support
**Arabic Layout:**
- Text direction: Right-to-left
- Icon mirroring
- Navigation drawer from right
- Layout reversal
- Number localization

**Implementation:**
```dart
MaterialApp(
  locale: languageProvider.locale,
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', ''),
    Locale('ar', ''),
  ],
)
```

---

## 📦 Dependencies (pubspec.yaml)

### Core Flutter
- `flutter: sdk: flutter`
- `flutter_localizations: sdk: flutter`

### State Management
- `provider: ^6.1.1` - State management solution

### Database & Storage
- `sqflite: ^2.3.0` - Local SQLite database
- `path_provider: ^2.1.1` - File system paths
- `shared_preferences: ^2.2.2` - Key-value storage

### Notifications
- `flutter_local_notifications: ^17.2.4` - Local push notifications
- `timezone: ^0.9.2` - Timezone handling

### UI & Theming
- `google_fonts: ^6.1.0` - Custom fonts (Poppins)
- `flutter_svg: ^2.0.9` - SVG support
- `lottie: ^3.0.0` - Animations

### Utilities
- `intl: 0.20.2` - Internationalization
- `timeago: ^3.6.0` - Relative time formatting
- `url_launcher: ^6.2.2` - Phone calls, URLs
- `permission_handler: ^11.1.0` - Runtime permissions

### Development
- `flutter_lints: ^3.0.1` - Linting rules

### Platform-Specific
**Android:**
- Kotlin: 1.8.0
- Gradle: 8.0
- minSdkVersion: Set by Flutter
- targetSdkVersion: Set by Flutter
- Core library desugaring: Enabled

**iOS:**
- Deployment target: 11.0
- Swift: 5.0

---

## 🎨 UI/UX Design Principles

### Design System

**Color Palette:**
- Primary: `Color(0xFF2196F3)` - Blue
- Secondary: Custom from ColorScheme
- Error: Red tones
- Success: Green tones
- Warning: Orange tones

**Typography:**
- Font Family: Poppins (Google Fonts)
- Sizes: 12-32px
- Weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

**Spacing:**
- Base unit: 8px
- Common values: 8, 12, 16, 24, 32

**Border Radius:**
- Cards: 12px
- Buttons: 8-24px
- Input fields: 8px
- Dialogs: 16px

**Icons:**
- Material Icons
- Size: 24dp (default)
- Contextual colors

### Component Standards

**Cards:**
- Elevated or filled
- Shadow elevation: 2-4
- Padding: 16px
- Margin: 12-16px

**Buttons:**
- Primary: Filled
- Secondary: Outlined
- Text: Plain text
- Height: 48-56px

**Input Fields:**
- Outlined style
- Label: Floating
- Error text: Below field
- Helper text: Optional

**Lists:**
- Item height: 72-88px
- Dividers: Optional
- Leading: Avatar or icon
- Trailing: Actions or chevron

---

## 🔐 Security Considerations

### Current Implementation (Development):
⚠️ **For production, implement:**

1. **Password Storage:**
   - Current: Plain text in SQLite
   - Required: bcrypt/argon2 hashing

2. **Authentication:**
   - Current: Local database
   - Required: JWT tokens, OAuth, Firebase Auth

3. **Data Encryption:**
   - Current: None
   - Required: SQLite encryption (sqlcipher)

4. **Network Security:**
   - Required: HTTPS/TLS
   - Required: Certificate pinning
   - Required: API key encryption

5. **Privacy:**
   - Required: Data anonymization
   - Required: GDPR compliance
   - Required: Privacy policy

### Permissions Required:

**Android:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

**iOS:**
```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Access camera for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>Access microphone for calls</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access photos to share images</string>
```

---

## 🚀 User Flows (For UML Sequence Diagrams)

### 1. User Registration Flow
```
User → RegisterScreen
  ├─► Enter details (name, email, phone, password)
  ├─► Validate form
  ├─► AuthProvider.register()
  │   ├─► Check email uniqueness (DatabaseService)
  │   ├─► Create UserModel
  │   └─► Insert user (DatabaseService)
  ├─► Save user ID (SharedPreferences)
  └─► Navigate to HomeScreen
```

### 2. User Login Flow
```
User → LoginScreen
  ├─► Enter credentials (email, password)
  ├─► Validate form
  ├─► AuthProvider.login()
  │   ├─► Query user by email (DatabaseService)
  │   ├─► Verify password
  │   └─► Load user into state
  ├─► Save user ID (SharedPreferences)
  └─► Navigate to HomeScreen
```

### 3. Alert Creation Flow (Test Alert)
```
User → DashboardTab/AlertsTab
  ├─► Tap "Test Alert" button
  ├─► AlertProvider.createAlert()
  │   ├─► Create AlertModel (type: test, status: pending)
  │   ├─► Insert alert (DatabaseService)
  │   ├─► Show local notification (NotificationService)
  │   └─► Update UI (notifyListeners)
  └─► Display success message
```

### 4. Alert Status Update Flow
```
User → AlertsTab
  ├─► Tap alert card
  ├─► Navigate to AlertDetailScreen
  ├─► Tap "Acknowledge" or "Resolve" button
  ├─► AlertProvider.updateAlertStatus()
  │   ├─► Update AlertModel with new status
  │   ├─► Update timestamp (acknowledgedAt/resolvedAt)
  │   ├─► Update database (DatabaseService)
  │   └─► Refresh UI (notifyListeners)
  └─► Show updated status
```

### 5. Contact Management Flow
```
User → ContactsTab
  ├─► Tap FAB (+)
  ├─► Navigate to AddContactScreen
  ├─► Enter contact details
  ├─► ContactProvider.addContact()
  │   ├─► Create ContactModel
  │   ├─► Validate phone number
  │   ├─► Insert contact (DatabaseService)
  │   └─► Refresh contacts list
  └─► Navigate back to ContactsTab
```

### 6. Messaging Flow
```
User → MessagesTab
  ├─► Tap contact card
  ├─► Navigate to ChatScreen
  ├─► ChatProvider.loadMessages()
  │   └─► Query messages (DatabaseService)
  ├─► Display conversation
  ├─► User types message
  ├─► Tap send button
  ├─► ChatProvider.sendMessage()
  │   ├─► Create MessageModel
  │   ├─► Insert message (DatabaseService)
  │   ├─► Reload messages
  │   └─► Scroll to bottom
  └─► Display sent message
```

### 7. Phone Call Flow
```
User → ChatScreen or ContactsTab
  ├─► Tap call button (📞)
  ├─► Extract phone number from ContactModel
  ├─► Create tel: URI
  ├─► Launch URL (url_launcher)
  └─► Open device phone dialer
```

### 8. Theme Toggle Flow
```
User → SettingsTab
  ├─► Tap Dark Mode toggle
  ├─► ThemeProvider.toggleTheme()
  │   ├─► Switch ThemeMode (light ↔ dark)
  │   ├─► Save to SharedPreferences
  │   └─► Notify listeners
  └─► Rebuild MaterialApp with new theme
```

### 9. Language Switch Flow
```
User → SettingsTab
  ├─► Select language (English/Arabic)
  ├─► LanguageProvider.setLanguage()
  │   ├─► Update Locale
  │   ├─► Set RTL flag
  │   ├─► Save to SharedPreferences
  │   └─► Notify listeners
  └─► Rebuild app with new locale
```

---

## 📊 Statistics & Metrics

### Code Metrics (Approximate)
- **Total Dart Files:** 30+
- **Lines of Code:** ~4,500
- **Models:** 4
- **Providers:** 6
- **Services:** 2
- **Screens:** 15
- **Reusable Widgets:** 10+

### Feature Coverage
- ✅ **Authentication:** 100%
- ✅ **Alert Management:** 100%
- ✅ **Contact Management:** 100%
- ✅ **Messaging:** 100%
- ✅ **Theming:** 100%
- ✅ **Localization:** 100%
- ⏳ **AI Integration:** 0% (backend not implemented)
- ⏳ **Video Calls:** 0% (optional future feature)

---

## 🔌 Future Integration (AI Backend)

### Backend Requirements

**Technology Stack:**
- Python 3.8+
- OpenCV for video processing
- MediaPipe for pose estimation
- TensorFlow/PyTorch for ML models
- Flask/FastAPI for REST API
- WebSocket for real-time communication

### API Endpoints (Proposed)

```
POST /api/auth/login
POST /api/auth/register
GET  /api/alerts
POST /api/alerts
PUT  /api/alerts/{id}
DELETE /api/alerts/{id}
GET  /api/contacts
POST /api/contacts
PUT  /api/contacts/{id}
DELETE /api/contacts/{id}
WebSocket /ws/alerts (real-time alerts)
WebSocket /ws/video (video stream)
```

### Integration Points

**1. Alert Reception:**
```dart
// Receive real-time alerts from AI backend
WebSocketChannel channel = WebSocketChannel.connect(
  Uri.parse('ws://server:8080/ws/alerts'),
);

channel.stream.listen((data) {
  final alertData = jsonDecode(data);
  alertProvider.createAlert(AlertModel.fromJson(alertData));
});
```

**2. User Sync:**
```dart
// Sync local users with backend
Future<void> syncUser(UserModel user) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/users/sync'),
    body: jsonEncode(user.toMap()),
  );
}
```

**3. Video Stream (Optional):**
```dart
// Display live camera feed
NetworkImage('$baseUrl/api/video/stream/${userId}')
```

---

## 🧪 Testing Strategy (For Implementation)

### Unit Tests
- **Models:** Serialization/deserialization
- **Providers:** State management logic
- **Services:** Database operations
- **Utilities:** Validation functions

### Widget Tests
- **Screens:** UI rendering
- **Forms:** Validation behavior
- **Buttons:** Tap actions
- **Navigation:** Route transitions

### Integration Tests
- **User flows:** End-to-end scenarios
- **Database:** CRUD operations
- **Notifications:** Trigger and display

### Test Coverage Goals
- Unit tests: 80%+
- Widget tests: 60%+
- Integration tests: Key flows

---

## 📈 Performance Considerations

### Optimization Strategies

**1. Database:**
- Indexed queries on userId and timestamp
- Lazy loading for large lists
- Pagination for alerts and messages

**2. Images:**
- Cached network images
- Compressed avatars
- Lazy loading in lists

**3. State Management:**
- Selective widget rebuilds (Consumer vs Provider.of)
- Computed properties cached
- Minimal notifyListeners calls

**4. Navigation:**
- Route caching
- Hero animations
- Page transitions

---

## 🎯 Development Best Practices Used

1. **Clean Architecture:** Separation of concerns
2. **SOLID Principles:** Single responsibility
3. **DRY (Don't Repeat Yourself):** Reusable widgets
4. **Code Organization:** Feature-based structure
5. **Error Handling:** Try-catch blocks
6. **Null Safety:** Full null-safe code
7. **Async/Await:** Proper async handling
8. **Immutable Models:** copyWith pattern
9. **Provider Pattern:** Reactive state management
10. **Material Design 3:** Modern UI guidelines

---

## 📚 Documentation & Resources

### Internal Documentation
- `README.md` - Project overview and setup
- `CALL_FEATURES_GUIDE.md` - Call feature implementation guide
- `PROJECT_TECHNICAL_REPORT.md` - This document

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [SQLite in Flutter](https://pub.dev/packages/sqflite)
- [Material Design 3](https://m3.material.io/)

---

## 🎓 Academic Context

### Graduation Project Components

**1. Mobile Application (This):**
- User interface
- Alert management
- Contact management
- Local data storage

**2. AI Backend (Separate):**
- Fall detection
- Pose estimation
- Medical emergency recognition
- Real-time video processing

**3. Integration Layer (To Be Built):**
- REST API
- WebSocket communication
- Real-time synchronization

### Diagrams Needed for Project Report

**1. System Architecture Diagram**
- High-level system overview
- Component interactions
- Technology stack

**2. Class Diagram**
- All models with attributes
- Providers with methods
- Services and utilities
- Relationships (inheritance, composition)

**3. Sequence Diagrams**
- User registration
- User login
- Alert creation and notification
- Message sending
- Contact management

**4. Use Case Diagram**
- Actors (User, System, AI Backend)
- Use cases (Login, View Alerts, Send Message, etc.)
- Relationships

**5. Entity-Relationship Diagram**
- Database schema
- Table relationships
- Cardinality

**6. State Diagram**
- Alert status lifecycle
- User authentication states

**7. Activity Diagram**
- User flows
- Decision points
- Parallel processes

**8. Deployment Diagram**
- Mobile app
- Backend server
- Database
- Camera system

---

## 🔧 Build & Deployment

### Build Commands

```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android)
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Check dependencies
flutter pub outdated
```

### Release Configuration

**Android (android/app/build.gradle.kts):**
```kotlin
android {
    defaultConfig {
        applicationId = "com.zyad.grad_app"
        versionCode = 1
        versionName = "1.0.0"
    }
}
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

---

## ✅ Current Status Summary

### Completed Features
✅ User authentication (login/register/logout)  
✅ Alert management (create/view/update/delete)  
✅ Contact management (add/edit/delete/call)  
✅ Messaging system (send/receive/read receipts)  
✅ Dashboard with statistics  
✅ Dark/Light theme  
✅ English/Arabic localization  
✅ Local notifications  
✅ Test alert functionality  
✅ Phone call integration  
✅ SQLite database  
✅ Session persistence  

### Pending Features
⏳ AI backend integration  
⏳ Real-time alert reception  
⏳ Video call (optional)  
⏳ Cloud synchronization  
⏳ User profile editing  
⏳ Password recovery  
⏳ Push notifications (Firebase)  
⏳ Image attachments in messages  
⏳ Voice messages  
⏳ Camera live feed  

### Known Limitations
- No server backend (local-only)
- No AI detection (placeholder UI)
- No real-time sync between devices
- Simple authentication (no OAuth)
- No encrypted storage (production requirement)

---

## 👥 Team Information

**Developer:** ZYAD  
**Project Type:** Graduation Project  
**Academic Year:** 2025  
**Institution:** [Your University]  
**Department:** Computer Science  

**Credits:**
- Developed by ZYAD (Mobile App)
- AI Backend: [To be assigned to team member]
- Integration: [To be collaborative]

---

## 📞 Contact & Support

**For Questions:**
- Mobile App: Contact ZYAD
- AI Implementation: Refer to Python backend documentation
- Integration: Coordinate with team

**Repository:** [To be created]  
**Issue Tracker:** [To be set up]  
**Documentation:** See README.md and guides in project root

---

## 🏁 Conclusion

This mobile application serves as a complete UI/UX implementation for the Smart AI Camera graduation project. It provides all necessary screens, features, and functionality to interact with a future AI-powered medical emergency detection system.

**Key Strengths:**
- ✅ Clean, maintainable code architecture
- ✅ Complete feature set for demo purposes
- ✅ Professional UI/UX with Material Design 3
- ✅ Bilingual support with RTL layout
- ✅ Local data persistence
- ✅ Modular design for easy backend integration

**Next Steps:**
1. Implement Python AI backend with OpenCV + MediaPipe
2. Create REST API for mobile app communication
3. Implement WebSocket for real-time alerts
4. Test integration between mobile app and backend
5. Deploy system for graduation project demo

**Project Timeline:**
- ✅ Phase 1: Mobile App UI/UX (Complete)
- ⏳ Phase 2: AI Backend Development (In Progress)
- ⏳ Phase 3: Integration & Testing (Pending)
- ⏳ Phase 4: Documentation & Presentation (Pending)

---

**End of Technical Report**  
**Document Version:** 1.0  
**Last Updated:** December 14, 2025  
**Prepared by:** ZYAD  
**For:** Graduation Project Team Members
