//
//  PreviewSupport.swift
//  Vestiaire
//
//  An in-memory container seeded with sample data, used only by #Preview blocks.
//  The real app starts with an empty wardrobe (categories seeded, no items); this
//  lets the Xcode canvas show the grid populated.
//
//  NOTE: Wrap this file in a `#if DEBUG ... #endif` if you don't want sample data
//  compiled into release builds.
//

import Foundation
import SwiftData

@MainActor
enum PreviewData {
    /// In-memory container with the 8 default categories plus a few sample garments.
    static let container: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: ClothingItem.self, Category.self, Outfit.self, OutfitPlacement.self,
                configurations: config
            )
            let context = container.mainContext

            // Seed categories, then grab them by name to attach to sample items.
            Category.seedDefaultsIfNeeded(in: context)
            let categories = (try? context.fetch(FetchDescriptor<Category>())) ?? []
            func category(_ name: String) -> Category? { categories.first { $0.name == name } }

            let samples: [ClothingItem] = [
                ClothingItem(name: "Wool Overcoat",   category: category("Outerwear"),
                             cost: 320, season: .winter, fabric: "Wool",   timesWorn: 100),
                ClothingItem(name: "Linen Shirt",     category: category("Tops"),
                             cost: 74,  season: .summer, fabric: "Linen",  timesWorn: 40),
                ClothingItem(name: "Selvedge Denim",  category: category("Bottoms"),
                             cost: 190, season: .allSeason, fabric: "Cotton", timesWorn: 200),
                ClothingItem(name: "Leather Loafers", category: category("Shoes"),
                             cost: 240, season: .allSeason, fabric: "Leather", timesWorn: 100),
                ClothingItem(name: "Cashmere Scarf",  category: category("Accessories"),
                             cost: 123, season: .winter, fabric: "Cashmere", timesWorn: 30),
                ClothingItem(name: "Silk Slip Dress", category: category("Dresses"),
                             cost: 160, season: .summer, fabric: "Silk",   timesWorn: 0),
                ClothingItem(name: "Camel Trench",    category: category("Wish List"),
                             cost: 0,   season: .allSeason, fabric: "Cotton-gabardine"),
            ]
            samples.forEach { context.insert($0) }
            try? context.save()

            return container
        } catch {
            fatalError("Failed to create the preview ModelContainer: \(error)")
        }
    }()
}
