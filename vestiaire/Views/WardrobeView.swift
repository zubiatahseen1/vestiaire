

import SwiftUI
import SwiftData
import UIKit

// MARK: - Wardrobe View

struct WardrobeView: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \ClothingItem.dateAdded, order: .reverse) private var items: [ClothingItem]

    @State private var selectedCategoryID: PersistentIdentifier?
    @State private var searchText = ""
    @State private var showingSearch = false

    @State private var showingAddItem = false


    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var filteredItems: [ClothingItem] {

        items.filter { item in
            let matchesCategory = selectedCategoryID == nil || selectedCategoryID == item.category?.persistentModelID
            let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            content
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: ClothingItem.self) { item in
                    ItemDetailView(item: item)
                }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView()
        }
    }

    private var content: some View {

        ZStack(alignment: .bottomTrailing) {
            Color(.ivory).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                if showingSearch { searchField }
                chipRow

                ScrollView(showsIndicators: false) {
                    if filteredItems.isEmpty {
                        emptyState
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems) { item in
                                NavigationLink(value: item) {
                                    ItemCard(item: item)
                                }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            delete(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                        .padding(.bottom, 96)   // room behind the FAB
                    }
                }
            }

            fab
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("GOOD MORNING")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.32)
                .foregroundStyle(Color(.camel))

            HStack(alignment: .center) {
                Text("Wardrobe")
                    .font(.system(size: 34, weight: .medium, design: .serif))
                    .foregroundStyle(Color(.ink))

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showingSearch.toggle() }
                    if !showingSearch { searchText = "" }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color(.ink))
                        .frame(width: 40, height: 40)
                        .background(Color(.linen))
                        .clipShape(Circle())
                }
            }

            // "feels like 18°" is a placeholder until the weather layer (week 8).
            Text("\(items.count) \(items.count == 1 ? "piece" : "pieces") · feels like 18°")
                .font(.system(size: 14))
                .foregroundStyle(Color(.stone))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(Color(.stone))
            TextField("Search your wardrobe", text: $searchText)
                .font(.system(size: 14))
                .foregroundStyle(Color(.ink))
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.linen))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: Chips

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipView(label: "All", isSelected: selectedCategoryID == nil, isWishList: false)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedCategoryID = nil }
                    }

                ForEach(categories) { category in
                    ChipView(
                        label: category.isWishList ? "♡ \(category.name)" : category.name,
                        isSelected: selectedCategoryID == category.persistentModelID,
                        isWishList: category.isWishList
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedCategoryID = category.persistentModelID
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 16)
    }

    // MARK: Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "hanger")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color(.stone))
            Text(searchText.isEmpty ? "Nothing here yet" : "No matches")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.ink))
            Text(searchText.isEmpty
                 ? "Tap the + to add your first piece."
                 : "Try a different search or category.")
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
            showingAddItem = true
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

    private func delete(_ item: ClothingItem) {
        withAnimation { context.delete(item) }
        try? context.save()
    }

    /// Inserts a quick dummy garment so you can verify save/load (week 2 goal).
    /// Drops it into the selected category, or the first non–wish-list default.
    private func addPlaceholderItem() {
        let target = categories.first { $0.persistentModelID == selectedCategoryID }
            ?? categories.first { !$0.isWishList }
        let item = ClothingItem(
            name: "New Item",
            category: target,
            cost: 0,
            season: .allSeason,
            timesWorn: 0
        )
        withAnimation { context.insert(item) }
        try? context.save()
    }
}

// MARK: - Chip

private struct ChipView: View {
    let label: String
    let isSelected: Bool
    let isWishList: Bool

    var body: some View {
        Text(label)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(background)
            .overlay(
                Capsule()
                    .stroke(Color(.camel), lineWidth: 1.5)
                    .opacity(isWishList && !isSelected ? 1 : 0)
            )
            .clipShape(Capsule())
    }

    private var foreground: Color {
        if isSelected { return Color(.ivory) }
        return isWishList ? Color(.camel) : Color(.ink)
    }

    private var background: Color {
        if isSelected { return Color(.ink) }
        return isWishList ? Color.clear : Color(.linen)
    }
}

// MARK: - Item Card

private struct ItemCard: View {
    let item: ClothingItem

    var body: some View {
        VStack(spacing: 0) {
            // Photo, or the ◯ placeholder from the design.
            ZStack {
                Color(.linen)
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
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12))

            // Meta: name, then "Category · stat"
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(.ink))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(item.category?.name ?? "Uncategorized")
                        .foregroundStyle(Color(.stone))
                    if let stat = item.statText {
                        Text("·").foregroundStyle(Color(.stone))
                        Text(stat)
                            .fontWeight(item.statIsAccent ? .medium : .regular)
                            .foregroundStyle(item.statIsAccent ? Color(.camel) : Color(.stone))
                    }
                }
                .font(.system(size: 12))
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(.ink).opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    WardrobeView()
        .modelContainer(PreviewData.container)
}
