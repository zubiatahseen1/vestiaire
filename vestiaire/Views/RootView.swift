//
//  ContentView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-05-29.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @AppStorage("userName") private var userName = ""
    var body: some View {
        if userName.isEmpty {
            WelcomeView();
        } else {
            MainTabView()
        }
    }
}

#Preview {
   RootView()
        .modelContainer(PreviewData.container)
}
