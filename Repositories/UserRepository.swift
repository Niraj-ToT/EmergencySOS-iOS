import Foundation
import Combine

protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws
    func uploadProfileImage(_ imageData: Data, for userId: String) async throws -> URL
    func listenToUser(_ userId: String) -> AnyPublisher<User?, Error>
}

final class UserRepository: UserRepositoryProtocol {
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService(), authService: AuthServiceProtocol = AuthService()) {
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    func getCurrentUser() async throws -> User? {
        guard let firebaseUser = authService.currentUser else { return nil }
        return try await firestoreService.getDocument(in: "users", documentId: firebaseUser.uid, as: User.self)
    }
    
    func updateUser(_ user: User) async throws {
        var updatedUser = user
        updatedUser = User(
            uid: user.uid,
            name: user.name,
            email: user.email,
            phone: user.phone,
            profileImageURL: user.profileImageURL,
            bloodGroup: user.bloodGroup,
            medicalInfo: user.medicalInfo
        )
        try await firestoreService.update(updatedUser, in: "users", documentId: user.uid)
    }
    
    func uploadProfileImage(_ imageData: Data, for userId: String) async throws -> URL {
        // Placeholder for Firebase Storage upload
        // In production, upload to Firebase Storage and return download URL
        throw RepositoryError.notImplemented
    }
    
    func listenToUser(_ userId: String) -> AnyPublisher<User?, Error> {
        firestoreService.listen(to: "users", as: User.self, where: "uid", isEqualTo: userId)
            .map { $0.first }
            .eraseToAnyPublisher()
    }
}

enum RepositoryError: LocalizedError {
    case notImplemented
    case userNotFound
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Feature not yet implemented"
        case .userNotFound:
            return "User not found"
        case .encodingError:
            return "Failed to encode data"
        }
    }
}