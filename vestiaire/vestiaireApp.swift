//
//  vestiaireApp.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-05-29.
//

import SwiftUI
import SwiftData

@main
struct vestiaireApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        .modelContainer(VestiaireStore.container)
    }
}
