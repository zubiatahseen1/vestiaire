import Foundation
import Observation


@MainActor
@Observable
final class WeatherViewModel {
    private(set) var weather: WeatherResponse?
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    @ObservationIgnored private let provider = OpenMeteoWeatherProvider.shared

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            weather = try await provider.response()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
