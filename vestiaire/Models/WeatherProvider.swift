//
//  WeatherProvider.swift
//  Vestiaire
//
//  The weather layer, behind a protocol so the UI never knows where readings come
//  from. Today that's MockWeatherProvider; swapping in WeatherKit or OpenWeather
//  later means writing one more conformance and changing one line in TodayView —
//  no view code moves.
//

import Foundation

/// One reading, in the shape TodayView actually needs.
struct WeatherSnapshot {
    let city: String
    let condition: String
    let temperature: Int
    let feelsLike: Int
    let symbol: String        // emoji, as in the design

    /// "Toronto · Partly cloudy"
    var place: String { "\(city) · \(condition)" }
}

protocol WeatherProvider {
    func current() async -> WeatherSnapshot
}

/// Stand-in readings until a real API is wired up. Deterministic per calendar day,
/// so the screen doesn't flicker between different weather on every redraw, but
/// still changes day to day rather than looking frozen.
struct MockWeatherProvider: WeatherProvider {

    var city = "Toronto"

    private static let conditions: [(String, String)] = [
        ("Clear", "☀️"),
        ("Partly cloudy", "⛅"),
        ("Cloudy", "☁️"),
        ("Light rain", "🌦️"),
        ("Windy", "💨")
    ]

    func current() async -> WeatherSnapshot {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 1
        let (condition, symbol) = Self.conditions[day % Self.conditions.count]

        // A rough seasonal curve for Toronto: coldest in January, warmest in July.
        let seasonal = -9.0 * cos(2 * .pi * Double(day) / 365.0)
        let base = Int((11 + seasonal).rounded())
        let temperature = base + (day % 5) - 2
        let feelsLike = temperature - (condition == "Windy" ? 4 : 2)

        return WeatherSnapshot(
            city: city,
            condition: condition,
            temperature: temperature,
            feelsLike: feelsLike,
            symbol: symbol
        )
    }
}
