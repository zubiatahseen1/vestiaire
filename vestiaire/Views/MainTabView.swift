//
//  WardrobeView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-06-10.
//

//  MainTabView.swift

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            WardrobeView()
                .tabItem { Label("Wardrobe", systemImage: "square.grid.2x2") }

            OutfitsView()
                .tabItem { Label("Outfits", systemImage: "rectangle.stack") }

            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
        }
        .tint(Color(.ink))
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.container)
}
