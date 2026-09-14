# EmergencySOS-iOS Database Design

## Overview
The application uses **Cloud Firestore** as its primary NoSQL document database. Data is organized into top-level collections with document IDs designed for efficient querying, real-time listener updates, and strict security rule enforcement.

---

## Collections & Schemas

### 1. `users` Collection
Stores user profile and critical medical information.

- **Document ID**: `{uid}` (Matches Firebase Authentication UID)

| Field | Type | Required | Description |
|---|---|---|---|
| `uid` | String | Yes | Firebase Auth unique identifier |
| `name` | String | Yes | User's full name |
| `email` | String | Yes | Primary email address |
| `phone` | String | Yes | Contact phone number (with country code) |
| `profileImageURL` | String | No | Firebase Storage download URL |
| `bloodGroup` | String | No | Blood group (e.g., "O+", "A-", "B+") |
| `medicalInfo` | String | No | Allergies, chronic illnesses, emergency notes |
| `createdAt` | Timestamp | Yes | Account creation timestamp |
| `updatedAt` | Timestamp | Yes | Last profile update timestamp |

---

### 2. `emergencyContacts` Collection
Stores trusted emergency contacts linked to a specific user.

- **Document ID**: `{id}` (Auto-generated UUID or Firestore ID)

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | String | Yes | Unique contact document identifier |
| `ownerId` | String | Yes | UID of the user who owns this contact |
| `name` | String | Yes | Full name of the emergency contact |
| `phone` | String | Yes | Phone number of the contact |
| `relationship` | String | Yes | Relationship (e.g., "Parent", "Spouse", "Friend") |
| `isFavorite` | Boolean | Yes | Priority flag for primary emergency alerts |
| `createdAt` | Timestamp | Yes | Contact record creation timestamp |
| `updatedAt` | Timestamp | Yes | Last contact update timestamp |

---

### 3. `sosAlerts` Collection
Records every emergency SOS event triggered by a user.

- **Document ID**: `{id}` (Auto-generated UUID or Firestore ID)

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | String | Yes | Unique alert identifier |
| `userId` | String | Yes | UID of the user who triggered the SOS |
| `latitude` | Double | Yes | Initial latitude coordinate when SOS was triggered |
| `longitude` | Double | Yes | Initial longitude coordinate when SOS was triggered |
| `timestamp` | Timestamp | Yes | Timestamp when the emergency was initiated |
| `status` | String | Yes | Alert status: `"active"`, `"ended"`, `"cancelled"` |
| `endedAt` | Timestamp | No | Timestamp when the user ended the emergency |
| `createdAt` | Timestamp | Yes | Alert record creation timestamp |

---

### 4. `liveLocations` Collection
Tracks real-time coordinates during active SOS alerts for live map monitoring.

- **Document ID**: `{userId}` (One document per user to avoid unbounded writes)

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | String | Yes | Unique live location tracking record identifier |
| `userId` | String | Yes | UID of the user transmitting live location |
| `latitude` | Double | Yes | Current GPS latitude |
| `longitude` | Double | Yes | Current GPS longitude |
| `speed` | Double | No | User's current speed in m/s |
| `timestamp` | Timestamp | Yes | Timestamp of the last coordinate update |

---

## Relationships

- **User to Emergency Contacts**: 1-to-Many (`users.uid` == `emergencyContacts.ownerId`).
- **User to SOS Alerts**: 1-to-Many (`users.uid` == `sosAlerts.userId`).
- **User to Live Location**: 1-to-1 active tracking record (`users.uid` == `liveLocations.userId`).

---

## Security & Access Control Principles

1. **User Profile**: Only authenticated users can read or write their own profile document (`request.auth.uid == resource.data.uid`).
2. **Emergency Contacts**: Only the contact owner can read, create, update, or delete contacts (`request.auth.uid == resource.data.ownerId`).
3. **SOS Alerts**: Created by the authenticated user; read access is restricted to the user and designated emergency contacts.
4. **Live Location**: Transmitted only when an SOS is in `"active"` status; updates stop immediately when ended or cancelled.