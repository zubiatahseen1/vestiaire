//
//  AddItemView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-07-03.
//

import SwiftUI
import SwiftData

struct AddItemView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var color = ""
    @State private var season: Season = .allSeason
    @State private var fabric = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("NAME") {
                    TextField("e.g.Linen Shirt", text: $name)
                }

                Section("COLOR") {
                    TextField("Select", text: $color)
                }
                Section("SEASON") {
                    Picker("Season", selection: $season){
                        ForEach(Season.allCases){
                            season in Text(season.rawValue).tag(season)
                        }
                    }
                    .labelsHidden()
                }
                Section("FABRIC") {
                    TextField("e.g.Linen", text: $fabric)
                }


                Section("NOTES") {
                    TextField("Dry clean only, gift from mom...", text: $notes)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("New Piece")
                        .font(.system(size: 16))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        addItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                }


            }

        }
    }
   private func addItem(){
       let newItem = ClothingItem(name: name, color: color, season: season, fabric: fabric, notes: notes)
       modelContext.insert(newItem)
       dismiss()
    }



}


#Preview {
    AddItemView()
}
