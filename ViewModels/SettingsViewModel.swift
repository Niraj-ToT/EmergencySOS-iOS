import Foundation
import Combine
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled = false
    @Published var locationSharingEnabled = false
    @Published var criticalAlertsEnabled = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let notificationService: NotificationServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(notificationService: NotificationServiceProtocol = NotificationService(),
         authService: AuthServiceProtocol = AuthService()) {
        self.notificationService = notificationService
        self.authService = authService
        loadSettings()
    }
    
    func loadSettings() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let settings = try await UNUserNotificationCenter.current().notificationSettings()
                notificationsEnabled = settings.authorizationStatus == .authorized
                criticalAlertsEnabled = settings.criticalAlertSetting == .enabled
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleNotifications(_ enabled: Bool) async {
        if enabled {
            let granted = await notificationService.requestPermission()
            notificationsEnabled = granted
        } else {
            // User disabled - would need to guide to Settings app
            notificationsEnabled = false
        }
    }
    
    func toggleLocationSharing(_ enabled: Bool) {
        locationSharingEnabled = enabled
        // Save to UserDefaults or Firestore
    }
    
    func toggleCriticalAlerts(_ enabled: Bool) {
        criticalAlertsEnabled = enabled
        // Critical alerts require special entitlement and user permission
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

import UIKit