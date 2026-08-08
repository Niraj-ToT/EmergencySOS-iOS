import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol FirestoreServiceProtocol {
    func create<T: Encodable>(_ object: T, in collection: String) async throws
    func update<T: Encodable>(_ object: T, in collection: String, documentId: String) async throws
    func delete(in collection: String, documentId: String) async throws
    func getDocument<T: Decodable>(in collection: String, documentId: String, as type: T.Type) async throws -> T?
    func getDocuments<T: Decodable>(in collection: String, as type: T.Type, where field: String, isEqualTo value: Any) async throws -> [T]
    func listen<T: Decodable>(to collection: String, as type: T.Type, where field: String, isEqualTo value: Any) -> AnyPublisher<[T], Error>
}

final class FirestoreService: FirestoreServiceProtocol {
    private let db = Firestore.firestore()
    
    func create<T: Encodable>(_ object: T, in collection: String) async throws {
        let data = try Firestore.Encoder().encode(object)
        let documentRef = db.collection(collection).document()
        try await documentRef.setData(data)
    }
    
    func update<T: Encodable>(_ object: T, in collection: String, documentId: String) async throws {
        let data = try Firestore.Encoder().encode(object)
        try await db.collection(collection).document(documentId).updateData(data)
    }
    
    func delete(in collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }
    
    func getDocument<T: Decodable>(in collection: String, documentId: String, as type: T.Type) async throws -> T? {
        let document = try await db.collection(collection).document(documentId).getDocument()
        guard document.exists else { return nil }
        return try document.data(as: type)
    }
    
    func getDocuments<T: Decodable>(in collection: String, as type: T.Type, where field: String, isEqualTo value: Any) async throws -> [T] {
        let snapshot = try await db.collection(collection)
            .whereField(field, isEqualTo: value)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: type) }
    }
    
    func listen<T: Decodable>(to collection: String, as type: T.Type, where field: String, isEqualTo value: Any) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()
        
        let listener = db.collection(collection)
            .whereField(field, isEqualTo: value)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    subject.send([])
                    return
                }
                
                do {
                    let objects = try documents.compactMap { try $0.data(as: type) }
                    subject.send(objects)
                } catch {
                    subject.send(completion: .failure(error))
                }
            }
        
        return subject.handleEvents(receiveCancel: {
            listener.remove()
        }).eraseToAnyPublisher()
    }
}