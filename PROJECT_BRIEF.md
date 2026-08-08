# EmergencySOS-iOS - Project Brief

## Overview
Build an iOS emergency SOS app called **EmergencySOS-iOS** using **Swift, SwiftUI, and Firebase**, following **MVVM architecture** with a Repository pattern.

## Architecture Flow
```
SwiftUI View → ViewModel → Repository → Service → Firebase / Apple Framework
```

## Tech Stack
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Reactive**: Combine, async/await
- **Apple Frameworks**: CoreLocation, MapKit, UserNotifications, BackgroundTasks, AVFoundation (future use)
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Messaging)
- **Auth**: Email/password only (No Face ID/Touch ID)

## Project Structure
```
EmergencySOS-iOS/
├── App
├── Assets
├── Documentation
├── Models
├── Repositories
├── Resources
├── Services
├── Utilities
├── ViewModels
├── Views/
│   ├── Authentication/
│   ├── Home/
│   ├── Contacts/
│   ├── Profile/
│   ├── SOS/
│   ├── Settings/
│   └── Components/
├── Design/
├── README.md
├── CHANGELOG.md
├── LICENSE
└── .gitignore
```

## Core Features

### 1. Authentication
- Email register/login/logout
- Forgot password
- Persistent session
- Via Firebase Auth

### 2. User Profile
- Name, email, phone, profile picture
- Emergency/medical info (blood group, medical conditions)
- Edit profile

### 3. Emergency Contacts
- Add/edit/delete/view contacts
- Mark favorites
- Fields: name, phone, relationship

### 4. Emergency SOS (Main Feature)
- Press SOS → start event
- Get current location
- Share with trusted contacts
- Record event
- Continuous location updates
- User can end SOS
- Design against false triggers/accidental activation

### 5. Real-Time Location
- CoreLocation + MapKit
- Latitude/longitude with timestamps
- Map display
- Live sharing during SOS

### 6. Notifications
- Firebase Cloud Messaging
- Alert trusted contacts on SOS activation

### 7. Settings
- Notification preferences
- Privacy settings
- Account management
- Logout

## Data Models

### User
```swift
struct User {
    let uid: String
    let name: String
    let email: String
    let phone: String
    let profileImage: String?
    let bloodGroup: String?
    let medicalInfo: String?
    let createdAt: Date
}
```

### EmergencyContact
```swift
struct EmergencyContact {
    let contactId: String
    let ownerId: String
    let name: String
    let phone: String
    let relationship: String
    let isFavorite: Bool
}
```

### SOSAlert
```swift
struct SOSAlert {
    let alertId: String
    let userId: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let status: SOSStatus
}

enum SOSStatus {
    case active
    case ended
    case cancelled
}
```

### LiveLocation
```swift
struct LiveLocation {
    let userId: String
    let latitude: Double
    let longitude: Double
    let speed: Double?
    let timestamp: Date
}
```

## Firestore Collections
- `users` - User profiles
- `emergencyContacts` - User's emergency contacts
- `sosAlerts` - SOS alert history
- `liveLocations` - Real-time location during active SOS

**Security**: Each collection secured so users only access their own data via Firebase Security Rules.

## Dedicated Services

### LocationService
- Permission handling
- Get current location
- Monitor location updates
- Stop location updates
- Feed data to SOS system
- **Never put CoreLocation directly in views**

### NotificationService
- Permission handling
- Device token management
- Emergency notification flow
- Configuration

## SOS Flow
```
Home → Press SOS → Confirm/safety interaction → Location permission check →
Get current location → Create SOS Alert → Notify trusted contacts →
Start live location updates → Contacts receive location → User ends emergency →
Stop sharing → Save SOS history
```

## App Flow
```
Launch → Splash → Auth check → (Logged In → Home) / (Logged Out → Login → Register → Forgot Password)
Home → SOS / Contacts / Profile / Settings / SOS History
```

## Security Requirements
- Auth required for all access
- Users restricted to their own profile/contacts/SOS records/location data
- Firebase Security Rules enforced
- No credentials committed to GitHub
- Minimal data collection

## UI/UX Direction
- Modern, minimal, safety-focused
- Easy to use under stress
- Large accessible SOS button
- Consistent typography/colors/icons
- Apple HIG-inspired

### Screens
- Splash
- Login
- Register
- Forgot Password
- Home
- Contacts
- Profile

## Documentation Status
| Document | Status |
|----------|--------|
| AppFlow.md | ✅ Done |
| Architecture.md | ✅ Done |
| Database.md | ✅ Done |
| UserStories.md | ✅ Done |
| Security.md | ⏳ Planned |
| ProjectStructure.md | ⏳ Planned |
| API.md | ⏳ Planned |
| Testing.md | ⏳ Planned |

## Testing Plan
- **Unit Tests**: Auth, ViewModels, SOS state, location, repositories
- **UI Tests**: Login, registration, navigation, SOS, contacts
- **Integration Tests**: Firebase Auth, Firestore, notifications, location
- **Real-Device Testing**: GPS, background location, notifications (simulator insufficient)

## Development Context
- **Current**: Windows/VS Code for docs, GitHub, architecture, planning
- **Pending**: Mac for Xcode, SwiftUI builds, Firebase config, device testing
- **Git Workflow**: edit → test → `git status` → `git add .` → `git commit -m "message"` → `git push origin main` → confirm clean tree

## Roadmap

| Phase | Status | Description |
|-------|--------|-------------|
| 1. Foundation | ✅ | GitHub, README, license, folders, design system |
| 2. Documentation | 🔄 | AppFlow ✅, Database ✅, MVVM ✅, UserStories ✅ — Security/ProjectStructure/API/Testing pending |
| 3. Xcode Setup | ⏳ | Once Mac available |
| 4. Core App | ⏳ | Splash → Auth → Home → Contacts → Profile |
| 5. Emergency System | ⏳ | SOS → Location → Firebase → Notifications → Live Location → History |
| 6. Security & Reliability | ⏳ | Firestore rules, permissions, error/offline handling, false-SOS prevention |
| 7. Testing | ⏳ | Unit, UI, Firebase, real-device |
| 8. Polish | ⏳ | Animation, accessibility, loading/empty/error states, performance, final Figma match |
| 9. Portfolio/Final Year Project | ⏳ | Final README, screenshots, architecture diagram, demo video, cleanup, report, presentation |

---

*Generated from consolidated project specification*