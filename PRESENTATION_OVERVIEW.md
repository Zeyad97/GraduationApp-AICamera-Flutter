# EmergiCam — Project Overview
## For Presentation, Stakeholders & Everyone to Understand

**Developer:** ZYAD | **Project:** Graduation Project 2025 | **AASTMT,** Alexandria

---

## What Is EmergiCam? (The Big Picture)

Imagine an elderly grandparent living alone. If they fall or have a medical emergency, every second counts. EmergiCam is a **smart monitoring system** that uses an AI-powered camera to watch over them 24/7. If something goes wrong — a fall, no movement for too long, or a waving hand signaling for help — the system instantly sends an alert to the caregiver's phone.

The whole system has two parts:
1. **The AI Camera System** (a Python program running on a computer with a camera) — this watches and detects emergencies
2. **The Mobile App** (this project) — this receives alerts and lets caregivers respond

The mobile app is what you're looking at here. It's the part that caregivers see and use every day.

---

## Who Is This For?

| Person | How They Use It |
|--------|----------------|
| **Elderly person** | Is being monitored by the camera (no phone needed) |
| **Family member** | Gets alerts on their phone when something happens |
| **Doctor / Nurse** | Can be added as an emergency contact |
| **Professional caregiver** | Monitors multiple people from the app |

---

## What Can the App Actually Do? (Plain English)

### 1. Sign Up & Log In
- Create an account with email/password or sign in with Google
- You stay logged in even if you close the app
- First time users get a quick 3-page introduction

### 2. Main Dashboard (Home Screen)
When you open the app, you see a dashboard with:
- Your name and a welcome greeting
- How many alerts happened today
- How many emergency contacts you have
- The most recent alerts (tap to see details)

### 3. Emergency Alerts
When the AI camera detects something:
- A notification pops up on your phone immediately
- You see what type of emergency (fall, no movement, waving for help, etc.)
- You can **Acknowledge** (say "I see it"), **Resolve** (say "everything is fine now"), or mark as **False Alarm**
- Every alert has a time stamp so you know exactly when it happened

### 4. Contacts
- Add the people who should be notified during emergencies (family, doctor, neighbor)
- Mark someone as an "emergency contact" — they get special priority
- Tap a contact to call them directly from the app
- Categorize them as family, friend, doctor, nurse, caregiver, or other

### 5. Messaging (Chat)
- Talk to other people using the app in real time
- See if your message was delivered and read (check marks)
- Messages are organized by contact
- Works smoothly with automatic scrolling to new messages

### 6. Settings
- Switch between **Light mode** and **Dark mode**
- Change language between **English** and **Arabic** (full support for right-to-left)
- Set up the camera connection (enter server address and API key)
- Log out when done

---

## How It All Connects (How It Actually Works)

### The Technical Flow (For the Tech-Minded)

```
AI Camera (Python) → Detects emergency → Sends data to Firebase Firestore
                                                    ↓
Mobile App (Flutter) ← Real-time listener ← reads new alert
                                                    ↓
                                          Push notification on phone
                                                    ↓
                                          Caregiver opens app → takes action (acknowledge/resolve)
```

### The Simple Version (For Everyone Else)

```
Camera watches → Sees a fall → Cloud server gets the alert → Your phone rings → You check it
```

The mobile app constantly listens for new alerts in the cloud (Firebase). The moment the AI camera writes a new alert, the app picks it up instantly and notifies you. You don't need to refresh or check manually — it just happens.

---

## What's Under the Hood? (The Technical Part)

### The Mobile App (Flutter)
| Part | What It Does |
|------|-------------|
| **Flutter/Dart** | The programming language and framework — runs on both Android and iPhone from the same code |
| **Provider** | A system that manages app state — keeps everything organized so screens stay in sync |
| **Firebase Auth** | Handles login and registration securely (Google and email) |
| **Firestore** | A real-time cloud database — stores alerts, contacts, messages, and user data |
| **SQLite** | A local database on the phone — works when there's no internet connection |
| **Notifications** | Sends pop-up alerts to your phone when emergencies happen |

### The AI Camera System (Separate — Future Integration)
| Part | What It Does |
|------|-------------|
| **OpenCV** | Reads video from the camera |
| **MediaPipe** | Tracks body position (33 points on the skeleton) |
| **TensorFlow** | Recognizes gestures and movements |
| **Python Server** | Runs everything, sends alerts to the cloud |

---

## App Screens (What You Actually See)

| Screen | What It Does |
|--------|-------------|
| **Splash Screen** | App logo, auto-navigates after 3 seconds |
| **Onboarding** | 3 pages explaining the app (first time only) |
| **Login** | Sign in with email or Google |
| **Register** | Create a new account |
| **Dashboard** | Main screen — stats, recent alerts, welcome |
| **Alerts** | Full list of all alerts |
| **Alert Detail** | Tap an alert to see details and take action |
| **Contacts** | Your saved contacts with call and emergency toggle |
| **Add Contact** | Add or edit a contact's info |
| **Messages** | List of contacts to chat with |
| **Chat** | Real-time messaging with another person |
| **Settings** | Theme, language, camera setup, logout |

---

## What's Done and What's Next

| Feature | Status | Notes |
|---------|--------|-------|
| Login & Registration | ✅ Done | Email/password + Google |
| Dashboard | ✅ Done | Shows stats and recent alerts |
| Alerts System | ✅ Done | Real-time notifications |
| Contacts | ✅ Done | Full management |
| Chat / Messaging | ✅ Done | Real-time with read receipts |
| Camera Setup Screen | 🟡 UI Ready | Form is built, server connection pending |
| AI Camera Backend | 🔴 Future | Python server being developed separately |
| Voice / Video Calls | 🔴 Future | Buttons are there, not connected yet |
| Tests | 🟡 Minimal | Only basic test written |

---

## Firebase Cloud Structure (For Developers)

```
emergicam12 (Firebase Project)
├── users/{userId}                      → User profiles
├── users/{userId}/contacts/{contactId} → Each user's contacts
├── alerts (root collection)            → AI camera writes alerts here
├── users/{userId}/alerts/{alertId}     → Per-user alert copy (backup)
└── conversations/{convId}/messages/    → Chat messages between users
```

---

## The Bottom Line (Why This Matters)

Every year, millions of elderly people suffer from falls and medical emergencies at home alone. Many don't get help in time. EmergiCam aims to solve this by combining **AI-powered computer vision** with a **simple mobile app** that caregivers can use daily — no fancy hardware needed, just a regular camera and a smartphone.

It's affordable, works on standard equipment, and keeps family and doctors informed the moment something goes wrong.

---

*Project developed by ZYAD | AASTMT College of Computing and Information Technology | Graduation Project 2025*
