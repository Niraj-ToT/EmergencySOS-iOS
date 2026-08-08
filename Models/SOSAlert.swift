import Foundation
import FirebaseFirestore
import CoreLocation

enum SOSStatus: String, Codable {
    case active
    case ended
    case cancelled
}

struct SOSAlert: Codable, Identifiable {
    let id: String
    let userId: String
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    var status: SOSStatus
    let endedAt: Date?
    let createdAt: Date

    init(id: String = UUID().uuidString, userId: String, latitude: Double, longitude: Double, status: SOSStatus = .active) {
        self.id = id
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = Date()
        self.status = status
        self.endedAt = nil
        self.createdAt = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case latitude
        case longitude
        case timestamp
        case status
        case endedAt
        case createdAt
    }
}

extension SOSAlert {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Timestamp(date: timestamp),
            "status": status.rawValue,
            "endedAt": endedAt != nil ? Timestamp(date: endedAt!) : NSNull(),
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}