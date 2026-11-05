//
//  OpenMeteoWeatherProvider.swift
//  Vestiaire
//
//  Live weather for the device's location, from Open-Meteo (no API key needed).
//  One shared instance so Today, Planner and the weather card all reuse a single
//  location fix and a single network response, refreshed every 15 minutes.
//

import CoreLocation
import Foundation
import MapKit

final class OpenMeteoWeatherProvider: WeatherProvider {

    static let shared = OpenMeteoWeatherProvider()

    private let locationManager = LocationManager()
    private let service = WeatherService()

    /// Open-Meteo allows up to 16; the Planner shows 7.
    private let forecastDays = 7
    private let maxAge: TimeInterval = 15 * 60

    private var cached: (response: WeatherResponse, city: String, fetchedAt: Date)?
    private var inFlight: Task<(response: WeatherResponse, city: String), Error>?

    /// The raw response, for views (like WeatherCardView) that want every field.
    func response() async throws -> WeatherResponse {
        try await load().response
    }

    func current() async throws -> WeatherSnapshot {
        let (response, city) = try await load()
        let condition = WeatherCondition(code: response.current.weatherCode)
        return WeatherSnapshot(
            city: city,
            condition: condition.description,
            temperature: Int(response.current.temperature.rounded()),
            feelsLike: Int(response.current.feelsLike.rounded()),
            symbol: condition.emoji
        )
    }

    func forecast(days: Int) async throws -> [DayForecast] {
        let daily = try await load().response.daily

        let parser = DateFormatter()
        parser.calendar = Calendar.current
        parser.timeZone = Calendar.current.timeZone
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd"

        let count = min(days, daily.dates.count, daily.highs.count, daily.weatherCodes.count)
        return (0..<count).compactMap { i in
            guard let date = parser.date(from: daily.dates[i]) else { return nil }
            return DayForecast(
                date: Calendar.current.startOfDay(for: date),
                temperature: Int(daily.highs[i].rounded()),
                shortCondition: WeatherCondition(code: daily.weatherCodes[i]).short
            )
        }
    }

    // MARK: Loading

    private func load() async throws -> (response: WeatherResponse, city: String) {
        if let cached, Date.now.timeIntervalSince(cached.fetchedAt) < maxAge {
            return (cached.response, cached.city)
        }
        if let inFlight {
            return try await inFlight.value
        }

        let task = Task { () throws -> (response: WeatherResponse, city: String) in
            let coordinate = try await locationManager.currentCoordinate()
            async let response = service.fetchWeather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                days: forecastDays
            )
            async let city = Self.cityName(for: coordinate)
            return try await (response, city)
        }
        inFlight = task
        defer { inFlight = nil }

        let result = try await task.value
        cached = (result.response, result.city, .now)
        return result
    }

    /// Best-effort place name; weather still shows if this fails.
    private static func cityName(for coordinate: CLLocationCoordinate2D) async -> String {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let request = MKReverseGeocodingRequest(location: location),
              let item = try? await request.mapItems.first,
              let city = item.addressRepresentations?.cityName
        else { return "Your location" }
        return city
    }
}
