import Foundation
import FirebaseFirestore

struct User: Codable {
    let uid: String
    let name: String
    let email: String
    let phone: String
    let profileImageURL: String?
    let bloodGroup: String?
    let medicalInfo: String?
    let createdAt: Date
    let updatedAt: Date

    init(uid: String, name: String, email: String, phone: String, profileImageURL: String? = nil, bloodGroup: String? = nil, medicalInfo: String? = nil) {
        self.uid = uid
        self.name = name
        self.email = email
        self.phone = phone
        self.profileImageURL = profileImageURL
        self.bloodGroup = bloodGroup
        self.medicalInfo = medicalInfo
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case email
        case phone
        case profileImageURL
        case bloodGroup
        case medicalInfo
        case createdAt
        case updatedAt
    }
}

extension User {
    var dictionary: [String: Any] {
        return [
            "uid": uid,
            "name": name,
            "email": email,
            "phone": phone,
            "profileImageURL": profileImageURL as Any,
            "bloodGroup": bloodGroup as Any,
            "medicalInfo": medicalInfo as Any,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
}