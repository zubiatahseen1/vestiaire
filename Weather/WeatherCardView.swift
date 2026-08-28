import SwiftUI

struct WeatherCardView: View {
    @State private var viewModel = WeatherViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TODAY")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.32)
                .foregroundStyle(Color(.camel))

            if let weather = viewModel.weather {
                content(for: weather)
            } else if let message = viewModel.errorMessage {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.stone))
                Button("Try Again") {
                    Task { await viewModel.load() }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.camel))
            } else {
                ProgressView()
                    .tint(Color(.camel))
                    .frame(maxWidth: .infinity, minHeight: 60)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.ink).opacity(0.05), radius: 3, x: 0, y: 2)
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private func content(for weather: WeatherResponse) -> some View {
        let condition = WeatherCondition(code: weather.current.weatherCode)

        HStack(spacing: 14) {
            Image(systemName: condition.symbol)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Color(.camel))
                .frame(width: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(Int(weather.current.temperature.rounded()))°")
                    .font(.system(size: 34, weight: .medium, design: .serif))
                    .foregroundStyle(Color(.ink))
                Text("\(condition.description) · Feels like \(Int(weather.current.feelsLike.rounded()))°")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(.stone))
            }

            Spacer(minLength: 0)

            if let high = weather.daily.highs.first, let low = weather.daily.lows.first {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("H \(Int(high.rounded()))°  L \(Int(low.rounded()))°")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(.ink))
                    Text("Rain \(weather.todayRainChance)%")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.stone))
                }
            }
        }

        Rectangle()
            .fill(Color(.linen))
            .frame(height: 1)

        Label(weather.outfitHint, systemImage: "tshirt")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color(.ink))

        Link("Weather data by Open-Meteo", destination: URL(string: "https://open-meteo.com")!)
            .font(.system(size: 10))
            .foregroundStyle(Color(.stone))
    }
}

#Preview {
    ZStack {
        Color(.ivory).ignoresSafeArea()
        WeatherCardView()
            .padding(24)
    }
}
