//
//  AddItemView.swift
//  vestiaire
//
//  Created by Zubia Tahseen on 2026-07-03.
//  Rebuilt from Figma "03 Add Item" (node 2:29).
//
//  Doubles as the edit form: pass an existing item and it loads that item's values
//  and saves back to it instead of inserting a new one.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddItemView: View {

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    /// nil when adding, set when editing.
    private let existingItem: ClothingItem?

    @State private var name: String
    @State private var colour: String
    @State private var costText: String
    @State private var season: Season
    @State private var fabric: String
    @State private var notes: String
    @State private var photoData: Data?
    @State private var selectedCategoryID: PersistentIdentifier?
    @State private var pickerItem: PhotosPickerItem?

    init(item: ClothingItem? = nil) {
        existingItem = item
        _name    = State(initialValue: item?.name ?? "")
        _colour  = State(initialValue: item?.color ?? "")
        _season  = State(initialValue: item?.season ?? .allSeason)
        _fabric  = State(initialValue: item?.fabric ?? "")
        _notes   = State(initialValue: item?.notes ?? "")
        _photoData = State(initialValue: item?.photo)
        _selectedCategoryID = State(initialValue: item?.category?.persistentModelID)

        if let cost = item?.cost, cost > 0 {
            _costText = State(initialValue: cost == cost.rounded()
                              ? String(format: "%.0f", cost)
                              : String(format: "%.2f", cost))
        } else {
            _costText = State(initialValue: "")
        }
    }

    private var isEditing: Bool { existingItem != nil }
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        ZStack {
            Color(.ivory).ignoresSafeArea()

            VStack(spacing: 0) {
                nav

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        photoButton
                        form
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        .task {
            // Default to the first real category so nothing lands as "Uncategorized".
            if selectedCategoryID == nil && !isEditing {
                selectedCategoryID = categories.first { !$0.isWishList }?.persistentModelID
            }
        }
        .onChange(of: pickerItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    // MARK: Nav

    private var nav: some View {
        HStack {
            Button("Cancel") { dismiss() }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(.stone))

            Spacer()

            Text(isEditing ? "Edit Piece" : "New Piece")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(.ink))

            Spacer()

            Button("Save") { save() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(.camel))
                .disabled(trimmedName.isEmpty)
                .opacity(trimmedName.isEmpty ? 0.4 : 1)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    // MARK: Photo

    private var photoButton: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            ZStack {
                Color(.linen)
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 8) {
                        Text("＋")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(.camel))
                        Text("Add photo")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(.stone))
                    }
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: Form

    private var form: some View {
        VStack(spacing: 20) {
            Field("NAME") {
                TextField("e.g. Linen Shirt", text: $name)
            }

            HStack(spacing: 16) {
                Field("CATEGORY") {
                    Menu {
                        ForEach(categories) { category in
                            Button(category.name) {
                                selectedCategoryID = category.persistentModelID
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategoryName ?? "Select")
                                .foregroundStyle(selectedCategoryName == nil
                                                 ? Color(.stone) : Color(.ink))
                            Spacer(minLength: 0)
                        }
                    }
                }
                Field("COLOR") {
                    TextField("Select", text: $colour)
                }
            }

            HStack(spacing: 16) {
                Field("COST") {
                    TextField("$0", text: $costText)
                        .keyboardType(.decimalPad)
                }
                Field("SEASON") {
                    Menu {
                        ForEach(Season.allCases) { option in
                            Button(option.rawValue) { season = option }
                        }
                    } label: {
                        HStack {
                            Text(season.rawValue).foregroundStyle(Color(.ink))
                            Spacer(minLength: 0)
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                Field("FABRIC") {
                    TextField("e.g. Linen", text: $fabric)
                }
                Color.clear.frame(maxWidth: .infinity)
            }

            Field("NOTES", height: 96) {
                TextField("Dry clean only, gift from mom...", text: $notes, axis: .vertical)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private var selectedCategoryName: String? {
        categories.first { $0.persistentModelID == selectedCategoryID }?.name
    }

    // MARK: Save

    private func save() {
        let category = categories.first { $0.persistentModelID == selectedCategoryID }
        let cost = Double(costText
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)) ?? 0

        if let item = existingItem {
            item.name     = trimmedName
            item.category = category
            item.color    = colour
            item.cost     = cost
            item.season   = season
            item.fabric   = fabric
            item.notes    = notes
            item.photo    = photoData
        } else {
            context.insert(ClothingItem(
                name: trimmedName,
                category: category,
                color: colour,
                cost: cost,
                season: season,
                fabric: fabric,
                notes: notes,
                photo: photoData
            ))
        }

        try? context.save()
        dismiss()
    }
}

// MARK: - Field

/// Label above a white rounded input box — the repeated unit in the Figma form.
private struct Field<Content: View>: View {
    let label: String
    var height: CGFloat?
    @ViewBuilder var content: () -> Content

    init(_ label: String, height: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.height = height
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .tracking(1.1)
                .foregroundStyle(Color(.stone))

            content()
                .font(.system(size: 15))
                .foregroundStyle(Color(.ink))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: height, alignment: .topLeading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.linen), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview {
    AddItemView()
        .modelContainer(PreviewData.container)
}
