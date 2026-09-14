import Foundation
import UserNotifications
import FirebaseMessaging
import Combine

protocol NotificationServiceProtocol {
    var isAuthorized: Bool { get }
    var fcmToken: String? { get }
    
    func requestPermission() async -> Bool
    func configure()
    func sendEmergencyNotification(to tokens: [String], alert: SOSAlert, user: User)
    func handleNotificationResponse(_ response: UNNotificationResponse)
}

final class NotificationService: NSObject, NotificationServiceProtocol, ObservableObject {
    @Published var isAuthorized: Bool = false
    @Published var fcmToken: String?
    
    private let messaging = Messaging.messaging()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        messaging.delegate = self
    }
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert])
            await MainActor.run {
                self.isAuthorized = granted
            }
            if granted {
                await registerForRemoteNotifications()
            }
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func configure() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
        
        Messaging.messaging().token { token, error in
            if let token = token {
                DispatchQueue.main.async {
                    self.fcmToken = token
                }
            }
        }
    }
    
    private func registerForRemoteNotifications() async {
        await UIApplication.shared.registerForRemoteNotifications()
    }
    
    func sendEmergencyNotification(to tokens: [String], alert: SOSAlert, user: User) {
        // This would typically be called from a Cloud Function or backend
        // For direct device-to-device, you'd use a different approach
        let content = UNMutableNotificationContent()
        content.title = "🚨 Emergency Alert"
        content.body = "\(user.name) has triggered an emergency SOS at \(alert.timestamp.formatted())"
        content.sound = .defaultCritical
        content.categoryIdentifier = "EMERGENCY_SOS"
        content.userInfo = [
            "alertId": alert.id,
            "userId": alert.userId,
            "latitude": alert.latitude,
            "longitude": alert.longitude,
            "type": "sos_alert"
        ]
        
        // In production, send via FCM HTTP v1 API or Cloud Functions
        // This is a placeholder for the notification payload structure
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        if let alertId = userInfo["alertId"] as? String {
            // Navigate to SOS detail or map view
            NotificationCenter.default.post(name: .openSOSAlert, object: alertId)
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationResponse(response)
        completionHandler()
    }
}

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.fcmToken = fcmToken
        // Send token to your backend/Firestore for user profile
    }
}

extension Notification.Name {
    static let openSOSAlert = Notification.Name("openSOSAlert")
}

import UIKit