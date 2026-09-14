import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    var currentLocation: CLLocation? { get }
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func requestPermission()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func getCurrentLocation() async throws -> CLLocation
}

final class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationError.permissionDenied
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            if let location = currentLocation {
                continuation.resume(returning: location)
            } else {
                continuation.resume(throwing: LocationError.locationUnavailable)
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationSubject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

enum LocationError: LocalizedError {
    case permissionDenied
    case locationUnavailable
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission is required for emergency features"
        case .locationUnavailable:
            return "Unable to determine current location"
        case .timeout:
            return "Location request timed out"
        }
    }
}