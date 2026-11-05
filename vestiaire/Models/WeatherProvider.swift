//
//  WeatherProvider.swift
//  Vestiaire
//
//  The weather layer, behind a protocol so the UI never knows where readings come
//  from. The app uses OpenMeteoWeatherProvider (live, location-based); the mock
//  stays for previews and tests.
//

import Foundation

/// Today's reading, in the shape TodayView needs.
struct WeatherSnapshot {
    let city: String
    let condition: String
    let temperature: Int
    let feelsLike: Int
    let symbol: String        // emoji, as in the design

    /// "Toronto · Partly cloudy"
    var place: String { "\(city) · \(condition)" }
}

/// One upcoming day, in the shape PlannerView needs.
struct DayForecast: Identifiable {
    let date: Date            // always start-of-day
    let temperature: Int
    let shortCondition: String   // "sun", "cloud", "rain", "wind"

    var id: Date { date }

    /// "19° · sun"
    var line: String { "\(temperature)° · \(shortCondition)" }
}

protocol WeatherProvider {
    func current() async throws -> WeatherSnapshot
    func forecast(days: Int) async throws -> [DayForecast]
}

/// Stand-in readings for previews and tests. Deterministic per calendar day,
/// so the screen doesn't flicker between different weather on every redraw, but
/// still changes day to day rather than looking frozen.
struct MockWeatherProvider: WeatherProvider {

    var city = "Toronto"

    private static let conditions: [(name: String, symbol: String, short: String)] = [
        ("Clear",         "☀️",  "sun"),
        ("Partly cloudy", "⛅",  "cloud"),
        ("Cloudy",        "☁️",  "cloud"),
        ("Light rain",    "🌦️", "rain"),
        ("Windy",         "💨",  "wind")
    ]

    /// A rough seasonal curve for Toronto: coldest in January, warmest in July.
    private func reading(dayOfYear day: Int) -> (temp: Int, feels: Int, index: Int) {
        let seasonal = -9.0 * cos(2 * .pi * Double(day) / 365.0)
        let temperature = Int((11 + seasonal).rounded()) + (day % 5) - 2
        let index = day % Self.conditions.count
        let feels = temperature - (Self.conditions[index].short == "wind" ? 4 : 2)
        return (temperature, feels, index)
    }

    private func dayOfYear(_ date: Date) -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
    }

    func current() async -> WeatherSnapshot {
        let r = reading(dayOfYear: dayOfYear(.now))
        let condition = Self.conditions[r.index]
        return WeatherSnapshot(
            city: city,
            condition: condition.name,
            temperature: r.temp,
            feelsLike: r.feels,
            symbol: condition.symbol
        )
    }

    func forecast(days: Int) async -> [DayForecast] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else {
                return nil
            }
            let r = reading(dayOfYear: dayOfYear(date))
            return DayForecast(
                date: date,
                temperature: r.temp,
                shortCondition: Self.conditions[r.index].short
            )
        }
    }
}
