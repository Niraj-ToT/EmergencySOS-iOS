# EmergencySOS-iOS Project Roadmap

## Overview
This roadmap tracks the development lifecycle of the **EmergencySOS-iOS** final-year project across 9 distinct phases. It outlines work executable on Windows (design, architecture, documentation, code prep) and work scheduled for macOS (Xcode, simulators, device testing, hardware frameworks).

---

## 📌 Development Phases

### Phase 1: Foundation & Setup
- [x] Git repository initialization and GitHub remote configuration
- [x] Standard `.gitignore` for macOS, Xcode, and local tooling
- [x] Open-source MIT License
- [x] Initial project directory structure
- [x] Core design tokens (`AppColors`, `AppConstants`, `AppTheme`)
- [x] UI concept mockups (Figma screens 01–07)

### Phase 2: System Architecture & Documentation
- [x] High-level MVVM + Repository architecture specification (`Architecture.md`)
- [x] Cloud Firestore database schema & relationships (`Database.md`)
- [x] Software Requirements Specification (`SoftwareRequirements.md`)
- [x] User stories and acceptance criteria (`UserStories.md`)
- [x] End-to-end screen navigation and SOS lifecycle (`AppFlow.md`)
- [x] Project development roadmap (`Roadmap.md`)
- [ ] Security rules and privacy policy specification (`Security.md`)

### Phase 3: macOS & Xcode Project Configuration
*(To be executed once Mac hardware is available)*
- [ ] Xcode project setup and bundle identifier configuration
- [ ] Swift Package Manager (SPM) dependency integration
- [ ] Firebase SDK integration (`FirebaseAuth`, `FirebaseFirestore`, `FirebaseMessaging`)
- [ ] `GoogleService-Info.plist` placement and environment configuration
- [ ] Target capabilities: Background Modes (Location updates, Remote notifications)

### Phase 4: Core User Flows (UI & Logic)
- [ ] Splash screen authentication router (`SplashView`)
- [ ] User login and session persistence (`LoginView`, `AuthViewModel`)
- [ ] Registration with Firestore user document initialization (`RegisterView`)
- [ ] Password recovery flow (`ForgotPasswordView`)
- [ ] Home dashboard overview (`HomeView`, `HomeViewModel`)
- [ ] Emergency contacts management CRUD (`ContactView`, `ContactViewModel`)
- [ ] User profile and medical ID configuration (`ProfileView`, `ProfileViewModel`)

### Phase 5: Emergency SOS & Location Engine
- [ ] Safety countdown and accidental trigger prevention mechanism
- [ ] CoreLocation permission handling (When In Use / Always authorization)
- [ ] GPS coordinate fetching and accuracy validation (`LocationService`)
- [ ] Active SOS document creation in Firestore (`sosAlerts`)
- [ ] Live coordinate streaming to `liveLocations` collection
- [ ] MapKit integration for live responder/user tracking (`SOSView`, `SOSViewModel`)
- [ ] Emergency alert push notification dispatch (`NotificationService`)
- [ ] SOS resolution flow and historical log persistence

### Phase 6: Reliability, Security & Edge Cases
- [ ] Firestore Security Rules deployment and testing
- [ ] Offline coordinate caching and network reconnection handling
- [ ] Location authorization denial fallbacks (prompting device Settings)
- [ ] Graceful degradation for notification failures (fallback alert triggers)
- [ ] Robust error handling across repositories and services

### Phase 7: Verification & Testing
- [ ] Unit tests for ViewModels, state machines, and repositories
- [ ] UI navigation and input validation testing
- [ ] Integration testing with Firebase emulators / test project
- [ ] Real iPhone physical device testing:
  - Background GPS accuracy and battery consumption
  - Push notification delivery via APNs / FCM
  - Physical SOS trigger testing in varying network conditions

### Phase 8: UI Polish & Accessibility
- [ ] Design token alignment with finalized Figma components
- [ ] Dynamic Type and VoiceOver accessibility labels
- [ ] Loading spinners, empty states, and inline error banners
- [ ] Dark Mode and Light Mode visual verification
- [ ] Micro-interactions and transition animations

### Phase 9: Final-Year Delivery & Portfolio
- [ ] Comprehensive README with architecture diagrams and screen previews
- [ ] Video demonstration walkthrough of the live SOS flow
- [ ] Project report and technical documentation compilation
- [ ] Final-year project viva/presentation preparation