//
//  VestiaireStore.swift
//  Vestiaire
//
//  The production SwiftData container. Building it here (rather than inline in the
//  App) keeps the schema in one place and lets the default categories seed as soon
//  as the store opens.
//

import Foundation
import SwiftData

@MainActor
enum VestiaireStore {

    static let schema = Schema([
        ClothingItem.self,
        Category.self,
        Outfit.self,
        OutfitPlacement.self,
        PlannedOutfit.self
    ])

    /// Shared, on-disk container for the whole app. Seeds the 8 default categories
    /// the first time it's created.
    ///
    /// If the existing store can't be opened — which happens while the schema is
    /// still changing during development — the old store is moved aside and a fresh
    /// one is created rather than crashing on launch. That costs the local data,
    /// but the alternative is an app that won't start at all. Revisit before this
    /// ever ships with real users' wardrobes in it.
    static let container: ModelContainer = {
        if let container = try? ModelContainer(for: schema) {
            Category.seedDefaultsIfNeeded(in: container.mainContext)
            return container
        }

        archiveExistingStore()

        do {
            let container = try ModelContainer(for: schema)
            Category.seedDefaultsIfNeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create the Vestiaire ModelContainer: \(error)")
        }
    }()

    /// Renames the store files out of the way so SwiftData starts clean next try.
    private static func archiveExistingStore() {
        let fileManager = FileManager.default
        let base = URL.applicationSupportDirectory
        let stamp = Int(Date.now.timeIntervalSince1970)

        for suffix in ["", "-shm", "-wal"] {
            let current = base.appending(path: "default.store\(suffix)")
            guard fileManager.fileExists(atPath: current.path) else { continue }
            let archived = base.appending(path: "default-\(stamp).store\(suffix).bak")
            try? fileManager.moveItem(at: current, to: archived)
        }
    }
}
