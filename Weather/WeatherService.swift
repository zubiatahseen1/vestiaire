import Foundation

enum WeatherError: LocalizedError {
    case badResponse
    case locationDenied
    case requestInProgress

    var errorDescription: String? {
        switch self {
        case .badResponse:
            "Couldn't load the weather. Please try again."
        case .locationDenied:
            "Location access is off. Turn it on in Settings to see today's weather."
        case .requestInProgress:
            "Already getting your location."
        }
    }
}

struct WeatherService: Sendable {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        guard var components = URLComponents(string: baseURL) else {
            throw WeatherError.badResponse
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "2")
        ]

        guard let url = components.url else { throw WeatherError.badResponse }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw WeatherError.badResponse
        }

        return try JSONDecoder().decode(WeatherResponse.self, from: data)
    }
}
