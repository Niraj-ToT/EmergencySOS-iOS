import Foundation
import Combine
import CoreLocation

@MainActor
final class SOSViewModel: ObservableObject {
    @Published var sosState: SOSState = .idle
    @Published var currentLocation: CLLocation?
    @Published var liveLocations: [LiveLocation] = []
    @Published var countdown: Int = 0
    @Published var errorMessage: String?
    
    private let sosRepository: SOSRepositoryProtocol
    private let locationService: LocationServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let contactRepository: ContactRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var countdownTimer: Timer?
    private var locationUpdateTimer: Timer?
    
    enum SOSState: Equatable {
        case idle
        case confirming
        case activating
        case active(alert: SOSAlert)
        case ending
        case ended
        case cancelled
    }
    
    init(sosRepository: SOSRepositoryProtocol = SOSRepository(),
         locationService: LocationServiceProtocol = LocationService(),
         notificationService: NotificationServiceProtocol = NotificationService(),
         contactRepository: ContactRepositoryProtocol = ContactRepository()) {
        self.sosRepository = sosRepository
        self.locationService = locationService
        self.notificationService = notificationService
        self.contactRepository = contactRepository
        observeLocation()
    }
    
    private func observeLocation() {
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocation = location
                if case .active(let alert) = self?.sosState {
                    Task { await self?.updateLiveLocation(alert: alert, location: location) }
                }
            }
            .store(in: &cancellables)
    }
    
    func startSOSConfirmation() {
        sosState = .confirming
        startCountdown(seconds: 5)
    }
    
    func cancelSOSConfirmation() {
        stopCountdown()
        sosState = .idle
    }
    
    func confirmAndActivateSOS() async {
        stopCountdown()
        sosState = .activating
        
        guard let userId = getCurrentUserId(), let location = currentLocation else {
            errorMessage = "Location or user not available"
            sosState = .idle
            return
        }
        
        do {
            let alert = SOSAlert(
                userId: userId,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            try await sosRepository.createSOSAlert(alert)
            
            // Notify emergency contacts
            await notifyEmergencyContacts(alert: alert)
            
            // Start live location updates
            startLiveLocationUpdates(for: alert)
            
            sosState = .active(alert: alert)
        } catch {
            errorMessage = error.localizedDescription
            sosState = .idle
        }
    }
    
    func endSOS() async {
        guard case .active(let alert) = sosState else { return }
        
        sosState = .ending
        stopLiveLocationUpdates()
        
        do {
            var updatedAlert = alert
            updatedAlert.status = .ended
            try await sosRepository.updateSOSAlert(updatedAlert)
            sosState = .ended
            
            // Reset after showing ended state
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.sosState = .idle
            }
        } catch {
            errorMessage = error.localizedDescription
            sosState = .active(alert: alert)
        }
    }
    
    private func startCountdown(seconds: Int) {
        countdown = seconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.countdown > 0 {
                self.countdown -= 1
            } else {
                timer.invalidate()
                Task { await self.confirmAndActivateSOS() }
            }
        }
    }
    
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdown = 0
    }
    
    private func startLiveLocationUpdates(for alert: SOSAlert) {
        locationService.startUpdatingLocation()
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self = self, let location = self.currentLocation else { return }
            Task { await self.updateLiveLocation(alert: alert, location: location) }
        }
    }
    
    private func stopLiveLocationUpdates() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        locationService.stopUpdatingLocation()
    }
    
    private func updateLiveLocation(alert: SOSAlert, location: CLLocation) async {
        let liveLocation = LiveLocation(
            userId: alert.userId,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            speed: location.speed >= 0 ? location.speed : nil
        )
        
        do {
            try await sosRepository.addLiveLocation(liveLocation)
        } catch {
            print("Failed to update live location: \(error)")
        }
    }
    
    private func notifyEmergencyContacts(alert: SOSAlert) async {
        do {
            let contacts = try await contactRepository.getFavoriteContacts(for: alert.userId)
            let tokens = contacts.compactMap { $0.fcmToken } // Would need to store FCM tokens
            if !tokens.isEmpty {
                // notificationService.sendEmergencyNotification(to: tokens, alert: alert, user: user)
            }
        } catch {
            print("Failed to notify contacts: \(error)")
        }
    }
    
    private func getCurrentUserId() -> String? {
        // Get from AuthService or UserDefaults
        return nil // Placeholder
    }
}