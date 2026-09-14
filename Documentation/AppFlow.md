# EmergencySOS-iOS Application Flow & Navigation

## Overview
This document outlines the user navigation flow, authentication state routing, and the active SOS lifecycle for the EmergencySOS iOS application.

---

## 1. High-Level Navigation Diagram

```text
Application Launch
        │
        ▼
   Splash View (Session Check)
        │
   ┌────┴────────────────────────┐
   ▼                             ▼
[Unauthenticated]           [Authenticated]
   │                             │
   ▼                             ▼
Login View ──┬── Register       Home View (Dashboard)
             │                   ├── SOS Emergency Trigger
             └── Forgot Password ├── Emergency Contacts Management
                                 ├── Profile & Medical ID
                                 ├── Settings & Preferences
                                 └── SOS History Logs