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
| `profileImage` | String | No | Firebase Storage download URL |
| `bloodGroup` | String | No | Blood group (e.g., "O+", "A-", "B+") |
| `medicalInfo` | String | No | Allergies, chronic illnesses, emergency notes |
| `createdAt` | Timestamp | Yes | Account creation timestamp |
| `updatedAt` | Timestamp | Yes | Last profile update timestamp |

---

### 2. `emergencyContacts` Collection
Stores trusted emergency contacts linked to a specific user.

- **Document ID**: `{contactId}` (Auto-generated Firestore ID)

| Field | Type | Required | Description |
|---|---|---|---|
| `contactId` | String | Yes | Unique contact document identifier |
| `ownerId` | String | Yes | UID of the user who owns this contact |
| `name` | String | Yes | Full name of the emergency contact |
| `phone` | String | Yes | Phone number of the contact |
| `relationship` | String | Yes | Relationship (e.g., "Parent", "Spouse", "Friend") |
| `favorite` | Boolean | Yes | Priority flag for primary emergency alerts |
| `createdAt` | Timestamp | Yes | Contact record creation timestamp |

---

### 3. `sosAlerts` Collection
Records every emergency SOS event triggered by a user.

- **Document ID**: `{alertId}` (Auto-generated Firestore ID)

| Field | Type | Required | Description |
|---|---|---|---|
| `alertId` | String | Yes | Unique alert identifier |
| `userId` | String | Yes | UID of the user who triggered the SOS |
| `userName` | String | Yes | Snapshot of user name at time of alert |
| `userPhone` | String | Yes | Snapshot of user phone at time of alert |
| `latitude` | Double | Yes | Initial latitude coordinate when SOS was triggered |
| `longitude` | Double | Yes | Initial longitude coordinate when SOS was triggered |
| `timestamp` | Timestamp | Yes | Timestamp when the emergency was initiated |
| `status` | String | Yes | Alert status: `"active"`, `"resolved"`, `"cancelled"` |
| `resolvedAt` | Timestamp | No | Timestamp when the user ended the emergency |

---

### 4. `liveLocations` Collection
Tracks real-time coordinates during active SOS alerts for live map monitoring.

- **Document ID**: `{userId}` (One document per user to avoid unbounded writes)

| Field | Type | Required | Description |
|---|---|---|---|
| `userId` | String | Yes | UID of the user transmitting live location |
| `alertId` | String | Yes | Active SOS alert ID |
| `latitude` | Double | Yes | Current GPS latitude |
| `longitude` | Double | Yes | Current GPS longitude |
| `speed` | Double | Yes | User's current speed in m/s |
| `heading` | Double | No | Direction of movement in degrees |
| `timestamp` | Timestamp | Yes | Timestamp of the last coordinate update |
| `isActive` | Boolean | Yes | Flag indicating whether live streaming is active |

---

## Relationships

- **User to Emergency Contacts**: 1-to-Many (`users.uid` == `emergencyContacts.ownerId`).
- **User to SOS Alerts**: 1-to-Many (`users.uid` == `sosAlerts.userId`).
- **SOS Alert to Live Location**: 1-to-1 active link (`sosAlerts.alertId` == `liveLocations.alertId`).

---

## Security & Access Control Principles

1. **User Profile**: Only authenticated users can read or write their own profile document (`request.auth.uid == resource.data.uid`).
2. **Emergency Contacts**: Only the contact owner can read, create, update, or delete contacts (`request.auth.uid == resource.data.ownerId`).
3. **SOS Alerts**: Created by the authenticated user; read access is restricted to the user and designated emergency contacts.
4. **Live Location**: Transmitted only when an SOS is in `"active"` status; updates stop immediately when resolved.