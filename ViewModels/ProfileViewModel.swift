import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedImage: PhotosPickerItem?
    @Published var profileImage: Image?
    @Published var name = ""
    @Published var phone = ""
    @Published var bloodGroup = ""
    @Published var medicalInfo = ""
    
    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(userRepository: UserRepositoryProtocol = UserRepository(),
         authService: AuthServiceProtocol = AuthService()) {
        self.userRepository = userRepository
        self.authService = authService
        loadProfile()
    }
    
    func loadProfile() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                user = try await userRepository.getCurrentUser()
                if let user = user {
                    name = user.name
                    phone = user.phone
                    bloodGroup = user.bloodGroup ?? ""
                    medicalInfo = user.medicalInfo ?? ""
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func saveProfile() async {
        guard var currentUser = user else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            currentUser = User(
                uid: currentUser.uid,
                name: name,
                email: currentUser.email,
                phone: phone,
                profileImageURL: currentUser.profileImageURL,
                bloodGroup: bloodGroup.isEmpty ? nil : bloodGroup,
                medicalInfo: medicalInfo.isEmpty ? nil : medicalInfo
            )
            
            try await authService.updateProfile(name: name, phone: phone, photoURL: nil)
            try await userRepository.updateUser(currentUser)
            user = currentUser
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadProfileImage() {
        guard let item = selectedItem else { return }
        
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                    // Upload to storage and update profileImageURL
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    var selectedItem: PhotosPickerItem? {
        get { selectedImage }
        set { selectedImage = newValue }
    }
}