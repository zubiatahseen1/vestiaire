//
//  TodayView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-06-11.
//  Built from Figma "04 Today Suggestion" (node 4:2).
//
//  Readings come from a WeatherProvider (currently mocked). The suggestion is
//  driven by the *feels like* temperature rather than the actual one — the whole
//  point of the app.
//

import SwiftUI
import SwiftData
import UIKit

struct TodayView: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var items: [ClothingItem]

    private let provider: WeatherProvider

    @State private var weather: WeatherSnapshot?
    @State private var suggestion: [ClothingItem] = []
    @State private var loggedWear = false

    init(provider: WeatherProvider = MockWeatherProvider()) {
        self.provider = provider
    }

    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    weatherCard
                    suggestionHeader

                    if suggestion.isEmpty {
                        emptyState
                    } else {
                        outfitRow
                        actions
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .task {
            if weather == nil {
                weather = await provider.current()
                makeSuggestion()
            }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateLine)
                .font(.system(size: 11, weight: .medium))
                .tracking(1.32)
                .foregroundStyle(Color(.camel))

            Text("Today")
                .font(.system(size: 34, weight: .medium, design: .serif))
                .foregroundStyle(Color(.ink))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    /// "TUESDAY, JUNE 9"
    private var dateLine: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: .now).uppercased()
    }

    // MARK: Weather

    private var weatherCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(weather?.place ?? "Loading weather…")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(.mist))

                HStack(spacing: 8) {
                    Text(weather.map { "\($0.temperature)°" } ?? "—")
                        .font(.system(size: 36, weight: .medium, design: .serif))
                        .foregroundStyle(Color(.ivory))

                    if let feels = weather?.feelsLike {
                        Text("feels like \(feels)°")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.camel))
                    }
                }
            }

            Spacer(minLength: 0)

            Text(weather?.symbol ?? "")
                .font(.system(size: 36))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color(.ink))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: Suggestion

    private var suggestionHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Suggested for today")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(.ink))
            Text(reason)
                .font(.system(size: 13))
                .foregroundStyle(Color(.stone))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 12)
    }

    private var outfitRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(suggestion) { item in
                    pieceCard(item)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
        }
    }

    private func pieceCard(_ item: ClothingItem) -> some View {
        VStack(spacing: 0) {
            Color(.linen)
                .frame(width: 107, height: 110)
                .overlay {
                    if let data = item.photo, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(Color(.stone))
                    }
                }
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))

            Text(item.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(.ink))
                .lineLimit(1)
                .frame(width: 107, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
        .frame(width: 107)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.ink).opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button {
                wearThis()
            } label: {
                Text(loggedWear ? "Worn today ✓" : "Wear this")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.ivory))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.ink))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(loggedWear)
            .opacity(loggedWear ? 0.5 : 1)

            Button {
                withAnimation { makeSuggestion() }
            } label: {
                Text("↺")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(.ink))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(.linen))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "hanger")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color(.stone))
            Text("Nothing to suggest yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.ink))
            Text("Add a few pieces to your wardrobe and they'll show up here.")
                .font(.system(size: 14))
                .foregroundStyle(Color(.stone))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
        .padding(.horizontal, 40)
    }

    // MARK: Suggestion logic

    private var currentSeason: Season {
        switch Calendar.current.component(.month, from: .now) {
        case 3...5:   return .spring
        case 6...8:   return .summer
        case 9...11:  return .fall
        default:      return .winter
        }
    }

    /// The line under the heading, written from how it actually feels outside.
    private var reason: String {
        guard let feels = weather?.feelsLike else { return "Checking the weather…" }
        switch feels {
        case ..<0:   return "Bundle up — well below freezing"
        case 0..<8:  return "Layer properly — cold out there"
        case 8..<13: return "A warm layer — cool and brisk"
        case 13..<20: return "Light layers — mild with a breeze"
        case 20..<27: return "Keep it light — comfortably warm"
        default:     return "As cool as possible — it's hot"
        }
    }

    /// One piece per slot, weather first: outerwear only when it actually feels cold.
    private func makeSuggestion() {
        loggedWear = false

        let pool = items.filter { item in
            !item.isWishList && (item.season == .allSeason || item.season == currentSeason)
        }

        var slots = ["Tops", "Bottoms", "Shoes"]
        if let feels = weather?.feelsLike, feels < 13 {
            slots.insert("Outerwear", at: 0)
        }

        var picked = slots.compactMap { slot in
            pool.filter { $0.category?.name == slot }.randomElement()
        }

        // A young wardrobe may have nothing in those categories — show something.
        if picked.isEmpty {
            picked = Array(pool.shuffled().prefix(3))
        }

        suggestion = picked
    }

    private func wearThis() {
        for item in suggestion {
            item.timesWorn += 1
        }
        try? context.save()
        withAnimation { loggedWear = true }
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .modelContainer(PreviewData.container)
}
