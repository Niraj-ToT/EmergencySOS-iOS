# EmergencySOS-iOS Architecture

## Architecture Pattern

The application follows the MVVM (Model-View-ViewModel) architecture.

```
SwiftUI Views
        ↓
ViewModels
        ↓
Repositories
        ↓
Services
        ↓
Firebase
        ↓
Firestore
```

## Layers

### Views
Responsible for displaying UI and handling user interactions.

### ViewModels
Contains presentation logic and communicates with repositories.

### Models
Represents application data structures.

### Repositories
Acts as the bridge between ViewModels and Services.

### Services
Handles Firebase Authentication, Firestore, Location Services, Notifications, and Storage.

## Benefits

- Clean Architecture
- Separation of Concerns
- Testability
- Scalability
- Reusability
- Easy Maintenance