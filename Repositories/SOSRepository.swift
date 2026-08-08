import Foundation
import Combine

protocol SOSRepositoryProtocol {
    func createSOSAlert(_ alert: SOSAlert) async throws
    func updateSOSAlert(_ alert: SOSAlert) async throws
    func getSOSHistory(for userId: String) async throws -> [SOSAlert]
    func getActiveSOSAlert(for userId: String) async throws -> SOSAlert?
    func addLiveLocation(_ location: LiveLocation) async throws
    func listenToLiveLocation(for userId: String) -> AnyPublisher<[LiveLocation], Error>
    func listenToActiveSOS(for userId: String) -> AnyPublisher<SOSAlert?, Error>
}

final class SOSRepository: SOSRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    func createSOSAlert(_ alert: SOSAlert) async throws {
        try await firestoreService.create(alert, in: "sosAlerts")
    }
    
    func updateSOSAlert(_ alert: SOSAlert) async throws {
        try await firestoreService.update(alert, in: "sosAlerts", documentId: alert.id)
    }
    
    func getSOSHistory(for userId: String) async throws -> [SOSAlert] {
        let alerts = try await firestoreService.getDocuments(in: "sosAlerts", as: SOSAlert.self, where: "userId", isEqualTo: userId)
        return alerts.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getActiveSOSAlert(for userId: String) async throws -> SOSAlert? {
        let alerts = try await firestoreService.getDocuments(in: "sosAlerts", as: SOSAlert.self, where: "userId", isEqualTo: userId)
        return alerts.first { $0.status == .active }
    }
    
    func addLiveLocation(_ location: LiveLocation) async throws {
        try await firestoreService.create(location, in: "liveLocations")
    }
    
    func listenToLiveLocation(for userId: String) -> AnyPublisher<[LiveLocation], Error> {
        firestoreService.listen(to: "liveLocations", as: LiveLocation.self, where: "userId", isEqualTo: userId)
    }
    
    func listenToActiveSOS(for userId: String) -> AnyPublisher<SOSAlert?, Error> {
        firestoreService.listen(to: "sosAlerts", as: SOSAlert.self, where: "userId", isEqualTo: userId)
            .map { alerts in
                alerts.first { $0.status == .active }
            }
            .eraseToAnyPublisher()
    }
}