//
//  TodayView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-06-11.
//

import SwiftUI

//  TodayView.swift
struct TodayView: View {
    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()
            Text("Today").font(.system(size: 34, design: .serif))
        }
    }
}
#Preview {
    TodayView()
}
