# EmergencySOS-iOS

An iOS emergency SOS app built with Swift, SwiftUI, and Firebase following MVVM architecture with Repository pattern.

## Features

- 🔐 **Authentication** - Email/password register, login, password reset via Firebase Auth
- 👤 **User Profile** - Name, phone, profile picture, blood group, medical info
- 📞 **Emergency Contacts** - Add/edit/delete contacts, mark favorites
- 🚨 **Emergency SOS** - One-tap emergency activation with location sharing
- 📍 **Real-Time Location** - CoreLocation + MapKit live tracking during SOS
- 🔔 **Notifications** - Firebase Cloud Messaging alerts to trusted contacts
- ⚙️ **Settings** - Notification preferences, privacy, account management

## Architecture

```
SwiftUI View → ViewModel → Repository → Service → Firebase / Apple Framework
```

## Tech Stack

- **Language**: Swift 5.9+
- **UI**: SwiftUI, Combine
- **Architecture**: MVVM + Repository Pattern
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Messaging)
- **Location**: CoreLocation, MapKit
- **Notifications**: UserNotifications, FCM

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

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase account

## Setup

1. Clone the repository
2. Open `EmergencySOS-iOS.xcodeproj` in Xcode
3. Add your `GoogleService-Info.plist` from Firebase Console
4. Configure Firebase project (Auth, Firestore, Storage, Cloud Messaging)
5. Build and run on device (simulator doesn't support all location/notification features)

## Firebase Configuration

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add iOS app with your bundle ID
3. Download `GoogleService-Info.plist` and add to Xcode project
4. Enable Authentication (Email/Password)
5. Create Firestore database
6. Enable Cloud Messaging
7. Set up Firestore Security Rules (see `Documentation/Security.md`)

## Documentation

- [App Flow](Documentation/AppFlow.md)
- [Architecture](Documentation/Architecture.md)
- [Database Schema](Documentation/Database.md)
- [User Stories](Documentation/UserStories.md)

## Testing

```bash
# Unit tests
xcodebuild test -scheme EmergencySOS-iOS -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests
xcodebuild test -scheme EmergencySOS-iOS -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:EmergencySOS-iOSUITests
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request