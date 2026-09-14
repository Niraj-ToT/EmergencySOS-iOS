import Foundation
import Combine

@MainActor
final class ContactViewModel: ObservableObject {
    @Published var contacts: [EmergencyContact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddContact = false
    @Published var editingContact: EmergencyContact?
    
    private let contactRepository: ContactRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(contactRepository: ContactRepositoryProtocol = ContactRepository(),
         userRepository: UserRepositoryProtocol = UserRepository()) {
        self.contactRepository = contactRepository
        self.userRepository = userRepository
        observeContacts()
    }
    
    private func observeContacts() {
        guard let userId = getCurrentUserId() else { return }
        
        contactRepository.listenToContacts(for: userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] contacts in
                self?.contacts = contacts.sorted { ($0.isFavorite ? 0 : 1) < ($1.isFavorite ? 0 : 1) }
            }
            .store(in: &cancellables)
    }
    
    func loadContacts() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let userId = getCurrentUserId() else { return }
        
        do {
            contacts = try await contactRepository.getContacts(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addContact(name: String, phone: String, relationship: String, isFavorite: Bool = false) async {
        guard let userId = getCurrentUserId() else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let contact = EmergencyContact(
                ownerId: userId,
                name: name,
                phone: phone,
                relationship: relationship,
                isFavorite: isFavorite
            )
            try await contactRepository.addContact(contact)
            showingAddContact = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateContact(_ contact: EmergencyContact) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await contactRepository.updateContact(contact)
            editingContact = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteContact(_ contact: EmergencyContact) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await contactRepository.deleteContact(contact.id, for: contact.ownerId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleFavorite(_ contact: EmergencyContact) async {
        var updatedContact = contact
        updatedContact = EmergencyContact(
            id: contact.id,
            ownerId: contact.ownerId,
            name: contact.name,
            phone: contact.phone,
            relationship: contact.relationship,
            isFavorite: !contact.isFavorite
        )
        await updateContact(updatedContact)
    }
    
    func startEditing(_ contact: EmergencyContact) {
        editingContact = contact
    }
    
    private func getCurrentUserId() -> String? {
        return userRepository.getCurrentUser()?.uid
    }
}