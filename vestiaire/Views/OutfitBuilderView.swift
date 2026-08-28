//
//  OutfitBuilderView.swift
//  vestiaire
//
//  Built from Figma "07 Outfit Builder" (node 8:83).
//
//  Pieces are arranged on a free canvas. Two decisions worth knowing:
//
//  • Placement x/y are stored NORMALISED (0...1) as a fraction of the canvas,
//    not as absolute points. Same Double columns, so no schema change — but an
//    outfit now looks the same on any screen width instead of drifting.
//  • Nothing is written to SwiftData until Save, so cancelling leaves no debris.
//    Pieces live in a local `Placed` array while you're arranging them.
//

import SwiftUI
import SwiftData
import UIKit

struct OutfitBuilderView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var items: [ClothingItem]

    /// nil when creating, set when editing an existing outfit.
    private let existingOutfit: Outfit?

    /// One piece on the canvas while it's being arranged.
    private struct Placed: Identifiable {
        let id = UUID()
        let item: ClothingItem
        var x: Double          // 0...1 across the canvas
        var y: Double          // 0...1 down the canvas
        var zIndex: Int
    }

    @State private var placed: [Placed] = []
    @State private var selectedCategoryID: PersistentIdentifier?
    @State private var dragging: (id: UUID, translation: CGSize)?
    @State private var showingNamePrompt = false
    @State private var outfitName = ""

    private let canvasHeight: CGFloat = 440

    init(outfit: Outfit? = nil) {
        existingOutfit = outfit
        _outfitName = State(initialValue: outfit?.name ?? "")
    }

    private var isEditing: Bool { existingOutfit != nil }

    /// Wish-list pieces can't be worn, so they're not offered here.
    private var pickableCategories: [Category] {
        categories.filter { !$0.isWishList }
    }

    private var carouselItems: [ClothingItem] {
        items.filter { item in
            guard !item.isWishList else { return false }
            guard let selected = selectedCategoryID else { return true }
            return item.category?.persistentModelID == selected
        }
    }

    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()

            VStack(spacing: 0) {
                nav
                canvas
                chips
                carousel
                Spacer(minLength: 0)
            }
        }
        .task { loadExistingPlacements() }
        .alert("Name this outfit", isPresented: $showingNamePrompt) {
            TextField("e.g. Office Monochrome", text: $outfitName)
            Button("Cancel", role: .cancel) { }
            Button("Save") { commit() }
        }
    }

    // MARK: Nav

    private var nav: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(.stone))

            Spacer()

            Text(isEditing ? "Edit Outfit" : "New Outfit")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.ink))

            Spacer()

            Button("Save") { showingNamePrompt = true }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(.camel))
                .disabled(placed.isEmpty)
                .opacity(placed.isEmpty ? 0.4 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    // MARK: Canvas

    private var canvas: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(placed) { piece in
                    placedView(piece, in: geo.size)
                }

                Text("Drag to arrange · add as many pieces as you like")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(.stone))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 20)
                    .allowsHitTesting(false)
            }
        }
        .frame(height: canvasHeight)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color(.linen), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        )
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private func placedView(_ piece: Placed, in size: CGSize) -> some View {
        let dimensions = pieceSize(for: piece.item)

        return Color(.linen)
            .frame(width: dimensions.width, height: dimensions.height)
            .overlay {
                if let data = piece.item.photo, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Color(.stone))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color(.ink).opacity(0.12), radius: 4, x: 0, y: 3)
            .rotationEffect(.degrees(tilt(for: piece)))
            .position(point(for: piece, in: size))
            .zIndex(Double(piece.zIndex))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragging = (piece.id, value.translation)
                    }
                    .onEnded { value in
                        dragging = nil
                        commitDrag(piece, translation: value.translation, in: size)
                    }
            )
            .onLongPressGesture { remove(piece) }
    }

    private func point(for piece: Placed, in size: CGSize) -> CGPoint {
        var p = CGPoint(x: piece.x * size.width, y: piece.y * size.height)
        if let drag = dragging, drag.id == piece.id {
            p.x += drag.translation.width
            p.y += drag.translation.height
        }
        return p
    }

    private func commitDrag(_ piece: Placed, translation: CGSize, in size: CGSize) {
        guard let index = placed.firstIndex(where: { $0.id == piece.id }),
              size.width > 0, size.height > 0 else { return }
        let newX = (piece.x * size.width + translation.width) / size.width
        let newY = (piece.y * size.height + translation.height) / size.height
        placed[index].x = min(max(newX, 0.08), 0.92)
        placed[index].y = min(max(newY, 0.08), 0.88)
        placed[index].zIndex = (placed.map(\.zIndex).max() ?? 0) + 1   // dragged piece comes forward
    }

    /// Small, stable tilt so the canvas feels hand-arranged like the design.
    private func tilt(for piece: Placed) -> Double {
        let angles: [Double] = [4, -5, -2, 6, -3, 2]
        return angles[abs(piece.id.hashValue % angles.count)]
    }

    /// Shoes, bags and accessories read smaller than garments — as in the design.
    private func pieceSize(for item: ClothingItem) -> CGSize {
        switch item.category?.name {
        case "Shoes", "Bags", "Accessories": return CGSize(width: 90, height: 90)
        case "Dresses", "Outerwear":         return CGSize(width: 120, height: 160)
        default:                             return CGSize(width: 130, height: 150)
        }
    }

    // MARK: Chips

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(label: "All", isSelected: selectedCategoryID == nil) {
                    selectedCategoryID = nil
                }
                ForEach(pickableCategories) { category in
                    chip(label: category.name,
                         isSelected: selectedCategoryID == category.persistentModelID) {
                        selectedCategoryID = category.persistentModelID
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func chip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? Color(.ivory) : Color(.ink))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(.ink) : Color(.linen))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: Carousel

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(carouselItems) { item in
                    carouselCard(item)
                        .onTapGesture { add(item) }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 4)
        }
        .padding(.bottom, 16)
    }

    private func carouselCard(_ item: ClothingItem) -> some View {
        let isOnCanvas = placed.contains { $0.item.persistentModelID == item.persistentModelID }

        return VStack(spacing: 0) {
            Color(.linen)
                .frame(width: 96, height: 96)
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
                .frame(width: 96, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
        }
        .frame(width: 96)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.camel), lineWidth: 2)
                .opacity(isOnCanvas ? 1 : 0)
        )
        .shadow(color: Color(.ink).opacity(0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: Canvas actions

    private func add(_ item: ClothingItem) {
        // Stagger each new piece so they don't land on top of one another.
        let step = placed.count
        placed.append(Placed(
            item: item,
            x: 0.34 + Double(step % 3) * 0.16,
            y: 0.26 + Double((step / 3) % 3) * 0.22,
            zIndex: (placed.map(\.zIndex).max() ?? 0) + 1
        ))
    }

    private func remove(_ piece: Placed) {
        withAnimation { placed.removeAll { $0.id == piece.id } }
    }

    // MARK: Load & save

    private func loadExistingPlacements() {
        guard let outfit = existingOutfit, placed.isEmpty else { return }
        placed = outfit.placements
            .sorted { $0.zIndex < $1.zIndex }
            .compactMap { placement in
                guard let item = placement.item else { return nil }
                return Placed(item: item, x: placement.x, y: placement.y, zIndex: placement.zIndex)
            }
    }

    private func commit() {
        let name = outfitName.trimmingCharacters(in: .whitespaces)
        let finalName = name.isEmpty ? "Untitled Outfit" : name
        let season = derivedSeason()

        if let outfit = existingOutfit {
            outfit.name = finalName
            outfit.season = season
            // .cascade removes the replaced placements; deleting them explicitly
            // as well double-frees them.
            outfit.placements = placed.map {
                OutfitPlacement(item: $0.item, x: $0.x, y: $0.y, zIndex: $0.zIndex)
            }
        } else {
            let outfit = Outfit(name: finalName, season: season)
            outfit.placements = placed.map {
                OutfitPlacement(item: $0.item, x: $0.x, y: $0.y, zIndex: $0.zIndex)
            }
            context.insert(outfit)
        }

        try? context.save()
        dismiss()
    }

    /// If every piece shares one season, the outfit takes it; otherwise all-season.
    private func derivedSeason() -> Season {
        let seasons = Set(placed.map(\.item.season)).subtracting([.allSeason])
        return seasons.count == 1 ? seasons.first! : .allSeason
    }
}

// MARK: - Preview

#Preview {
    OutfitBuilderView()
        .modelContainer(PreviewData.container)
}
