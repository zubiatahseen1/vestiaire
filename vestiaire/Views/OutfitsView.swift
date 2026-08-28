//
//  OutfitsView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-06-11.
//  Built from Figma "06 Outfits" (node 8:19).
//

import SwiftUI
import SwiftData
import UIKit

struct OutfitsView: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \Outfit.dateCreated, order: .reverse) private var outfits: [Outfit]

    @State private var showingBuilder = false
    @State private var editingOutfit: Outfit?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color(.ivory).ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView(showsIndicators: false) {
                        if outfits.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 16) {
                                ForEach(outfits) { outfit in
                                    OutfitCard(outfit: outfit)
                                        .onTapGesture { editingOutfit = outfit }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                delete(outfit)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                            .padding(.bottom, 96)   // room behind the FAB
                        }
                    }
                }

                fab
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showingBuilder) {
            OutfitBuilderView()
        }
        .sheet(item: $editingOutfit) { outfit in
            OutfitBuilderView(outfit: outfit)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("YOUR COMBINATIONS")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.32)
                .foregroundStyle(Color(.camel))

            Text("Outfits")
                .font(.system(size: 34, weight: .medium, design: .serif))
                .foregroundStyle(Color(.ink))

            Text("\(outfits.count) saved \(outfits.count == 1 ? "outfit" : "outfits")")
                .font(.system(size: 14))
                .foregroundStyle(Color(.stone))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color(.stone))
            Text("No outfits yet")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.ink))
            Text("Tap the + to put a look together.")
                .font(.system(size: 14))
                .foregroundStyle(Color(.stone))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 40)
    }

    // MARK: FAB

    private var fab: some View {
        Button {
            showingBuilder = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color(.ivory))
                .frame(width: 56, height: 56)
                .background(Color(.camel))
                .clipShape(Circle())
                .shadow(color: Color(.camel).opacity(0.35), radius: 6, x: 0, y: 4)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 16)
    }

    // MARK: Actions

    private func delete(_ outfit: Outfit) {
        withAnimation { context.delete(outfit) }
        try? context.save()
    }
}

// MARK: - Outfit card

private struct OutfitCard: View {
    let outfit: Outfit

    /// Up to four thumbnails, in the order they're stacked on the canvas.
    private var thumbnails: [OutfitPlacement] {
        Array(outfit.placements.sorted { $0.zIndex < $1.zIndex }.prefix(4))
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(thumbnails) { placement in
                    Color(.linen)
                        .frame(width: 72, height: 72)
                        .overlay {
                            if let data = placement.item?.photo,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 18, weight: .light))
                                    .foregroundStyle(Color(.stone))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(outfit.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(.ink))
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.stone))
                }

                Spacer(minLength: 0)

                Text("›")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(.stone))
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.ink).opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var subtitle: String {
        let count = outfit.placements.count
        return "\(count) \(count == 1 ? "piece" : "pieces") · \(outfit.season.rawValue)"
    }
}

// MARK: - Preview

#Preview {
    OutfitsView()
        .modelContainer(PreviewData.container)
}
