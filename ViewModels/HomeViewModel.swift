import Foundation
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var user: User?
    @Published var favoriteContacts: [EmergencyContact] = []
    @Published var activeSOSAlert: SOSAlert?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userRepository: UserRepositoryProtocol
    private let contactRepository: ContactRepositoryProtocol
    private let sosRepository: SOSRepositoryProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserRepositoryProtocol = UserRepository(),
         contactRepository: ContactRepositoryProtocol = ContactRepository(),
         sosRepository: SOSRepositoryProtocol = SOSRepository(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.userRepository = userRepository
        self.contactRepository = contactRepository
        self.sosRepository = sosRepository
        self.locationService = locationService
        observeData()
    }
    
    private func observeData() {
        // Observe user profile
        userRepository.listenToUser(userRepository.getCurrentUser()?.uid ?? "")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &cancellables)
        
        // Observe favorite contacts
        contactRepository.listenToContacts(for: userRepository.getCurrentUser()?.uid ?? "")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] contacts in
                self?.favoriteContacts = contacts.filter { $0.isFavorite }
            }
            .store(in: &cancellables)
        
        // Observe active SOS
        sosRepository.listenToActiveSOS(for: userRepository.getCurrentUser()?.uid ?? "")
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] alert in
                self?.activeSOSAlert = alert
            }
            .store(in: &cancellables)
    }
    
    func loadInitialData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            user = try await userRepository.getCurrentUser()
            if let userId = user?.uid {
                favoriteContacts = try await contactRepository.getFavoriteContacts(for: userId)
                activeSOSAlert = try await sosRepository.getActiveSOSAlert(for: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func triggerSOS() async -> SOSAlert? {
        guard let user = user, let location = locationService.currentLocation else {
            errorMessage = "Unable to get current location"
            return nil
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let alert = SOSAlert(
                userId: user.uid,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            try await sosRepository.createSOSAlert(alert)
            activeSOSAlert = alert
            return alert
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func endSOS() async {
        guard var alert = activeSOSAlert else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            alert.status = .ended
            try await sosRepository.updateSOSAlert(alert)
            activeSOSAlert = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}