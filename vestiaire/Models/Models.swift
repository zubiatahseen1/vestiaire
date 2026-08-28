
//  Models.swift
//  Vestiaire
//
//  The SwiftData layer:
//   • ClothingItem — name, category, color, cost, season, fabric, notes, photo,
//                    timesWorn, dateAdded  (wish-list behaviour derived from category)
//   • Category     — name, sortOrder, isDefault  (8 seeded defaults, user-editable later)
//   • Outfit       — name, season, dateCreated, placements [{item, x, y, zIndex}]


import Foundation
import SwiftData

// MARK: - Season

enum Season: String, Codable, CaseIterable, Identifiable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    case allSeason = "All-Season"

    var id: String { rawValue }
}

// MARK: - Category

@Model
final class Category {
    var name: String
    var sortOrder: Int
    var isDefault: Bool

    // Items in this category. Deleting a category nullifies the link rather than
    // deleting the garments.
    @Relationship(deleteRule: .nullify, inverse: \ClothingItem.category)
    var items: [ClothingItem] = []

    init(name: String, sortOrder: Int, isDefault: Bool = false) {
        self.name = name
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    /// Wishlistness is a property of the category, per the spec decision.
    var isWishList: Bool { name == Category.wishListName }
}

extension Category {
    static let wishListName = "Wish List"

    /// The 8 defaults, in display order. Wish List sorts last.
    static let defaultNames = [
        "Tops", "Bottoms", "Dresses", "Outerwear",
        "Shoes", "Bags", "Accessories", wishListName
    ]

    /// Inserts the 8 default categories the first time the app runs.
    @MainActor
    static func seedDefaultsIfNeeded(in context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
        guard existing == 0 else { return }
        for (index, name) in defaultNames.enumerated() {
            context.insert(Category(name: name, sortOrder: index, isDefault: true))
        }
        try? context.save()
    }
}

// MARK: - ClothingItem

@Model
final class ClothingItem {
    var name: String
    var category: Category?
    var color: String
    var cost: Double
    var season: Season
    var fabric: String
    var notes: String

    // Stored outside the database file so the store stays small.
    @Attribute(.externalStorage) var photo: Data?

    var timesWorn: Int
    var dateAdded: Date

    init(
        name: String,
        category: Category? = nil,
        color: String = "",
        cost: Double = 0,
        season: Season = .allSeason,
        fabric: String = "",
        notes: String = "",
        photo: Data? = nil,
        timesWorn: Int = 0,
        dateAdded: Date = .now
    ) {
        self.name = name
        self.category = category
        self.color = color
        self.cost = cost
        self.season = season
        self.fabric = fabric
        self.notes = notes
        self.photo = photo
        self.timesWorn = timesWorn
        self.dateAdded = dateAdded
    }
}

extension ClothingItem {
    var isWishList: Bool { category?.isWishList ?? false }


    var costPerWear: Double? {
        guard !isWishList, timesWorn > 0 else { return nil }
        return cost / Double(timesWorn)
    }


    var statText: String? {
        if isWishList { return nil }
        if let cpw = costPerWear { return String(format: "$%.2f/wear", cpw) }
        return "Not worn yet"
    }

 
    var statIsAccent: Bool { costPerWear != nil }
}

// MARK: - Outfit

@Model
final class Outfit {
    var name: String
    var season: Season
    var dateCreated: Date

    // Free-canvas placements. Deleting an outfit deletes its placements.
    @Relationship(deleteRule: .cascade)
    var placements: [OutfitPlacement] = []

    init(name: String, season: Season = .allSeason, dateCreated: Date = .now) {
        self.name = name
        self.season = season
        self.dateCreated = dateCreated
    }
}


@Model
final class OutfitPlacement {
    var x: Double
    var y: Double
    var zIndex: Int

    @Relationship(deleteRule: .nullify)
    var item: ClothingItem?

    init(item: ClothingItem? = nil, x: Double = 0, y: Double = 0, zIndex: Int = 0) {
        self.item = item
        self.x = x
        self.y = y
        self.zIndex = zIndex
    }
}
