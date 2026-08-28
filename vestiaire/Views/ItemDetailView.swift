//
//  ItemDetailView.swift
//  vestiaire
//
//  Built from Figma "02 Item Detail" (node 2:2).
//  Layout, spacing and type sizes come straight from that frame; colours resolve
//  through the asset catalog (Ink #1E1B18, Ivory #F7F3ED, Linen #ECE6DD,
//  Stone #8E867B, Camel #B08257).
//

import SwiftUI
import SwiftData
import UIKit

struct ItemDetailView: View {

    let item: ClothingItem

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showingEdit = false

    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()

            VStack(spacing: 0) {
                nav
                hero
                details
                stats
                Spacer(minLength: 0)
                wearButton
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEdit) {
            AddItemView(item: item)
        }
    }

    // MARK: Nav

    private var nav: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("← Back")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.ink))
            }

            Spacer()

            Button {
                showingEdit = true
            } label: {
                Text("Edit")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color(.camel))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    // MARK: Hero photo

    private var hero: some View {
        // The photo goes in an .overlay, not a ZStack: a .scaledToFill image
        // reports its full scaled width during layout, which would stretch the
        // whole screen sideways. An overlay is sized by its parent, so it can't.
        Color(.linen)
            .frame(height: 360)
            .frame(maxWidth: .infinity)
            .overlay {
                if let data = item.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Color(.stone))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)
            .padding(.top, 8)
    }

    // MARK: Details

    private var details: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text((item.category?.name ?? "Uncategorized").uppercased())
                .font(.system(size: 11, weight: .medium))
                .tracking(1.32)
                .foregroundStyle(Color(.camel))

            Text(item.name)
                .font(.system(size: 28, weight: .medium, design: .serif))
                .foregroundStyle(Color(.ink))

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color(.stone))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    /// "Charcoal · Winter", or just the season when no colour was recorded.
    private var subtitle: String {
        let colour = item.color.trimmingCharacters(in: .whitespaces)
        return colour.isEmpty ? item.season.rawValue : "\(colour) · \(item.season.rawValue)"
    }

    // MARK: Stats

    private var stats: some View {
        HStack(spacing: 16) {
            StatTile(value: money(item.cost), label: "COST")
            StatTile(value: "\(item.timesWorn)", label: "WEARS")
            StatTile(value: perWearText, label: "PER WEAR", isAccent: item.costPerWear != nil)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    /// Wish-list pieces and never-worn pieces have no meaningful cost per wear.
    /// Always two decimals here — "$8.00" reads as a rate, "$8" reads as a price.
    private var perWearText: String {
        guard let cpw = item.costPerWear else { return "—" }
        return String(format: "$%.2f", cpw)
    }

    /// "$320" for whole amounts, "$3.20" otherwise — matches the design.
    private func money(_ value: Double) -> String {
        value == value.rounded()
            ? String(format: "$%.0f", value)
            : String(format: "$%.2f", value)
    }

    // MARK: Wear button

    private var wearButton: some View {
        Button {
            wearToday()
        } label: {
            Text(item.isWishList ? "On your wish list" : "Wearing this today")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.ivory))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.ink))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(item.isWishList)
        .opacity(item.isWishList ? 0.4 : 1)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private func wearToday() {
        withAnimation { item.timesWorn += 1 }
        try? context.save()
    }
}

// MARK: - Stat tile

private struct StatTile: View {
    let value: String
    let label: String
    var isAccent: Bool = false

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(isAccent ? Color(.camel) : Color(.ink))
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .tracking(1)
                .foregroundStyle(Color(.stone))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.ink).opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    ItemDetailPreview()
        .modelContainer(PreviewData.container)
}

private struct ItemDetailPreview: View {
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var items: [ClothingItem]

    var body: some View {
        NavigationStack {
            if let item = items.first(where: { $0.timesWorn > 0 }) ?? items.first {
                ItemDetailView(item: item)
            } else {
                Text("No sample items")
            }
        }
    }
}
