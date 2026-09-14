# EmergencySOS-iOS Security Architecture & Rules

## Overview
Because EmergencySOS handles sensitive real-time location data, personal contact details, and emergency medical information, robust security and privacy protections are enforced across the client and backend.

---

## Core Security Principles

1. **Mandatory Authentication**: All database read and write operations require a valid, verified Firebase Authentication token. Unauthenticated access is completely blocked.
2. **Strict Data Isolation**: Users can only read, update, or delete their own profile data and emergency contact lists.
3. **Restricted Emergency Access**: Live location data and SOS alerts are accessible only to the alert owner and designated trusted emergency contacts.
4. **Active-Only Streaming**: Live coordinate broadcasting is permitted exclusively while an alert's status is `"active"`. Once resolved or cancelled, transmission must terminate.
5. **No Secret Storage in Source Control**: API keys, signing certificates, and configuration files (`GoogleService-Info.plist`) must never be committed to public repositories.

---

## Cloud Firestore Security Rules (`firestore.rules`)

These rules enforce server-side validation and authorization for each collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // 1. Users Collection
    // Each user can read and modify only their own profile
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update, delete: if isOwner(userId);
    }

    // 2. Emergency Contacts Collection
    // Only the contact owner can view or manage their emergency contacts
    match /emergencyContacts/{contactId} {
      allow read, write: if isAuthenticated() && 
        (resource == null || resource.data.ownerId == request.auth.uid) &&
        (request.resource == null || request.resource.data.ownerId == request.auth.uid);
    }

    // 3. SOS Alerts Collection
    // Authenticated users can create alerts; owner can update/resolve
    match /sosAlerts/{alertId} {
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow read: if isAuthenticated();
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow delete: if false; // Audit trail: SOS records should not be deleted
    }

    // 4. Live Locations Collection
    // Transmitting location is restricted to the alert owner during active state
    match /liveLocations/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
  }
}