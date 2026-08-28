//
//  VestiaireStore.swift
//  Vestiaire
//
//  The production SwiftData container. Building it here (rather than inline in the
//  App) keeps the schema in one place and lets the default categories seed as soon
//  as the store opens.
//
//  Wire it into your App entry point:
//
//      @main
//      struct VestiaireApp: App {
//          var body: some Scene {
//              WindowGroup {
//                  RootTabView()           // your existing tab skeleton
//              }
//              .modelContainer(VestiaireStore.container)
//          }
//      }
//

import SwiftData

@MainActor
enum VestiaireStore {
    /// Shared, on-disk container for the whole app. Seeds the 8 default categories
    /// the first time it's created.
    static let container: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: ClothingItem.self, Category.self, Outfit.self, OutfitPlacement.self
            )
            Category.seedDefaultsIfNeeded(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create the Vestiaire ModelContainer: \(error)")
        }
    }()
}
