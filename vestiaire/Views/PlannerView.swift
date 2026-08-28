

import SwiftUI
import SwiftData

struct PlannerView: View {

    @Environment(\.modelContext) private var context

    @Query private var plans: [PlannedOutfit]
    @Query(sort: \Outfit.dateCreated, order: .reverse) private var outfits: [Outfit]

    private let provider: WeatherProvider
    private let dayCount = 7

    @State private var forecast: [Date: DayForecast] = [:]

    private struct PlannedDay: Identifiable {
        let date: Date
        var id: Date { date }
    }

    @State private var pickingDay: PlannedDay?

    init(provider: WeatherProvider = MockWeatherProvider()) {
        self.provider = provider
    }

    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<dayCount).compactMap {
            calendar.date(byAdding: .day, value: $0, to: today)
        }
    }

    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView(showsIndicators: false) {
                    WeatherCardView()
                    VStack(spacing: 12) {
                        ForEach(days, id: \.self) { day in
                            DayRow(
                                date: day,
                                outfit: plannedOutfit(on: day),
                                weather: forecast[day]?.line
                            )
                            .onTapGesture { pickingDay = PlannedDay(date: day) }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .task {
            let upcoming = await provider.forecast(days: dayCount)
            forecast = Dictionary(uniqueKeysWithValues: upcoming.map { ($0.date, $0) })
            tidyOrphanedPlans()
        }
        .sheet(item: $pickingDay) { selection in
            OutfitPicker(
                date: selection.date,
                outfits: outfits,
                current: plannedOutfit(on: selection.date),
                onPick: { plan(day: selection.date, outfit: $0) },
                onClear: { clear(day: selection.date) }
            )
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("THIS WEEK")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.32)
                .foregroundStyle(Color(.camel))

            Text("Planner")
                .font(.system(size: 34, weight: .medium, design: .serif))
                .foregroundStyle(Color(.ink))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: Data

    private func plannedOutfit(on day: Date) -> Outfit? {
        plans.first { Calendar.current.isDate($0.date, inSameDayAs: day) }?.outfit
    }

    private func plan(day: Date, outfit: Outfit) {
        let start = Calendar.current.startOfDay(for: day)
        if let existing = plans.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            existing.outfit = outfit
        } else {
            context.insert(PlannedOutfit(date: start, outfit: outfit))
        }
        try? context.save()
        pickingDay = nil
    }

    private func clear(day: Date) {
        for plan in plans where Calendar.current.isDate(plan.date, inSameDayAs: day) {
            context.delete(plan)
        }
        try? context.save()
        pickingDay = nil
    }

    
    private func tidyOrphanedPlans() {
        let orphans = plans.filter { $0.outfit == nil }
        guard !orphans.isEmpty else { return }
        orphans.forEach { context.delete($0) }
        try? context.save()
    }
}

// MARK: - Day row

private struct DayRow: View {
    let date: Date
    let outfit: Outfit?
    let weather: String?

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.ink))
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.stone))
            }
            .frame(width: 48, height: 44)

            Rectangle()
                .fill(Color(.linen))
                .frame(width: 1, height: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(outfit?.name ?? "— plan an outfit")
                    .font(.system(size: 14, weight: outfit == nil ? .regular : .medium))
                    .foregroundStyle(outfit == nil ? Color(.stone) : Color(.ink))
                    .lineLimit(1)

                if let weather {
                    Text(weather)
                        .font(.system(size: 12))
                        .foregroundStyle(outfit == nil ? Color(.stone) : Color(.camel))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(outfit == nil ? "+" : "›")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(outfit == nil ? Color(.camel) : Color(.stone))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.ink).opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Outfit picker

private struct OutfitPicker: View {
    let date: Date
    let outfits: [Outfit]
    let current: Outfit?
    let onPick: (Outfit) -> Void
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(.stone))
                    Spacer()
                    Text(date.formatted(.dateTime.weekday(.wide).month().day()))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(.ink))
                    Spacer()
                    Color.clear.frame(width: 50)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                if outfits.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(Color(.stone))
                        Text("No outfits yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.ink))
                        Text("Put a look together on the Outfits tab first.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.stone))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 64)
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(outfits) { outfit in
                                row(outfit)
                                    .onTapGesture { onPick(outfit) }
                            }

                            if current != nil {
                                Button {
                                    onClear()
                                } label: {
                                    Text("Remove from this day")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color(.stone))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(.linen))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }

    private func row(_ outfit: Outfit) -> some View {
        let isCurrent = outfit.persistentModelID == current?.persistentModelID
        let count = outfit.placements.count

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(outfit.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(.ink))
                Text("\(count) \(count == 1 ? "piece" : "pieces") · \(outfit.season.rawValue)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.stone))
            }
            Spacer(minLength: 0)
            if isCurrent {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(.camel))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.camel), lineWidth: 2)
                .opacity(isCurrent ? 1 : 0)
        )
        .shadow(color: Color(.ink).opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    PlannerView()
        .modelContainer(PreviewData.container)
}
