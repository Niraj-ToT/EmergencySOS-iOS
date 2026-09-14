import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

protocol AuthServiceProtocol {
    var currentUser: FirebaseAuth.User? { get }
    var authStatePublisher: AnyPublisher<FirebaseAuth.User?, Never> { get }
    
    func signUp(email: String, password: String, name: String, phone: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() throws
    func sendPasswordReset(email: String) async throws
    func updateProfile(name: String?, phone: String?, photoURL: URL?) async throws
    func deleteAccount() async throws
}

final class AuthService: AuthServiceProtocol, ObservableObject {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let authStateSubject = CurrentValueSubject<FirebaseAuth.User?, Never>(nil)
    
    var currentUser: FirebaseAuth.User? {
        auth.currentUser
    }
    
    var authStatePublisher: AnyPublisher<FirebaseAuth.User?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    init() {
        authStateSubject.send(auth.currentUser)
        auth.addStateDidChangeListener { [weak self] _, user in
            self?.authStateSubject.send(user)
        }
    }
    
    func signUp(email: String, password: String, name: String, phone: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        let firebaseUser = result.user
        
        let user = User(
            uid: firebaseUser.uid,
            name: name,
            email: email,
            phone: phone
        )
        
        try await db.collection("users").document(firebaseUser.uid).setData(user.dictionary)
        return user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return try await fetchUser(uid: result.user.uid)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    func updateProfile(name: String? = nil, phone: String? = nil, photoURL: URL? = nil) async throws {
        guard let firebaseUser = auth.currentUser else { throw AuthError.noCurrentUser }
        
        var updateData: [String: Any] = ["updatedAt": Timestamp(date: Date())]
        
        if let name = name {
            updateData["name"] = name
        }
        if let phone = phone {
            updateData["phone"] = phone
        }
        if let photoURL = photoURL {
            updateData["profileImageURL"] = photoURL.absoluteString
            let changeRequest = firebaseUser.createProfileChangeRequest()
            changeRequest.photoURL = photoURL
            try await changeRequest.commitChanges()
        }
        
        try await db.collection("users").document(firebaseUser.uid).updateData(updateData)
    }
    
    func deleteAccount() async throws {
        guard let firebaseUser = auth.currentUser else { throw AuthError.noCurrentUser }
        
        try await db.collection("users").document(firebaseUser.uid).delete()
        try await firebaseUser.delete()
    }
    
    func fetchUser(uid: String) async throws -> User {
        let document = try await db.collection("users").document(uid).getDocument()
        guard let data = document.data() else { throw AuthError.userNotFound }
        
        return try decodeUser(from: data, uid: uid)
    }
    
    private func decodeUser(from data: [String: Any], uid: String) throws -> User {
        guard let name = data["name"] as? String,
              let email = data["email"] as? String,
              let phone = data["phone"] as? String else {
            throw AuthError.invalidUserData
        }
        
        let profileImageURL = data["profileImageURL"] as? String
        let bloodGroup = data["bloodGroup"] as? String
        let medicalInfo = data["medicalInfo"] as? String
        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updatedAt = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        
        var user = User(uid: uid, name: name, email: email, phone: phone, profileImageURL: profileImageURL, bloodGroup: bloodGroup, medicalInfo: medicalInfo)
        return user
    }
}

enum AuthError: LocalizedError {
    case noCurrentUser
    case userNotFound
    case invalidUserData
    case firestoreError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noCurrentUser:
            return "No authenticated user found"
        case .userNotFound:
            return "User profile not found"
        case .invalidUserData:
            return "Invalid user data"
        case .firestoreError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
}