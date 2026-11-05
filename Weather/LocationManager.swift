
import CoreLocation

@MainActor
final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    /// Everyone waiting on the current request. Today, Planner and the weather
    /// card can all ask at once on launch; they share one location fix.
    private var waiters: [CheckedContinuation<CLLocationCoordinate2D, Error>] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Asks for permission if needed, then returns the device's current coordinate once.
    func currentCoordinate() async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            waiters.append(continuation)
            guard waiters.count == 1 else { return }   // a request is already in flight

            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            default:
                finish(.failure(WeatherError.locationDenied))
            }
        }
    }

    private func finish(_ result: Result<CLLocationCoordinate2D, Error>) {
        let pending = waiters
        waiters = []
        pending.forEach { $0.resume(with: result) }
    }

    // MARK: - CLLocationManagerDelegate

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            guard !self.waiters.isEmpty else { return }
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.manager.requestLocation()
            case .denied, .restricted:
                self.finish(.failure(WeatherError.locationDenied))
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        Task { @MainActor in
            self.finish(.success(coordinate))
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.finish(.failure(WeatherError.locationUnavailable))
        }
    }
}
