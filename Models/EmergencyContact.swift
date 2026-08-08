import Foundation
import FirebaseFirestore

struct EmergencyContact: Codable, Identifiable, Equatable {
    let id: String
    let ownerId: String
    let name: String
    let phone: String
    let relationship: String
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date

    init(id: String = UUID().uuidString, ownerId: String, name: String, phone: String, relationship: String, isFavorite: Bool = false) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.phone = phone
        self.relationship = relationship
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case ownerId
        case name
        case phone
        case relationship
        case isFavorite
        case createdAt
        case updatedAt
    }
}

extension EmergencyContact {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "ownerId": ownerId,
            "name": name,
            "phone": phone,
            "relationship": relationship,
            "isFavorite": isFavorite,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
}