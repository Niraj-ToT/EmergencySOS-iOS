import Foundation
import FirebaseFirestore
import CoreLocation

struct LiveLocation: Codable, Identifiable {
    let id: String
    let userId: String
    let latitude: Double
    let longitude: Double
    let speed: Double?
    let timestamp: Date

    init(id: String = UUID().uuidString, userId: String, latitude: Double, longitude: Double, speed: Double? = nil) {
        self.id = id
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.speed = speed
        self.timestamp = Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case latitude
        case longitude
        case speed
        case timestamp
    }
}

extension LiveLocation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    var dictionary: [String: Any] {
        return [
            "id": id,
            "userId": userId,
            "latitude": latitude,
            "longitude": longitude,
            "speed": speed as Any,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}