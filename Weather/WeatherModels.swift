import Foundation

// MARK: - Open-Meteo response

struct WeatherResponse: Decodable {
    let current: Current
    let daily: Daily

    struct Current: Decodable {
        let temperature: Double
        let feelsLike: Double
        let precipitation: Double
        let weatherCode: Int
        let windSpeed: Double

        enum CodingKeys: String, CodingKey {
            case temperature = "temperature_2m"
            case feelsLike = "apparent_temperature"
            case precipitation
            case weatherCode = "weather_code"
            case windSpeed = "wind_speed_10m"
        }
    }

    struct Daily: Decodable {
        let dates: [String]
        let highs: [Double]
        let lows: [Double]
        let rainChances: [Int?]
        let weatherCodes: [Int]

        enum CodingKeys: String, CodingKey {
            case dates = "time"
            case highs = "temperature_2m_max"
            case lows = "temperature_2m_min"
            case rainChances = "precipitation_probability_max"
            case weatherCodes = "weather_code"
        }
    }
}

// MARK: - Helpers for Vestiaire

extension WeatherResponse {
    var todayRainChance: Int {
        daily.rainChances.first.flatMap { $0 } ?? 0
    }

    
    var outfitHint: String {
        var hint: String
        switch current.feelsLike {
        case ..<(-10): hint = "Heavy winter coat, hat and gloves"
        case ..<0:     hint = "Winter coat and warm layers"
        case ..<10:    hint = "Jacket or warm sweater"
        case ..<18:    hint = "Light jacket or cardigan"
        case ..<25:    hint = "T-shirt weather"
        default:       hint = "Light, breathable clothes"
        }

        let condition = WeatherCondition(code: current.weatherCode)
        if condition.isSnowy {
            hint += " · wear boots"
        } else if todayRainChance >= 50 {
            hint += " · bring an umbrella"
        }
        return hint
    }
}

// MARK: - WMO weather code → text + SF Symbol

struct WeatherCondition {
    let code: Int

    var description: String {
        switch code {
        case 0: "Clear"
        case 1: "Mainly clear"
        case 2: "Partly cloudy"
        case 3: "Overcast"
        case 45, 48: "Fog"
        case 51, 53, 55: "Drizzle"
        case 56, 57: "Freezing drizzle"
        case 61, 63, 65: "Rain"
        case 66, 67: "Freezing rain"
        case 71, 73, 75, 77: "Snow"
        case 80, 81, 82: "Rain showers"
        case 85, 86: "Snow showers"
        case 95: "Thunderstorm"
        case 96, 99: "Thunderstorm with hail"
        default: "Unknown"
        }
    }

    var symbol: String {
        switch code {
        case 0: "sun.max.fill"
        case 1, 2: "cloud.sun.fill"
        case 3: "cloud.fill"
        case 45, 48: "cloud.fog.fill"
        case 51, 53, 55: "cloud.drizzle.fill"
        case 56, 57, 66, 67: "cloud.sleet.fill"
        case 61, 63: "cloud.rain.fill"
        case 65: "cloud.heavyrain.fill"
        case 71, 73, 75, 77, 85, 86: "cloud.snow.fill"
        case 80, 81, 82: "cloud.sun.rain.fill"
        case 95: "cloud.bolt.rain.fill"
        case 96, 99: "cloud.hail.fill"
        default: "questionmark.circle"
        }
    }

    var isSnowy: Bool {
        [71, 73, 75, 77, 85, 86].contains(code)
    }
}
