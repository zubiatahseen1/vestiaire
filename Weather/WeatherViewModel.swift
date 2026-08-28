import CoreLocation
import Foundation
import Observation


@MainActor
@Observable
final class WeatherViewModel {
    private(set) var weather: WeatherResponse?
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    @ObservationIgnored private let locationManager = LocationManager()
    @ObservationIgnored private let service = WeatherService()

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let coordinate = try await locationManager.currentCoordinate()
            weather = try await service.fetchWeather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
