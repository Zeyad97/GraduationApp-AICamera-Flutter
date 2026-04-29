# Smart AI Camera - Mobile App

A Flutter mobile application for the Smart AI Camera Medical Emergency Detection System. This app serves as the mobile companion to receive real-time alerts from an AI-powered camera system that detects falls, emergencies, and abnormal activities.

**Developed by ZYAD** | Graduation Project 2025

## 📱 Features

### ✅ Implemented Features

#### Authentication & Onboarding
- Beautiful splash screen with animations
- Multi-page onboarding flow
- User registration and login
- Profile management
- Session persistence

#### User Interface
- Modern Material Design 3 UI
- Dark and Light theme support
- Bilingual support (English & Arabic)
- RTL support for Arabic
- Smooth animations and transitions
- Custom Google Fonts (Poppins)

#### Emergency Alerts System
- Real-time alert notifications
- Test alert functionality
- Alert history and tracking
- Alert status management (Pending, Active, Acknowledged, Resolved, False Alarm)
- Alert types: Fall, Emergency Gesture, Immobility, Abnormal Activity, Medical Emergency
- Detailed alert view with timestamps
- Push notifications for emergency situations

#### Contacts Management
- Add/Edit/Delete emergency contacts
- Mark contacts as emergency responders
- Contact relationships (Family, Friend, Caregiver, Doctor, Nurse)
- Call functionality via phone integration
- Emergency contact notification system

#### Dashboard
- Welcome card with user info
- Today's alerts counter
- Emergency contacts counter
- Recent alerts feed
- Quick test alert button
- Refresh functionality

#### Settings
- Theme toggle (Light/Dark/System)
- Language switcher (English/Arabic)
- Profile display
- About section with version info
- Logout functionality

#### Camera Integration Guide
- Detailed setup instructions
- API configuration interface
- Technical documentation
- Connection status display
- Step-by-step integration guide

## 🏗️ Architecture

### State Management
- **Provider** for state management
- Separation of concerns with multiple providers:
  - `AuthProvider` - Authentication and user session
  - `ThemeProvider` - Theme management
  - `LanguageProvider` - Localization
  - `AlertProvider` - Alert management
  - `ContactProvider` - Contact management

### Database
- **SQLite** for local data persistence
- Tables: Users, Alerts, Contacts, Messages
- Efficient CRUD operations
- Relational data structure

### Services
- `DatabaseService` - SQLite database operations
- `NotificationService` - Local push notifications

### Localization
- Custom `AppLocalizations` implementation
- Support for English and Arabic
- 100+ translated strings
- Easy to extend for more languages

## 🔮 Future Integration (Camera AI System)

This mobile app is designed to connect with a Python-based AI detection server:

### AI Backend Components (To be integrated)
```
Python Server (Flask/FastAPI)
├── OpenCV - Video capture & processing
├── MediaPipe Pose - Skeleton detection (33 keypoints)
├── TensorFlow - Gesture recognition (MLP/LSTM)
├── Scikit-learn - Anomaly detection (Isolation Forest)
└── REST API / WebSocket - Communication with mobile app
```

### How Integration Will Work

1. **Server Setup**
   - Install Python AI detection server on a computer
   - Configure with camera feed (Webcam, USB, or RTSP stream)
   - Set detection thresholds and preferences

2. **API Connection**
   - Enter server URL and API key in the app
   - Establish WebSocket connection for real-time alerts
   - REST API for alert history and configuration

3. **Real-Time Detection**
   - AI server processes video frames
   - Detects: Falls, Emergency Gestures, Immobility, Abnormal Activity
   - Sends alerts to mobile app via API

4. **Alert Flow**
   ```
   Camera → AI Server → Detection → Alert Generation → 
   Mobile App → Push Notification → Emergency Contacts
   ```

### API Endpoints (To be implemented in backend)

```
POST /api/alert/send          - Send alert from AI server to app
GET  /api/alerts              - Get alert history
PUT  /api/alert/:id/status    - Update alert status
POST /api/camera/connect      - Connect camera to system
GET  /api/camera/status       - Get camera status
POST /api/config/thresholds   - Update detection thresholds
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd grad_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### First Time Setup

1. Launch the app
2. Complete onboarding
3. Register a new account
4. Add emergency contacts
5. Test the alert system using "Test Alert" button
6. Explore settings and customize theme/language

## 📦 Dependencies

```yaml
# UI & Design
google_fonts: ^6.1.0
flutter_svg: ^2.0.9
lottie: ^3.0.0

# State Management
provider: ^6.1.1

# Storage
shared_preferences: ^2.2.2
sqflite: ^2.3.0
path_provider: ^2.1.1

# Notifications
flutter_local_notifications: ^16.3.0

# Localization
intl: ^0.19.0

# Communications
url_launcher: ^6.2.2
permission_handler: ^11.1.0

# Utils
uuid: ^4.2.2
timeago: ^3.6.0
```

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point
├── models/                       # Data models
│   ├── user_model.dart
│   ├── alert_model.dart
│   ├── contact_model.dart
│   └── message_model.dart
├── providers/                    # State management
│   ├── auth_provider.dart
│   ├── theme_provider.dart
│   ├── language_provider.dart
│   ├── alert_provider.dart
│   └── contact_provider.dart
├── services/                     # Business logic
│   ├── database_service.dart
│   └── notification_service.dart
├── screens/                      # UI screens
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
│   │   └── settings_tab.dart
│   ├── alert/
│   │   └── alert_detail_screen.dart
│   ├── contact/
│   │   └── add_contact_screen.dart
│   └── settings/
│       └── camera_integration_screen.dart
└── utils/
    └── app_localization.dart      # Localization helper
```

## 🎨 UI/UX Features

- **Material Design 3** with custom theme
- **Smooth animations** throughout the app
- **Responsive design** for different screen sizes
- **Intuitive navigation** with bottom navigation bar
- **Pull-to-refresh** on data lists
- **Swipe gestures** where applicable
- **Loading indicators** for async operations
- **Error handling** with user-friendly messages
- **Empty states** with helpful guidance

## 🔒 Security & Privacy

- Passwords stored locally (in production, should be hashed)
- All data processing done locally
- No data sent to external servers without user consent
- Secure storage using SQLite
- Permission-based access to phone features

## 📱 Supported Platforms

- ✅ Android (Primary target)
- ✅ iOS (Compatible)
- ⚠️ Web (Partial support, notifications limited)
- ⚠️ Desktop (Partial support)

## 🧪 Testing

To test the alert system:

1. Login to the app
2. Add emergency contacts
3. Navigate to Dashboard
4. Tap "Test Alert" button
5. Confirm the test
6. Check notifications and alert history

## 🎓 Academic Context

This app is part of a graduation project for:
- **Institution**: College of Computing and Information Technology, AASTMT
- **Project**: Smart AI Camera for Medical Emergency Detection Using Gestures and Abnormal Activity Recognition
- **Year**: 2025
- **Location**: Alexandria

### Project Objectives
- Develop a vision-based monitoring system
- Implement pose estimation for emergency detection
- Recognize emergency gestures
- Detect falls and abnormal activities
- Provide real-time alerts
- Operate on standard hardware

## 🛣️ Roadmap

### Phase 1: Mobile App (✅ Completed)
- [x] Authentication system
- [x] Alert management
- [x] Contact management
- [x] Dark/Light theme
- [x] Localization
- [x] Notifications
- [x] UI/UX design

### Phase 2: AI Backend (🔄 In Progress)
- [ ] OpenCV video capture
- [ ] MediaPipe Pose integration
- [ ] Gesture recognition models
- [ ] Fall detection algorithm
- [ ] Abnormal activity detection
- [ ] REST API development

### Phase 3: Integration (📅 Planned)
- [ ] WebSocket real-time connection
- [ ] API authentication
- [ ] Video streaming (optional)
- [ ] Enhanced notifications
- [ ] Camera management UI
- [ ] Multi-camera support

### Phase 4: Deployment (📅 Future)
- [ ] Production server setup
- [ ] Cloud deployment
- [ ] Performance optimization
- [ ] Security audit
- [ ] User testing
- [ ] Documentation finalization

## 👨‍💻 Developer

**ZYAD**
- Graduation Project 2025
- College of Computing and Information Technology, AASTMT
- Alexandria, Egypt

## 📄 License

This project is developed for academic purposes as part of a graduation project.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI guidelines
- Open source community for packages and inspiration
- Project supervisor and academic institution

---

**Note**: This app is currently in development as part of an academic project. The AI detection backend is being developed separately and will be integrated in future updates.

For questions or support, please contact the development team.
