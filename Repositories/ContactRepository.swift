import Foundation
import Combine

protocol ContactRepositoryProtocol {
    func getContacts(for userId: String) async throws -> [EmergencyContact]
    func addContact(_ contact: EmergencyContact) async throws
    func updateContact(_ contact: EmergencyContact) async throws
    func deleteContact(_ contactId: String, for userId: String) async throws
    func getFavoriteContacts(for userId: String) async throws -> [EmergencyContact]
    func listenToContacts(for userId: String) -> AnyPublisher<[EmergencyContact], Error>
}

final class ContactRepository: ContactRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService()) {
        self.firestoreService = firestoreService
    }
    
    func getContacts(for userId: String) async throws -> [EmergencyContact] {
        try await firestoreService.getDocuments(in: "emergencyContacts", as: EmergencyContact.self, where: "ownerId", isEqualTo: userId)
    }
    
    func addContact(_ contact: EmergencyContact) async throws {
        try await firestoreService.create(contact, in: "emergencyContacts")
    }
    
    func updateContact(_ contact: EmergencyContact) async throws {
        try await firestoreService.update(contact, in: "emergencyContacts", documentId: contact.id)
    }
    
    func deleteContact(_ contactId: String, for userId: String) async throws {
        try await firestoreService.delete(in: "emergencyContacts", documentId: contactId)
    }
    
    func getFavoriteContacts(for userId: String) async throws -> [EmergencyContact] {
        let contacts = try await getContacts(for: userId)
        return contacts.filter { $0.isFavorite }
    }
    
    func listenToContacts(for userId: String) -> AnyPublisher<[EmergencyContact], Error> {
        firestoreService.listen(to: "emergencyContacts", as: EmergencyContact.self, where: "ownerId", isEqualTo: userId)
    }
}