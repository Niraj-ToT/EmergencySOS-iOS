import Foundation
import Combine
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService(), userRepository: UserRepositoryProtocol = UserRepository()) {
        self.authService = authService
        self.userRepository = userRepository
        observeAuthState()
    }
    
    private func observeAuthState() {
        authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                self?.isAuthenticated = firebaseUser != nil
                if firebaseUser != nil {
                    Task { await self?.loadUserProfile() }
                } else {
                    self?.currentUser = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func loadUserProfile() async {
        do {
            currentUser = try await userRepository.getCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signUp(email: String, password: String, name: String, phone: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            _ = try await authService.signUp(email: email, password: password, name: name, phone: phone)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.sendPasswordReset(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfile(name: String? = nil, phone: String? = nil) async {
        guard var user = currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await authService.updateProfile(name: name, phone: phone, photoURL: nil)
            if let name = name { user = User(uid: user.uid, name: name, email: user.email, phone: user.phone, profileImageURL: user.profileImageURL, bloodGroup: user.bloodGroup, medicalInfo: user.medicalInfo) }
            if let phone = phone { user = User(uid: user.uid, name: user.name, email: user.email, phone: phone, profileImageURL: user.profileImageURL, bloodGroup: user.bloodGroup, medicalInfo: user.medicalInfo) }
            try await userRepository.updateUser(user)
            currentUser = user
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}