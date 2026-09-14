# 🚨 EmergencySOS-iOS

**"Design and Development of an Emergency SOS and Real-Time Location Sharing System"**

A modern iOS personal-safety application built with SwiftUI, Firebase, and Apple frameworks. The system allows users to rapidly trigger emergency SOS alerts and share their real-time location with trusted contacts during critical situations.

---

## 📌 Project Overview

- **Platform**: iOS 17+
- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Repository Pattern
- **Backend & Cloud**: Firebase (Authentication, Cloud Firestore, Storage, Cloud Messaging)
- **Apple Frameworks**: CoreLocation, MapKit, UserNotifications
- **Design Guidelines**: Apple Human Interface Guidelines (HIG)

---

## ✨ Core Features

1. **Authentication**: Email/password registration, login, password recovery, session state management via Firebase Authentication.
2. **User Profile & Medical ID**: Profile management including emergency medical notes and blood group information.
3. **Emergency Contacts**: CRUD management for trusted emergency contacts with prioritization for emergency alerts.
4. **Emergency SOS System**: Instant SOS activation with safety verification to prevent accidental triggers.
5. **Real-Time Location Sharing**: High-accuracy GPS tracking using CoreLocation and MapKit rendering, streaming active coordinates via Firestore.
6. **Emergency Notifications**: Real-time push notification infrastructure for designated emergency contacts.
7. **SOS History & Settings**: Persistent logging of previous alerts and privacy/notification preference management.

---

## 🏗️ Architecture

The project follows a clean **MVVM (Model-View-ViewModel) + Repository Pattern**: